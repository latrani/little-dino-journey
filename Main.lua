-- luacheck: globals GameScene SceneManager FollowCamera Z_INDEXES COL_TAGS SCENE_MANAGER CAMERA

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

import "lib/AnimatedSprite"
import "lib/LDtk"
import "lib/FollowCamera"

import "SceneManager"

import "scenes/GameScene"
import "scenes/GameOverScene"

import "dinos/Dino"
import "dinos/Ank"
import "dinos/Ceph"

import "entities/Spikes"
import "entities/CrackedStone"
import "entities/Gate"
import "entities/Log"

local pd <const> = playdate
local gfx <const> = pd.graphics

Z_INDEXES = {
  ACTIVE_DINO = 101,
  DINO = 100,
  WORLD = 1,
  HAZARD = 2
}

COL_TAGS = {
  ACTIVE_DINO = 0,
  DINO = 1,
  HAZARD = 2,
  CRACKED = 3,
  EXIT = 4,
  PLATFORM = 5
}

SCENE_MANAGER = SceneManager()
CAMERA = FollowCamera()

-- local scene = GameScene()

GameOverScene("LITTLE DINO JOURNEY\n\nA to jump, Up/Down to change dino.\nUse the crank for dino power.\n\nGet all the dinos to the exit.\nWork together!")

function pd.update()
  gfx.sprite.update()
  pd.timer.updateTimers()
  CAMERA:update()
end
