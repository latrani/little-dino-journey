-- luacheck: globals AnimatedSprite Dino Z_INDEXES COL_TAGS SCENE_MANAGER GameOverScene Pointer

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Dino").extends(AnimatedSprite)

function Dino:init(imageTable, x, y, theGameScene)
  self.gameScene = theGameScene
  Dino.super.init(self, imageTable)

  self.name = "SomeDino"
  self.deathMessage = ""

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

  self.pointer = Pointer(x, y)
  self.pointer:setVisible(false)
end

function Dino:setSpawn(x, y)
  self.spawnX = x
  self.spawnY = y
end

function Dino:setPointerLocation(x, y)
  local collideRect = self:getCollideRect()
  self.pointer:moveTo(x + collideRect.x + collideRect.width / 2, y + collideRect.y - 6)
end

function Dino:respawn()
  self:moveTo(self.spawnX, self.spawnY)
end

function Dino:activate()
  self.isActive = true
  self:setZIndex(Z_INDEXES.ACTIVE_DINO)
  self:setPointerLocation(self.x, self.y)
  self.pointer:setVisible(true)
end

function Dino:deactivate()
  self.isActive = false
  self:setZIndex(Z_INDEXES.DINO)
  self.pointer:setVisible(false)
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
  local actualX, actualY, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

  self:setPointerLocation(actualX, actualY)

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
          collision.other:startCarry(self)
        elseif self.ridingDino then
          self.ridingDino:stopCarry()
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

  if self.carryingDino then
    if self.touchingWall then
      self.carryingDino.xVelocity = 0
    else
      self.carryingDino.xVelocity = self.xVelocity
    end
    if not self.carryingDino.ridingDino then
      -- If it fell off, clean up
      self:stopCarry()
    end
  end

  if self.y > 240 then
    self.deathMessage = "fell too far!"
    self:die()
  end
end

function Dino:handleHazardCollision()
  self.shouldDie = true
  self.deathMessage = "got spiked!"
end

function Dino:handleCrackedCollision(other)
  -- Generally, do nothing
  return
end

function Dino:die()
  self.xVelocity = 0
  self.yVelocity = 0
  self.isDead = true
  self:setCollisionsEnabled(false)
  local deadMessage = self.name .. " " .. self.deathMessage .. "\n\nTry again!"
  pd.timer.performAfterDelay(200, function()
    -- self:setCollisionsEnabled(true)
    -- self.isDead = false
    SCENE_MANAGER:switchScene(GameOverScene, deadMessage)
    self.deathMessage = ""
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
  if self.touchingGround then
    self.yVelocity = 0
  elseif self.touchingCeiling then
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

function Dino:startCarry(otherDino)
  self.canJump = false
  self.carryingDino = otherDino
  otherDino.ridingDino = self
end

function Dino:stopCarry()
  self.canJump = true
  if self.carryingDino then
    self.carryingDino.ridingDino = nil
  end
  self.carryingDino = nil
end

function Dino:debugString()
    local s = "state: " .. self.currentState
    s = s .. "\n" .. "Y Velocity:" .. tostring(self.yVelocity)
    s = s .. "\n" .. "Y Velocity:" .. tostring(self.touchingGround)
    -- construct `s` using any properties belonging to your sprite
    return s, false -- true indicates that substitutions are needed
end
