-- luacheck: globals AnimatedSprite Zino Dino Z_INDEXES COL_TAGS

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Zino").extends(Dino)

function Zino:init(x, y, theGameScene)
  Zino.super.init(self, gfx.imagetable.new("img/zino-table-64-64"), x, y, theGameScene)

  self.name = "Zino"
  self:addState("idle", 1, 1)
  self:addState("run", 1, 8, {tickStep = 3})
  self:addState("jump", 1, 1)
  self:addState("swipe", 9, 14, {tickStep = 2})
  self:playAnimation()

  self.runSpeed = 3.0
  self.airSpeed = 3.0
  self.jumpVelocity = -5.5

  self.collideRects = {
    idle = {26, 44, 12, 20},
  }

  self:respawn()
  self:doSetCollideRect()
end

function Zino:handleInput()
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
      elseif crankChange ~= 0 then
        self:changeToSwipeState()
      else
        self:changeToIdleState()
      end
    end
    self:doSetCollideRect()
  end
end

function Zino:changeToSwipeState()
  self:changeState("swipe")
end


