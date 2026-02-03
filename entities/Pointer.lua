-- luacheck: globals Pointer Z_INDEXES COL_TAGS

local pd <const> = playdate
local gfx <const> = pd.graphics

local image <const> = gfx.image.new("img/Pointer.png")

class("Pointer").extends(gfx.sprite)

function Pointer:init(x, y)
  self:setZIndex(Z_INDEXES.UI)
  self:setImage(image)
  -- self:setCenter(0.5, 0.5)
  self:moveTo(x, y)
  self:add()
end

