local Sliderbox = require("widget")()
local drawing = require "drawing"
local Circle = require "Circle"

Sliderbox.parameters = {
  left = {
    value = 0,
  },
  top = {
    value = 0,
  },
  width = {
    value = 200,
  },
  height = {
    value = 200,
  },
  backgroundColor = {
    value = {50, 50, 50},
  },
  outlineColor = {
    value = {220, 220, 220},
  },
  midlinesColor = {
    value = {230, 230, 230},
  }
}

function Sliderbox:draw()
  drawing.pushCanvas(self.canvas)
  local x, y, w, h = self.left, self.top, self.width, self.height
  drawing.drawRect(0, 0, w, h, self.backgroundColor, "fill")
  drawing.drawLine(w/2, 0, w/2, h, self.midlinesColor)
  drawing.drawLine(0, h/2, w, h/2, self.midlinesColor)
  drawing.drawRect(0, 0, w, h, self.outlineColor, "line")
  self.circle:draw()
  drawing.drawCanvas(drawing.popCanvas(), x, y)
  return self
end

function Sliderbox:new()
  local sbox = {
    circle = Circle:new():set{radius=15, backgroundColor={200, 200, 210, 100}},
  }
  sbox = setmetatable(sbox, Sliderbox):initDefaults()
  sbox.canvas = drawing.newCanvas(sbox.width, sbox.height)
  function sbox.circle.handleMouseMove(cir, x, y, dx, dy)
    if cir.mouseCaptured then
      local new_x = x + dx
      if new_x > sbox.width then
        new_x = sbox.width
      elseif new_x < 0 then
        new_x = 0
      end
      local new_y = y + dy
      if new_y > sbox.height then
        new_y = sbox.height
      elseif new_y < 0 then
        new_y = 0
      end
      cir.center_x = new_x
      cir.center_y = new_y
    end
    return cir
  end
  return sbox
end

function Sliderbox:handleMouseClick(x, y, button)
  local left, right = self.left, self.left + self.width
  local top, bottom = self.top, self.top + self.height
  local all_ok = x > left and x < right and y > top and y < bottom
  if all_ok then
    if self.onClick then
      self.onClick(x, y, button)
    end
    local x_shift, y_shift = x - left, y - top
    self.circle:handleMouseClick(x_shift, y_shift, button)
  end
  self.mouseCaptured = true
  return self
end

function Sliderbox:handleMouseRelease(x, y, button)
  local x_shift, y_shift = x - self.left, y - self.top
  self.mouseCaptured = false
  self.circle:handleMouseRelease(x_shift, y_shift, button)
end

function Sliderbox:handleMouseMove(x, y, dx, dy)
  local left = self.left
  local top = self.top
  local x_shift, y_shift = x - left, y - top
  self.circle:handleMouseMove(x_shift, y_shift, dx, dy)
end

return Sliderbox
