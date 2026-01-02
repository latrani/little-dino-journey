-- luacheck: globals CrackedStone Z_INDEXES COL_TAGS

local pd <const> = playdate
local gfx <const> = pd.graphics

local image <const> = gfx.image.new("img/log.png")

class("Log").extends(gfx.sprite)

function Log:init(x, y)
  self:setZIndex(Z_INDEXES.WORLD)
  self:setImage(image)
  self:setCenter(0, 0)
  self:moveTo(x, y)
  self:add()

  self:setTag(COL_TAGS.PLATFORM)
  self:setCollideRect(0, 0, 40, 8)
end

