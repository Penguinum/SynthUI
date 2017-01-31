local Circle = require("widget")()
local drawing = require "drawing"

local sqrt = math.sqrt

Circle.parameters = {
  center_x = {
    value = 0,
  },
  center_y = {
    value = 0,
  },
  radius = {
    value = 20,
  },
  backgroundColor = {
    value = {200, 200, 200},
  },
}

function Circle:new()
  local circle = {}
  return setmetatable(circle, Circle):initDefaults()
end

function Circle:draw()
  drawing.drawCircle(self.center_x, self.center_y, self.radius, self.backgroundColor)
end

function Circle:handleMouseClick(x, y, button)
  local center_x, center_y, radius = self.center_x, self.center_y, self.radius
  local distance = sqrt((center_x - x)^2 + (center_y - y)^2)
  local all_ok = distance <= radius
  if all_ok then
    self.mouseCaptured = true
    if self.onClick then
      self.onClick(x, y, button)
    end
  end
  return self
end

function Circle:onClick(x, y, button)
end

function Circle:handleMouseRelease(x, y, button)
  self.mouseCaptured = false
end

function Circle:handleMouseMove(x, y, dx, dy)
  if self.mouseCaptured then
    self.center_x = x + dx
    self.center_y = y + dy
  end
  return self
end

return Circle
