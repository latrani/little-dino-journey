-- luacheck: globals Gate Z_INDEXES COL_TAGS SCENE_MANAGER GameOverScene

local pd <const> = playdate
local gfx <const> = pd.graphics

local gateImage <const> = gfx.image.new("img/Gate.png")

local xPadding = 8

class("Gate").extends(gfx.sprite)

function Gate:init(x, y, theGameScene)
  self.gameScene = theGameScene
  self:setZIndex(Z_INDEXES.WORLD)
  self:setImage(gateImage)
  self:moveTo(x, y)
  self:add()

  self:setTag(COL_TAGS.EXIT)
  self:setCollideRect(-xPadding, 0, self.width + xPadding * 2, self.height)
end

function Gate:checkSuccess()
  local overlaps = self:overlappingSprites()
  if #overlaps == #self.gameScene.dinos then
    SCENE_MANAGER:switchScene(GameOverScene, "You win!")
  end
end
