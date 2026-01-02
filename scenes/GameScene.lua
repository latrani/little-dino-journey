-- luacheck: globals LDtk GameScene Dino Ank Ceph Spikes CrackedStone
-- luacheck: globals Gate FollowCamera SCENE_MANAGER GameOverScene CAMERA

local pd <const> = playdate
local gfx <const> = pd.graphics

local spawnX = 30
local spawnY = 200

LDtk.load("levels/world.ldtk", false)

class("GameScene").extends(gfx.sprite)

function GameScene:init()
  self:goToLevel("Level_0")

  self.dinos = {Ank(spawnX, spawnY, self), Ceph(spawnX + 30, spawnY, self)}

  self.activeDinoIndex = #self.dinos
  self:activateDino()

  self:add()
end

function GameScene:resetDinos()
  for _, dino in ipairs(self.dinos) do
    dino:respawn()
  end
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

      CAMERA:setBounds(layerSprite)

      local empty_tiles = LDtk.get_empty_tileIDs(level_name, "Solid", layer_name)
      if empty_tiles then
        gfx.sprite.addWallSprites(tilemap, empty_tiles)
      end
    end
  end

  for _, entity in ipairs(LDtk.get_entities(level_name)) do
    if entity.name == "Spikes" then
      Spikes(entity.position.x, entity.position.y)
    end
    if entity.name == "CrackedStone" then
      CrackedStone(entity.position.x, entity.position.y)
    end
    if entity.name == "Gate" then
      Gate(entity.position.x, entity.position.y, self)
    end
    if entity.name == "Log" then
      Log(entity.position.x, entity.position.y, self)
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
  self.dinos[index]:deactivate()
  CAMERA:clearTarget()
end

function GameScene:activateDino(index)
  if not index then
    index = self.activeDinoIndex
  end
  self.dinos[index]:activate()
  CAMERA:setTarget(self.dinos[index], true)
end

function GameScene:update()
  if pd.buttonJustPressed(pd.kButtonUp) then
    print("Up")
    self:cycleDino(1)
  elseif pd.buttonJustPressed(pd.kButtonDown) then
    print("Doen")
    self:cycleDino(-1)
  end
end
