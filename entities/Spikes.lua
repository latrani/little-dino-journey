-- luacheck: globals Spikes Z_INDEXES COL_TAGS

local pd <const> = playdate
local gfx <const> = pd.graphics

local spikeImage <const> = gfx.image.new("img/Spikes.png")

class("Spikes").extends(gfx.sprite)

function Spikes:init(x, y)
  self:setZIndex(Z_INDEXES.HAZARD)
  self:setImage(spikeImage)
  self:setCenter(0, 0)
  self:moveTo(x, y)
  self:add()

  self:setTag(COL_TAGS.HAZARD)
  self:setCollideRect(3, 7, 2, 1)
end
