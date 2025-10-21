-- luacheck: globals LDtk GameScene Z_INDEXES COL_TAGS

local gfx <const> = playdate.graphics

Z_INDEXES = {
  Player = 100
}

COL_TAGS = {
  Player = 1
}


LDtk.load("levels/world.ldtk", false)

class("GameScene").extends()

function GameScene:init()
  self:goToLevel("Level_0")

  self.player = Player(50, 50)
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

      local empty_tiles = LDtk.get_empty_tileIDs(level_name, "Solid", layer_name)
      if empty_tiles then
        gfx.sprite.addWallSprites(tilemap, empty_tiles)
      end
    end
  end
end
