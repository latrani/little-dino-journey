-- luacheck: globals SceneManager

local pd <const> = playdate
local gfx <const> = pd.graphics

class('SceneManager').extends()

function SceneManager:switchScene(scene, ...)
  self.newScene = scene
  self.sceneArgs = ...
  self:loadNewScene()
end

function SceneManager:loadNewScene()
  self:cleanupScene()
  self.newScene(self.sceneArgs)
end

function SceneManager:cleanupScene()
  gfx.sprite.removeAll()
  self:removeTimers()
  gfx.setDrawOffset(0, 0)
end

function SceneManager:removeTimers()
  local allTimers = pd.timer.allTimers()
  for _, timer in ipairs(allTimers) do
      timer:remove()
  end
end
