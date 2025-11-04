-- luacheck: globals AnimatedSprite Ank Dino Z_INDEXES COL_TAGS

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Ank").extends(Dino)

function Ank:init(x, y)
  Ank.super.init(self, gfx.imagetable.new("img/ank-table-64-64"))

  self.rollSpeed = 4.0

  self:addState("idle", 1, 1)
  self:addState("run", 1, 1)
  self:addState("jump", 1, 1)
  self:addState("curl", 2, 2)
  self:addState("roll", 2, 2)
  self:playAnimation()

  self.collideRects = {
    idle = {24, 48, 16, 16},
    run  = {24, 48, 16, 16},
    jump = {24, 48, 16, 16},
    curl = {24, 44, 16, 20},
    roll = {24, 44, 16, 20}
  }

  self:moveTo(x, y)
  self:doSetCollideRect()
end
