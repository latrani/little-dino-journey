-- luacheck: globals Spikes Z_INDEXES COL_TAGS

local pd <const> = playdate
local gfx <const> = pd.graphics

local spikeImage <const> = gfx.image.new("img/spikes.png")

class("Spikes").extends(gfx.sprite)

function Spikes:init(x, y)
  self:setZIndex(Z_INDEXES.HAZARD)
  self:setImage(spikeImage)
  self:setCenter(0, 0)
  self:moveTo(x, y)
  self:add()

  self:setTag(COL_TAGS.HAZARD)
  self:setCollideRect(1, 3, 6, 5)
end
