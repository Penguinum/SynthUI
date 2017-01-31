local ADSR = require("widget")()
local drawing = require "drawing"

ADSR.parameters = {
  left = {
    value = 0,
  },
  top = {
    value = 0,
  },
  width = {
    value = 300,
  },
  height = {
    value = 150,
  },
  backgroundColor = {
    value = {50, 50, 50},
  },
  outlineColor = {
    value = {220, 220, 220},
  },
  midlinesColor = {
    value = {230, 230, 230},
  },
  attack = {
    value = 0,
  },
  decay = {
    value = 0,
  },
  sustain = {
    value = 1,
  },
  release = {
    value = 0,
  }
}

function ADSR:new()
  local adsr = {}
  setmetatable(adsr, ADSR):initDefaults()
  adsr.canvas = drawing.newCanvas(self.width, self.height)
  return adsr
end

function ADSR:draw()
  drawing.pushCanvas(self.canvas)
  local x, y, w, h = self.left, self.top, self.width, self.height
  drawing.drawRect(0, 0, w, h, self.backgroundColor, "fill")
  drawing.drawRect(0, 0, w, h, self.outlineColor, "line")
  drawing.drawCanvas(drawing.popCanvas(), x, y)
  return self
end

return ADSR
