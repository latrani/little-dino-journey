-- luacheck: globals GameScene FollowCamera

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

import "lib/AnimatedSprite"
import "lib/LDtk"
import "lib/FollowCamera"

import "GameScene"
import "dinos/Dino"
import "dinos/Ank"
import "dinos/Ceph"

local pd <const> = playdate
local gfx <const> = pd.graphics

local camera = FollowCamera()
local scene = GameScene(camera)

function pd.update()
  gfx.sprite.update()
  pd.timer.updateTimers()
  camera:update()
  scene:update()
end
