-- luacheck: globals AnimatedSprite Dino Z_INDEXES COL_TAGS COL_GROUPS

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Dino").extends(AnimatedSprite)

function Dino:init(imageTable, theGameScene)
  self.gameScene = theGameScene
  Dino.super.init(self, imageTable)

  self:setZIndex(Z_INDEXES.DINO)
  self:setTag(COL_TAGS.DINO)
  self:setGroups(COL_GROUPS.DINO)
  self:setCollidesWithGroups(COL_GROUPS.WORLD, COL_GROUPS.DINO_PLATFORM)

  self.isActive = false
  self.xVelocity = 0
  self.yVelocity = 0
  self.gravity = 1.0
  self.canJump = true
  self.runSpeed = 2.0
  self.airSpeed = 2.0
  self.jumpVelocity = -3.6
  self.airDrag = 0.1
  self.minAirSpeed = 0.5

  self.touchingGround = false
  self.touchingWall = false
  self.touchingCeiling = false

  self.isDead = false
end

function Dino:setActive(active)
  self.isActive = active
end

function Dino:doSetCollideRect()
  self:setCollideRect(table.unpack(self.collideRects[self.currentState] or self.collideRects['idle']))
end

function Dino:collisionResponse(other)
    local tag = other:getTag()
    if tag == COL_TAGS.HAZARD then
        return gfx.sprite.kCollisionTypeOverlap
    end
    return gfx.sprite.kCollisionTypeSlide
end

function Dino:update()
  if self.isDead then
    return
  end

  self:updateAnimation()

  self:handleState()
  self:handleMovementAndCollisions()
end

function Dino:handleState()
  if self.currentState == "jump" then
    if self.touchingGround then
      self:changeToIdleState()
    end
    self:applyDrag(self.airDrag)
  end

  self:applyGravity()
  self:handleInput()
end

function Dino:handleMovementAndCollisions()
  local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

  self.touchingGround = false
  self.touchingWall = false
  self.touchingCeiling = false

  local died = false

  for i = 1, length do
    local collision = collisions[i]
    local collisionTag = collision.other:getTag()

    if collision.type == gfx.sprite.kCollisionTypeSlide then
      if collision.normal.y == -1 then
        self.touchingGround = true
        self.chargeAvailable = true
      end
      if collision.normal.y == 1 then
        self.touchingCeiling = true
      end
      if collision.normal.x ~= 0 then
        self.touchingWall = true
      end
    end

    if collisionTag == COL_TAGS.HAZARD then
      died = true
    end
  end

  if self.xVelocity < 0 then
    self.globalFlip = 1
  elseif self.xVelocity > 0 then
    self.globalFlip = 0
  end

  if died then
    self:die()
  end
end

function Dino:die()
  self.xVelocity = 0
  self.yVelocity = 0
  self.isDead = true
  self:setCollisionsEnabled(false)
  pd.timer.performAfterDelay(200, function()
    self:setCollisionsEnabled(true)
    self.isDead = false
    self.gameScene:resetDinos()
  end)
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

function Dino:applyDrag(drag)
  if self.xVelocity > drag then
    self.xVelocity -= drag
  elseif self.xVelocity < -drag then
    self.xVelocity += drag
  end

  if self.touchingWall then
    self.xVelocity = 0
  end
end
