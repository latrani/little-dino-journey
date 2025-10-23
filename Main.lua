-- luacheck: globals GameScene FollowCamera

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "lib/AnimatedSprite"
import "lib/LDtk"
import "lib/FollowCamera"

import "GameScene"
import "Player"

local pd <const> = playdate
local gfx <const> = pd.graphics

local camera = FollowCamera()
GameScene(camera)

function pd.update()
  gfx.sprite.update()
  pd.timer.updateTimers()
  camera:update()
end
