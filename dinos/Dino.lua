-- luacheck: globals AnimatedSprite Dino Z_INDEXES COL_TAGS SCENE_MANAGER GameOverScene

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Dino").extends(AnimatedSprite)

function Dino:init(imageTable, x, y, theGameScene)
  self.gameScene = theGameScene
  Dino.super.init(self, imageTable)

  self:setCenter(0, 0)
  self:setZIndex(Z_INDEXES.DINO)
  self:setTag(COL_TAGS.DINO)
  self:setSpawn(x, y)

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

  self.isRiding = nil
  self.isRiddenBy = nil

  self.touchingGround = false
  self.touchingWall = false
  self.touchingCeiling = false

  self.shouldDie = false
  self.isDead = false
  self.atGoal = false
end

function Dino:setSpawn(x, y)
  self.spawnX = x
  self.spawnY = y
end

function Dino:respawn()
  self:moveTo(self.spawnX, self.spawnY)
end

function Dino:activate()
  self.isActive = true
  self:setZIndex(Z_INDEXES.ACTIVE_DINO)
  -- self:setTag(Z_INDEXES.ACTIVE_DINO)
end

function Dino:deactivate()
  self.isActive = false
  self:setZIndex(Z_INDEXES.DINO)
  -- self:setTag(COL_TAGS.DINO)
end


function Dino:doSetCollideRect()
  self:setCollideRect(table.unpack(self.collideRects[self.currentState] or self.collideRects['idle']))
end

-- The comical one
-- function Dino:collisionResponse(other)
  -- local tag = other:getTag()
  -- if tag == COL_TAGS.HAZARD then
  --   return "overlap"
  -- elseif tag == COL_TAGS.DINO then
  --   if self.yVelocity > 0 then
  --     return "slide"
  --   else
  --     return "overlap"
  --   end
  -- end
  -- return "slide"
-- end

function Dino:collisionResponse(other)
  local tag = other:getTag()
  if tag == COL_TAGS.HAZARD then
    return "overlap"
  end
  if tag == COL_TAGS.EXIT then
    other:checkSuccess()
    return "overlap"
  end
  if tag == COL_TAGS.PLATFORM or tag == COL_TAGS.DINO then
    if (self.y + self.height <= other.y + other:getCollideRect().y) then
      return "slide"
    else
      return "overlap"
    end
  end
  return "slide"
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

  for i = 1, length do
    local collision = collisions[i]
    local collisionTag = collision.other:getTag()

    if collision.type == gfx.sprite.kCollisionTypeSlide then
      if collision.normal.y == -1 then
        self.touchingGround = true
        self.chargeAvailable = true
        if collision.other:getTag() == COL_TAGS.DINO then
          self.isRiding = collision.other
          collision.other.isRiddenBy = self
        elseif self.isRiding then
          self.isRiding.isRiddenBy = nil
          self.isRiding = nil
        end
      end
      if collision.normal.y == 1 then
        self.touchingCeiling = true
      end
      if collision.normal.x ~= 0 then
        self.touchingWall = true
      end
    end

    if collisionTag == COL_TAGS.HAZARD then
      self:handleHazardCollision()
    end

    if collisionTag == COL_TAGS.CRACKED then
      self:handleCrackedCollision(collision.other)
    end
  end

  if self.xVelocity < 0 then
    self.globalFlip = 1
  elseif self.xVelocity > 0 then
    self.globalFlip = 0
  end

  if self.shouldDie then
    self.shouldDie = false
    self:die()
  end

  if self.isRiddenBy then
    self.isRiddenBy.xVelocity = self.xVelocity
    self.isRiddenBy.yVelocity = self.yVelocity
  end
end

function Dino:handleHazardCollision()
  self.shouldDie = true
end

function Dino:handleCrackedCollision(other)
  print("Generic cracked collision")
  return
end

function Dino:die()
  self.xVelocity = 0
  self.yVelocity = 0
  self.isDead = true
  self:setCollisionsEnabled(false)
  pd.timer.performAfterDelay(200, function()
    -- self:setCollisionsEnabled(true)
    -- self.isDead = false
    SCENE_MANAGER:switchScene(GameOverScene, "Try again!")
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
  if self.touchingGround or self.touchingCeiling then
    self.yVelocity = 0
  else
    self.yVelocity += self.gravity
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
