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
    value = 400,
  },
  height = {
    value = 400,
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
  drawing.pushCanvas(self.canvas)
  local x, y, w, h = self.left, self.top, self.width, self.height
  drawing.drawRect(0, 0, w, h, self.backgroundColor, "fill")
  drawing.drawRect(0, 0, w, h, self.outlineColor, "line")
  local points = self.points
  local points_num = #points
  for i = 1, points_num do
    local x1, y1 = self:toScreenCoords(points[i][1], points[i][2])
    if i < points_num then
      local x2, y2 = self:toScreenCoords(points[i+1][1], points[i+1][2])
      drawing.drawLine(x1, y1, x2, y2, {0, 25, 0})
    end
    drawing.drawCircle(x1, y1, 4, {10, 250, 10})
  end
  drawing.drawCanvas(drawing.popCanvas(), x, y)
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
    points = {{0, 0}, {0.5, 1}, {1, 0}}
  }
  setmetatable(cbox, PolylineEdit):initDefaults()
  cbox.canvas = drawing.newCanvas(cbox.width, cbox.height)
  return cbox
end

function PolylineEdit:searchNeighbours(x)
  local guess_left = 1
  for i = 2, #self.points do
    if self.points[i][1] < x then
      guess_left = i
    else
      break
    end
  end
  return guess_left
end

function PolylineEdit:addPoint(x, y)
  x, y = self:toNormalCoords(x, y)
  local left = self:searchNeighbours(x)
  local points = self.points
  print(points[left][1], x)
  if math.abs(points[left][1] - x) <= 0.1 then
    points[left][2] = y
    return left
  else
    table.insert(points, left + 1, {x, y})
    return left + 1
  end
end

function PolylineEdit:handleMouseClick(x, y, button, is_double)
  local left, right = self.left, self.left + self.width
  local top, bottom = self.top, self.top + self.height
  local all_ok = x > left and x < right and y > top and y < bottom
  if all_ok then
    local x_shift, y_shift = x - left, y - top
    self.movepoint_num = self:findClosest(self:toNormalCoords(x_shift, y_shift))
    if is_double then
      local x_normal, y_normal = self:toNormalCoords(x_shift, y_shift)
      local closest = self:findClosest(x_normal, y_normal)
      if closest and closest ~= 1 and closest ~= #self.points then
        table.remove(self.points, closest)
        self.movepoint_num = nil
        self.mouse_captured = false
      else
        local num = self:addPoint(x_shift, y_shift)
        self.movepoint_num = num
        self.mouse_captured = true
      end
    end
  end
  self.mouse_captured = true
  return self
end

function PolylineEdit:handleMouseRelease(x, y, button)
  self.movepoint_num = nil
  self.mouse_captured = false
end

function PolylineEdit:handleMouseMove(x, y, dx, dy)
  local left, top = self.left, self.top
  local point_num = self.movepoint_num
  local point_obj = self.points[point_num]
  local points = self.points
  if point_obj then
    local x_shift, y_shift = x - left, y - top
    x, y = self:toNormalCoords(x_shift, y_shift)

    if point_num ~= 1 and x < points[point_num-1][1] then
      x = points[point_num-1][1]
    end

    if point_num ~= #points and x > points[point_num+1][1] then
      x = points[point_num+1][1]
    end

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

function PolylineEdit:getValue()
  return self.points
end

return PolylineEdit
