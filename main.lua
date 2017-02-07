local SynthUI = require "SynthUI"
local mainPanel = SynthUI.Panel:new():set{left=1, top=1}
local polyline_edit = SynthUI.PolylineEdit:new():set{left=0, top=0}
mainPanel:addNodes{polyline_edit}
function love.draw()
  mainPanel:draw()
end



