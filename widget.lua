local Widget = {}

function Widget:draw()
  return
end

function Widget:set(param_table)
  local parameters = self.parameters
  for k, v in pairs(param_table) do
    if parameters[k] then
      if parameters[k].set then
        parameters[k].set(self, v)
      else
        self[k] = v
      end
    end
  end
  return self
end

function Widget:get(param_name)
  return self.parameters[param_name].value
end

function Widget:initDefaults()
  for k, v in pairs(self.parameters) do
    if v.value then
      self:set{[k]=v.value}
    end
  end
  return self
end

function Widget:handleMouseClick(x, y, button, is_double)
  local left, right = self.left, self.left + self.width
  local top, bottom = self.top, self.top + self.height
  local all_ok = x > left and x < right and y > top and y < bottom
  if all_ok then
    if self.onClick then
      self:onClick(x, y, button)
    end
    if self.child_nodes then
      local x_shift, y_shift = x - left, y - top
      for _, widget in pairs(self.child_nodes) do
        widget:handleMouseClick(x_shift, y_shift, button, is_double)
      end
    end
  end
  self.mouseCaptured = true
  return self
end

function Widget:handleMouseRelease(x, y, button)
  local x_shift, y_shift = x - self.left, y - self.top
  self.mouseCaptured = false
  if self.child_nodes then
    for _, widget in pairs(self.child_nodes) do
      widget:handleMouseRelease(x_shift, y_shift, button)
    end
  end
end

function Widget:handleMouseMove(x, y, dx, dy)
  local x_shift, y_shift = x - self.left, y - self.top
  if self.child_nodes then
    for _, widget in pairs(self.child_nodes) do
      widget:handleMouseMove(x_shift, y_shift, dx, dy)
    end
  end
end

local function Create()
  local new_class = {}
  local new_class_mt = {__index=Widget}
  setmetatable(new_class, new_class_mt)
  new_class.__index = new_class
  return new_class
end

return Create
