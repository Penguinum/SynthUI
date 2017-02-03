local SynthUI = require "SynthUI"

local mainPanel = SynthUI.Panel:new():set{left=10, top=10}

local button = SynthUI.Button:new():set{left=0, top=200, text="Quit"}
function button:onClick(x, y, button)
  love.event.quit(0)
end

local sliderbox = SynthUI.ADSR:new():set{left=110, top=10}
local polyline_edit = SynthUI.PolylineEdit:new():set{left=110, top=250}

mainPanel:addNodes{button, sliderbox, polyline_edit}

local last_click = 0
local last_click_button
local click_interval = 0.05

function love.mousepressed(x, y, button)
  local is_double = false
  local time = os.clock()
  if time - last_click <= click_interval and button == last_click_button then
    is_double = true
  else
    last_click = time
  end
  print(is_double and "double click" or "single click")
  last_click_button = button
  mainPanel:handleMouseClick(x, y, button, is_double)
end

function love.mousereleased(x, y, button)
  mainPanel:handleMouseRelease(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
  mainPanel:handleMouseMove(x, y, dx, dy)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

function love.draw()
  mainPanel:draw()
end

