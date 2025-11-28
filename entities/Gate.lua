-- luacheck: globals Gate Z_INDEXES COL_TAGS

local pd <const> = playdate
local gfx <const> = pd.graphics

local gateImage <const> = gfx.image.new("img/Gate.png")

class("Gate").extends(gfx.sprite)

function Gate:init(x, y, theGameScene)
  self.gameScene = theGameScene
  self:setZIndex(Z_INDEXES.WORLD)
  self:setImage(gateImage)
  self:setCenter(0, 0)
  self:moveTo(x-self.width, y-self.height)
  -- self:moveTo(x, y)
  self:add()

  self:setTag(COL_TAGS.EXIT)
  self:setCollideRect(0, 0, self.width, self.height)
end

function Gate:checkSuccess()
  local overlaps = self:overlappingSprites()
  if #overlaps == #self.gameScene.dinos then
    self.gameScene:completeLevel()
  end
end
