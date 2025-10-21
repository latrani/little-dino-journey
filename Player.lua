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
  self:addState("roll", 2, 2)
  self:playAnimation()

  self:moveTo(x, y)
  self:setZIndex(Z_INDEXES.Player)
  self:setTag(COL_TAGS.Player)
  self:setCollideRect(22, 0, 20, 16)

  self.xVelocity = 0
  self.yVelocity = 0
  self.gravity = 1.0
  self.maxSpeed = 2.0

  self.touchingGround = false
  self.touchingWall = false
  self.touchingCeiling = false
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
  elseif self.currentState == "run" then
    self:applyGravity()
    self:handleGroundInput()
  elseif self.currentState == "jump" then
  end
end

function Player:handleMovementAndCollisions()
  local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

  self.touchingGround = false

  for i = 1, length do
    local collision = collisions[i]
    if collision.normal.y == -1 then
      self.touchingGround = true
    end
  end
end

function Player:handleGroundInput()
  if pd.buttonIsPressed(pd.kButtonLeft) then
    self:changeToRunState("left")
  elseif pd.buttonIsPressed(pd.kButtonRight) then
    self:changeToRunState("right")
  else
    self:changeToIdleState()
  end
end

function Player:changeToIdleState()
  self.xVelocity = 0
  self:changeState("idle")
end

function Player:changeToRunState(direction)
  if direction == "left" then
    self.xVelocity = -self.maxSpeed
  elseif direction == "right" then
    self.xVelocity = self.maxSpeed
  end
end

function Player:applyGravity()
  self.yVelocity += self.gravity
  if self.touchingGround then
    self.yVelocity = 0
  end
end
