local PolylineEdit = require("widget")()
local drawing = require "drawing"

local function dist2(x1, y1, x2, y2)
  return (x1 - x2)^2 + (y1 - y2)^2
end

PolylineEdit.parameters = {
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

function PolylineEdit:draw()
  local old_canvas = love.graphics.getCanvas()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()
  local x, y, w, h = self.left, self.top, self.width, self.height
  drawing.drawRect(0, 0, w, h, self.backgroundColor, "fill")
  drawing.drawRect(0, 0, w, h, self.outlineColor, "line")
  local points = self.points
  local points_num = #points
  for i = 1, points_num do
    local x1, y1 = self:toScreenCoords(points[i][1], points[i][2])
    if i < points_num then
      local x2, y2 = self:toScreenCoords(points[i+1][1], points[i+1][2])
      drawing.drawLine(x1, y1, x2, y2, {0, 255, 0})
    end
    drawing.drawCircle(x1, y1, 4, {10, 250, 10})
  end
  love.graphics.setCanvas(old_canvas)
  love.graphics.draw(self.canvas, x, y)
  return self
end

function PolylineEdit:toNormalCoords(sx, sy)
  local w, h = self.width, self.height
  return sx / w, 1 - sy / h
end

function PolylineEdit:toScreenCoords(nx, ny)
  local w, h = self.width, self.height
  return nx * w, (1 - ny) * h
end

function PolylineEdit:findClosest(x, y)
  local points = self.points
  local closest_point, closest_dist2 = 1, dist2(points[1][1], points[1][2], x, y)
  for i = 2, #points do
    local new_point = i
    local point_obj = points[new_point]
    local new_dist2 = dist2(point_obj[1], point_obj[2], x, y)
    if new_dist2 < closest_dist2 then
      closest_dist2 = new_dist2
      closest_point = new_point
    end
  end
  return closest_dist2 < 0.002 and closest_point or nil
end

function PolylineEdit:new()
  local cbox = {
    points = {{0, 0}, {0.5, 0.5}, {0.7, 0.8}, {1, 0}}
  }
  setmetatable(cbox, PolylineEdit):initDefaults()
  cbox.canvas = love.graphics.newCanvas(cbox.width, cbox.height, "rgba8", 10)
  return cbox
end

function PolylineEdit:handleMouseClick(x, y, button, is_double)
  local left, right = self.left, self.left + self.width
  local top, bottom = self.top, self.top + self.height
  local all_ok = x > left and x < right and y > top and y < bottom
  if all_ok then
    local x_shift, y_shift = x - left, y - top
    self.movepoint_num = self:findClosest(self:toNormalCoords(x_shift, y_shift))
    -- if is_double then
    --   print("double click")
    -- end
  end
  self.mouseCaptured = true
  return self
end

function PolylineEdit:handleMouseRelease(x, y, button)
  -- local x_shift, y_shift = x - self.left, y - self.top
  self.movepoint_num = nil
  self.mouseCaptured = false
end

function PolylineEdit:handleMouseMove(x, y, dx, dy)
  local left, top = self.left, self.top
  local point_num = self.movepoint_num
  local point_obj = self.points[point_num]
  if point_obj then
    local x_shift, y_shift = x - left, y - top
    x, y = self:toNormalCoords(x_shift, y_shift)
    -- Check bounds
    if point_num == 1 then
      x = 0
    elseif point_num == #self.points then
      x = 1
    end
    if y > 1 then y = 1 end
    if y < 0 then y = 0 end
    if x > 1 then x = 1 end
    if x < 0 then x = 0 end
    --
    point_obj[1], point_obj[2] = x, y
  end
end

return PolylineEdit
