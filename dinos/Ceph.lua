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

  self.chargeAvailable = true
  self.chargeSpeed = 16
  self.chargeMinSpeed = 6
  self.chargeDrag = 3

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

function Dino:handleState()
  if self.currentState == "jump" then
    if self.touchingGround then
      self:changeToIdleState()
    end
    self:applyDrag(self.airDrag)
    self:applyGravity()
    self:handleInput()
  elseif self.currentState == "charge" then
    self:applyDrag(self.chargeDrag)
    if math.abs(self.xVelocity) <= self.chargeMinSpeed then
      self:changeToFallState()
    end
  else
    self:applyGravity()
    self:handleInput()
  end
end

function Ceph:handleInput()
  if self.isActive then
    if self.currentState == "jump" then
      if pd.buttonIsPressed(pd.kButtonLeft) then
        self.xVelocity = -self.airSpeed
      elseif pd.buttonIsPressed(pd.kButtonRight) then
        self.xVelocity = self.airSpeed
      end
    elseif self.currentState == "bow" then
      -- Using ticks here to basically buffer the crank input
      self.crankChange = pd.getCrankTicks(10)
      if self.crankChange > 0 then
        self:changeToChargeState()
      end
    else -- Ground input
      self.crankChange = pd.getCrankTicks(10)
      if pd.buttonJustPressed(pd.kButtonA) and self.canJump then
        self:changeToJumpState()
      elseif self.crankChange < 0 and self.chargeAvailable then
        self:changeToBowState()
      elseif pd.buttonIsPressed(pd.kButtonLeft) then
        self:changeToRunState("left")
      elseif pd.buttonIsPressed(pd.kButtonRight) then
        self:changeToRunState("right")
      else
        self:changeToIdleState()
      end
    end
    self:doSetCollideRect()
  end
end

function Ceph:changeToBowState()
  self:changeState("bow")
end


function Ceph:changeToFallState()
  self:changeState("jump")
end

function Ceph:changeToChargeState()
  self.chargeAvailable = false
  self.yVelocity = 0

  if self.globalFlip == 1 then
    self.xVelocity = -self.chargeSpeed
  else --
    self.xVelocity = self.chargeSpeed
  end

  self:changeState("charge")
end

