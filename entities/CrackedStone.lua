-- luacheck: globals CrackedStone Z_INDEXES COL_TAGS

local pd <const> = playdate
local gfx <const> = pd.graphics

local spikeImage <const> = gfx.image.new("img/CrackedStone.png")

class("CrackedStone").extends(gfx.sprite)

local BREAK_DELAY = 1

function CrackedStone:init(x, y)
  self:setZIndex(Z_INDEXES.WORLD)
  self:setImage(spikeImage)
  self:setCenter(0, 0)
  self:moveTo(x, y)
  self:add()

  self:setTag(COL_TAGS.CRACKED)
  self:setCollideRect(0, 0, 8, 8)

  self.willBreak = false
end

function CrackedStone:doBreak()
  self.willBreak = true
  local neighbors = {
    {self.x+1, self.y},
    {self.x, self.y+1},
    {self.x-1, self.y},
    {self.x, self.y-1},
  }
  for _, neighborCoord in ipairs(neighbors) do
    local _, _, collisions, _ = self:checkCollisions(table.unpack(neighborCoord))
    for _, collision in ipairs(collisions) do
      if collision.other.className == "CrackedStone" and not collision.other.willBreak then
        pd.timer.performAfterDelay(BREAK_DELAY, function()
          collision.other:doBreak()
        end)
      end
    end
  end
  self:remove()
end
