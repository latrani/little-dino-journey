-- luacheck: globals AnimatedSprite Ceph Dino Z_INDEXES COL_TAGS

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Ceph").extends(Dino)

function Ceph:init(x, y)
  Ceph.super.init(self, gfx.imagetable.new("img/ceph-table-64-64"))

  self.rollSpeed = 4.0

  self:addState("idle", 1, 1)
  self:addState("run", 1, 1)
  self:addState("jump", 1, 1)
  self:addState("bow", 2, 2)
  self:addState("charge", 2, 2)
  self:playAnimation()

  self.runSpeed = 3.0
  self.airSpeed = 3.0
  self.jumpVelocity = -6

  self.collideRects = {
    idle = {24, 40, 16, 24},
    run  = {24, 40, 16, 24},
    jump = {24, 40, 16, 24},
    curl = {24, 40, 16, 24},
    roll = {24, 40, 16, 24}
  }

  self:moveTo(x, y)
  self:doSetCollideRect()
end
