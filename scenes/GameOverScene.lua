-- luacheck: globals GameOverScene GameScene SCENE_MANAGER CAMERA

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('GameOverScene').extends(gfx.sprite)

function GameOverScene:init(text)
  local gameOverImage = gfx.image.new(gfx.getTextSize(text))
  gfx.pushContext(gameOverImage)
    gfx.drawText(text, 0, 0)
  gfx.popContext()
  local gameOverSprite = gfx.sprite.new(gameOverImage)
  gameOverSprite:moveTo(200, 120)
  gameOverSprite:add()

  CAMERA:setTarget(gameOverSprite)

  self:add()
end

function GameOverScene:update()
  if pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonB) then
    SCENE_MANAGER:switchScene(GameScene)
  end
end
