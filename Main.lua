-- luacheck: globals GameScene

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "lib/AnimatedSprite"
import "lib/LDtk"

import "GameScene"
import "Player"

local pd <const> = playdate
local gfx <const> = pd.graphics

GameScene()

function pd.update()
  gfx.sprite.update()
  pd.timer.updateTimers()
end
