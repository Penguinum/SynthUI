local Button = require("widget")()
local drawing = require "drawing"

Button.parameters = {
  left = {
    value = 0,
  },
  top = {
    value = 0,
  },
  width = {
    value = 100,
  },
  height = {
    value = 20,
  },
  backgroundColor = {
    value = {200, 200, 200},
  },
  text = {
    value = "Some button",
  },
}

function Button:new()
  local btn = {}
  return setmetatable(btn, Button):initDefaults()
end

function Button:draw()
  drawing.drawRect(self.left, self.top, self.width, self.height, self.backgroundColor)
  drawing.drawText(self.left, self.top, {0, 0, 0}, self.text)
  return self
end

return Button
