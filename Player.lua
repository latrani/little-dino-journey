-- luacheck: globals AnimatedSprite Player Z_INDEXES COL_TAGS

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Player").extends(AnimatedSprite)

function Player:init(x, y)
  local playerImageTable = gfx.imagetable.new("img/ank-table-64-16")
  Player.super.init(self, playerImageTable)

  self:addState("idle", 1, 1)
  self:addState("run", 1, 1)
  self:addState("jump", 1, 1)
  self:addState("curl", 2, 2)
  self:addState("roll", 2, 2)
  self:playAnimation()

  self:moveTo(x, y)
  self:setZIndex(Z_INDEXES.Player)
  self:setTag(COL_TAGS.Player)
  self:doSetCollideRect()

  self.xVelocity = 0
  self.yVelocity = 0
  self.gravity = 1.0
  self.runSpeed = 2.0
  self.airSpeed = 2.0
  self.rollSpeed = 4.0
  self.jumpVelocity = -3.6
  self.drag = 0.1
  self.minAirSpeed = 0.5
  self.canJump = true

  self.touchingGround = false
  self.touchingWall = false
  self.touchingCeiling = false
end

function Player:doSetCollideRect()
  if self.currentState == "roll" or self.currentState == "curl" then
    self:setCollideRect(24, 0, 16, 16)
  else
    self:setCollideRect(22, 0, 20, 16)
  end
end

function Player:collisionResponse()
  return gfx.sprite.kCollisionTypeSlide
end

function Player:update()
  self:updateAnimation()

  self:handleState()
  self:handleMovementAndCollisions()
end

function Player:handleState()
  if self.currentState == "idle" then
    self:applyGravity()
    self:handleGroundInput()
  elseif self.currentState == "curl" then
    self:applyGravity()
    self:handleGroundInput()
  elseif self.currentState == "run" then
    self:applyGravity()
    self:handleGroundInput()
  elseif self.currentState == "roll" then
    self:applyGravity()
    self:handleGroundInput()
  elseif self.currentState == "jump" then
    if self.touchingGround then
      self:changeToIdleState()
    end
    self:applyGravity()
    self:applyDrag()
    self:handleAirInput()
  end
end

function Player:handleMovementAndCollisions()
  local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

  self.touchingGround = false
  self.touchingWall = false
  self.touchingCeiling = false

  for i = 1, length do
    local collision = collisions[i]
    if collision.normal.y == -1 then
      self.touchingGround = true
    end
    if collision.normal.y == 1 then
      self.touchingCeiling = true
    end
    if collision.normal.x ~= 0 then
      self.touchingWall = true
    end
  end

  if self.xVelocity < 0 then
    self.globalFlip = 1
  elseif self.xVelocity > 0 then
    self.globalFlip = 0
  end
end

function Player:handleGroundInput()
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
  self:doSetCollideRect()
end

function Player:handleAirInput()
  if pd.buttonIsPressed(pd.kButtonLeft) then
    self.xVelocity = -self.airSpeed
  elseif pd.buttonIsPressed(pd.kButtonRight) then
    self.xVelocity = self.airSpeed
  end
end

function Player:changeToIdleState()
  self.canJump = true
  self.xVelocity = 0
  self:changeState("idle")
end

function Player:changeToRunState(direction)
  self.canJump = true
  if direction == "left" then
    self.xVelocity = -self.runSpeed
    self.globalFlip = 1
  elseif direction == "right" then
    self.xVelocity = self.runSpeed
    self.globalFlip = 0
  end
  self:changeState("run")
end

function Player:changeToRollState(direction)
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

function Player:changeToCurlState()
  self.xVelocity = 0
  self.canJump = false

  self:changeState("curl")
end

function Player:changeToJumpState()
  self.yVelocity = self.jumpVelocity
  self:changeState("jump")
end

function Player:applyGravity()
  self.yVelocity += self.gravity
  if self.touchingGround or self.touchingCeiling then
    self.yVelocity = 0
  end
end

function Player:applyDrag()
  if self.xVelocity > self.drag then
    self.xVelocity -= self.drag
  elseif self.xVelocity < -self.drag then
    self.xVelocity += self.drag
  end

  if self.touchingWall then
    self.xVelocity = 0
  end
end
