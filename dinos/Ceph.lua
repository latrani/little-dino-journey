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

function Ceph:handleInput()
  if self.isActive then
    local crankChange = pd.getCrankChange()
    if self.currentState == "jump" then
      if pd.buttonIsPressed(pd.kButtonLeft) then
        self.xVelocity = -self.airSpeed
      elseif pd.buttonIsPressed(pd.kButtonRight) then
        self.xVelocity = self.airSpeed
      end
    elseif self.currentState == "bow" then
      if ((crankChange > 0 and self.lastCranked == "left") or (crankChange < 0 and self.lastCranked == "right")) then
        print "Charge!"
        self:changeToIdleState()
      end
    else -- Ground input
      if pd.buttonJustPressed(pd.kButtonA) and self.canJump then
        self:changeToJumpState()
      elseif pd.buttonIsPressed(pd.kButtonLeft) then
        self:changeToRunState("left")
      elseif pd.buttonIsPressed(pd.kButtonRight) then
        self:changeToRunState("right")
      elseif crankChange < 0 then
        self:changeToBowState("left")
      elseif crankChange > 0 then
        self:changeToBowState("right")
      else
        self:changeToIdleState()
      end
    end
    self:doSetCollideRect()
  end
end

function Ceph:changeToBowState(direction)
  self.lastCranked = direction
  if direction == "left" then
    self.globalFlip = 0
  elseif direction == "right" then
    self.globalFlip = 1
  end
  self:changeState("bow")
end
