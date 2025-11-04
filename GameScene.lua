-- luacheck: globals LDtk GameScene Z_INDEXES COL_TAGS Dino

local pd <const> = playdate
local gfx <const> = pd.graphics

Z_INDEXES = {
  Dino = 100
}

COL_TAGS = {
  Dino = 1
}


LDtk.load("levels/world.ldtk", false)

class("GameScene").extends()

function GameScene:init(camera)
  self.camera = camera

  self:goToLevel("Level_0")

  self.dinos = {Ank(20, 50), Ceph(20, 50)}

  self.activeDinoIndex = 1
  self:activateDino()
end

function GameScene:goToLevel(level_name)
  gfx.sprite.removeAll()

  for layer_name, layer in pairs(LDtk.get_layers(level_name)) do
    if layer.tiles then
      local tilemap = LDtk.create_tilemap(level_name, layer_name)

      local layerSprite = gfx.sprite.new()
      layerSprite:setTilemap(tilemap)
      layerSprite:setCenter(0, 0)
      layerSprite:moveTo(0, 0)
      layerSprite:setZIndex(layer.zIndex)
      layerSprite:add()

      self.camera:setBounds(layerSprite)

      local empty_tiles = LDtk.get_empty_tileIDs(level_name, "Solid", layer_name)
      if empty_tiles then
        gfx.sprite.addWallSprites(tilemap, empty_tiles)
      end
    end
  end
end

function GameScene:cycleDino(amount)
  self:deactivateDino()
  local newDinoIndex = (self.activeDinoIndex + amount) % #self.dinos
  if newDinoIndex == 0 then
    newDinoIndex = #self.dinos
  end
  self.activeDinoIndex = newDinoIndex
  self:activateDino()
end

function GameScene:deactivateDino(index)
  if not index then
    index = self.activeDinoIndex
  end
  self.dinos[index]:setActive(false)
  self.camera:clearTarget()
end

function GameScene:activateDino(index)
  if not index then
    index = self.activeDinoIndex
  end
  self.dinos[index]:setActive(true)
  self.camera:setTarget(self.dinos[index], true)
end

function GameScene:update()
  if pd.buttonJustPressed(pd.kButtonUp) then
    self:cycleDino(1)
  elseif pd.buttonJustPressed(pd.kButtonDown) then
    self:cycleDino(-1)
  end
end
