-- luacheck: globals Ank Dino COL_TAGS

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Ank").extends(Dino)

function Ank:init(x, y, theGameScene)
  Ank.super.init(self, gfx.imagetable.new("img/ank-table-64-64"), x, y, theGameScene)

  self.rollSpeed = 4.0

  self:addState("idle", 1, 1)
  self:addState("run", 1, 8, {tickStep = 3})
  self:addState("jump", 1, 1)
  self:addState("curl", 9, 9)
  self:addState("roll", 9, 12, {tickStep = 3})
  self:playAnimation()

  self.collideRects = {
    idle = {24, 48, 16, 16},
    run  = {24, 48, 16, 16},
    jump = {24, 48, 16, 16},
    curl = {24, 44, 16, 20},
    roll = {24, 44, 16, 20}
  }

  self:respawn()
  self:doSetCollideRect()
end

function Ank:handleInput()
  if self.isActive then
    if self.currentState == "jump" then
      if pd.buttonIsPressed(pd.kButtonLeft) then
        self.xVelocity = -self.airSpeed
      elseif pd.buttonIsPressed(pd.kButtonRight) then
        self.xVelocity = self.airSpeed
      end
    else -- Ground input
      local crankChange = pd.getCrankChange()
      if pd.buttonJustPressed(pd.kButtonA) and self.canJump then
        self:changeToJumpState()
      elseif pd.buttonIsPressed(pd.kButtonLeft) then
        self:changeToRunState("left")
      elseif pd.buttonIsPressed(pd.kButtonRight) then
        self:changeToRunState("right")
      elseif crankChange < 0 then
        self:changeToRollState("left")
      elseif crankChange > 0 then
        self:changeToRollState("right")
      elseif self.currentState == "roll" then
        self:changeToCurlState()
      elseif self.currentState ~= "curl" then
        self:changeToIdleState()
      end
    end
    self:doSetCollideRect()
  end
end

function Ank:collisionResponse(other)
  if (self.currentState == "roll" or self.currentState == "curl") then
    local tag = other:getTag()
    if tag == COL_TAGS.DINO then
      return "slide"
    end
  end
  return Ank.super.collisionResponse(self, other)
end


function Ank:handleHazardCollision()
  if self.currentState ~= "roll" and self.currentState ~= "curl" then
    self.shouldDie = true
  end
end

function Ank:changeToRollState(direction)
  self.canJump = false
  if direction == "left" then
    self.xVelocity = -self.rollSpeed
    self.globalFlip = 1
  elseif direction == "right" then
    self.xVelocity = self.rollSpeed
    self.globalFlip = 0
  end
  self:changeState("roll")
end

function Ank:changeToIdleState()
  -- self:setTag(COL_TAGS.DINO)
  Ank.super.changeToIdleState(self)
end

function Ank:changeToCurlState()
  self.xVelocity = 0
  self.canJump = false
  -- self:setTag(COL_TAGS.DINO_PLATFORM)
  self:changeState("curl")
end


