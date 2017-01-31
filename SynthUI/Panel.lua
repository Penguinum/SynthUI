local Panel = require("widget")()
local drawing = require "drawing"

Panel.parameters = {
  left = {
    value = 50,
  },
  top = {
    value = 50,
  },
  width = {
    value = 700,
  },
  height = {
    value = 600,
  },
  backgroundColor = {
    value = {200, 200, 200},
  },
}

function Panel:new()
  local panel = {
    child_nodes = {},
  }
  setmetatable(panel, Panel):initDefaults()
  panel.canvas = drawing.newCanvas(panel.width, panel.height)
  return panel
end

function Panel:addNodes(widgets_table)
  for _, widget in pairs(widgets_table) do
    table.insert(self.child_nodes, widget)
  end
  return self
end

function Panel:draw()
  drawing.pushCanvas(self.canvas)
  -- love.graphics.clear()
  drawing.drawRect(0, 0, self.width, self.height, {100, 100, 100}, "line")
  for _, widget in pairs(self.child_nodes) do
    widget:draw()
  end
  drawing.drawCanvas(drawing.popCanvas(), self.left, self.top)
  return self
end

function Panel:update()
  return self
end

return Panel
