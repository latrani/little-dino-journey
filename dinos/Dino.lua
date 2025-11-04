-- luacheck: globals AnimatedSprite Dino Z_INDEXES COL_TAGS

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Dino").extends(AnimatedSprite)

function Dino:init(imageTable)
  Dino.super.init(self, imageTable)

  self:setZIndex(Z_INDEXES.Dino)
  self:setTag(COL_TAGS.Dino)
  self:setGroups(1)

  self.isActive = false
  self.xVelocity = 0
  self.yVelocity = 0
  self.gravity = 1.0
  self.canJump = true
  self.runSpeed = 2.0
  self.airSpeed = 2.0
  self.jumpVelocity = -3.6
  self.drag = 0.1
  self.minAirSpeed = 0.5

  self.touchingGround = false
  self.touchingWall = false
  self.touchingCeiling = false
end

function Dino:setActive(active)
  self.isActive = active
end

function Dino:doSetCollideRect()
  self:setCollideRect(table.unpack(self.collideRects[self.currentState] or self.collideRects['idle']))
end

function Dino:collisionResponse()
  return gfx.sprite.kCollisionTypeSlide
end

function Dino:update()
  self:updateAnimation()

  self:handleState()
  self:handleMovementAndCollisions()
end

function Dino:handleState()
  if self.currentState == "idle" then
    self:applyGravity()
  elseif self.currentState == "curl" then
    self:applyGravity()
  elseif self.currentState == "run" then
    self:applyGravity()
  elseif self.currentState == "roll" then
    self:applyGravity()
  elseif self.currentState == "jump" then
    if self.touchingGround then
      self:changeToIdleState()
    end
    self:applyGravity()
    self:applyDrag()
  end
  self:handleInput()
end

function Dino:handleInput()
  if self.isActive then
    if self.currentState == "idle" then
      self:handleGroundInput()
    elseif self.currentState == "curl" then
      self:handleGroundInput()
    elseif self.currentState == "run" then
      self:handleGroundInput()
    elseif self.currentState == "roll" then
      self:handleGroundInput()
    elseif self.currentState == "jump" then
      self:handleAirInput()
    end
  end
end

function Dino:handleGroundInput()
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

function Dino:handleAirInput()
  if pd.buttonIsPressed(pd.kButtonLeft) then
    self.xVelocity = -self.airSpeed
  elseif pd.buttonIsPressed(pd.kButtonRight) then
    self.xVelocity = self.airSpeed
  end
end


function Dino:handleMovementAndCollisions()
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

function Dino:changeToIdleState()
  self.canJump = true
  self.xVelocity = 0
  self:changeState("idle")
end

function Dino:changeToRunState(direction)
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

function Dino:changeToRollState(direction)
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

function Dino:changeToCurlState()
  self.xVelocity = 0
  self.canJump = false

  self:changeState("curl")
end

function Dino:changeToJumpState()
  self.yVelocity = self.jumpVelocity
  self:changeState("jump")
end

function Dino:applyGravity()
  self.yVelocity += self.gravity
  if self.touchingGround or self.touchingCeiling then
    self.yVelocity = 0
  end
end

function Dino:applyDrag()
  if self.xVelocity > self.drag then
    self.xVelocity -= self.drag
  elseif self.xVelocity < -self.drag then
    self.xVelocity += self.drag
  end

  if self.touchingWall then
    self.xVelocity = 0
  end
end
