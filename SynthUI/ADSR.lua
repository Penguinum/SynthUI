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
    value = 1,
  },
  decay = {
    value = 1,
  },
  sustain = {
    value = 0.5,
  },
  release = {
    value = 1,
  },
  max_stage_length = {
    value = 10,
  },
  line_color = {
    value = {30, 200, 50},
  },
}

function ADSR:new()
  local adsr = {}
  setmetatable(adsr, ADSR):initDefaults()
  adsr.canvas = drawing.newCanvas(self.width, self.height)
  adsr.max_stage_width = adsr.width / 4
  return adsr
end

function ADSR:toNormalCoords(sx, sy)
  local w, h = self.width, self.height
  return sx / w, 1 - sy / h
end

function ADSR:toScreenCoords(nx, ny)
  return nx * self.width, (1 - ny) * self.height
end

function ADSR:getScreenXs()
  local max_stage_len = self.max_stage_length
  local w = self.width
  local attack_x = w * self.attack/max_stage_len*0.25
  local decay_x = attack_x + w * self.decay/max_stage_len*0.25
  local sustain_x = decay_x + w * 0.25
  local release_x = sustain_x + w * self.release/max_stage_len*0.25
  return attack_x, decay_x, sustain_x, release_x
end

function ADSR:getScreenYs()
  local sust = (1-self.sustain) * self.height
  return 0, sust, sust, self.height
end

function ADSR:draw()
  drawing.pushCanvas(self.canvas)
  local x, y, w, h = self.left, self.top, self.width, self.height
  drawing.drawRect(0, 0, w, h, self.backgroundColor, "fill")
  local zero_x, zero_y = self:toScreenCoords(0, 0)
  local attack_x, decay_x, sustain_x, release_x = self:getScreenXs()
  local attack_y, decay_y, sustain_y, release_y = self:getScreenYs()
  drawing.drawPolyline({zero_x, zero_y, attack_x, attack_y, decay_x, decay_y,
    sustain_x, sustain_y, release_x, release_y}, self.line_color)
  drawing.drawRect(0, 0, w, h, self.outlineColor, "line")
  drawing.drawCanvas(drawing.popCanvas(), x, y)
  return self
end

function ADSR:findClosest(x)
  local xs = {self:getScreenXs()}
  local min_dist = math.abs(xs[1] - x)
  local cur_point = 1
  for i = 2, 4 do
    local cur_dist = math.abs(xs[i] - x)
    if cur_dist <= min_dist then
      if cur_dist == min_dist then
        cur_point = cur_point + 0.5
      else
        min_dist = cur_dist
        cur_point = i
      end
    end
  end
  return cur_point
end

function ADSR:handleMouseClick(x, y, button, is_double)
  local left, right = self.left, self.left + self.width
  local top, bottom = self.top, self.top + self.height
  local all_ok = x > left and x < right and y > top and y < bottom
  if all_ok then
    local x_shift, y_shift = x - left, y - top
    self:onClick(x_shift, y_shift, button)
    -- self.movepoint_num = self:findClosest(self:toNormalCoords(x_shift, y_shift))
    -- if is_double then
    --   print("double click")
    -- end
  end
  self.mouseCaptured = true
  return self
end

function ADSR:onClick(x, y, button)
  local closest = self:findClosest(x)
  self.movepoint_num = closest
  return self
end

function ADSR:handleMouseMove(x, y, dx, dy)
  local max_stage_length = self.max_stage_length
  local point_num = self.movepoint_num
  if point_num == 1.5 then
    if dx < 0 and self.decay == 0 then
      point_num = 1
    end
  end
  local function check_bounds(value)
    if value > max_stage_length then
      value = max_stage_length
    elseif value < 0 then
      value = 0
    end
    return value
  end
  local left, top = self.left, self.top
  local x_shift, y_shift = x - left, y - top
  local a, d, s, r = self:getScreenXs() -- luacheck: ignore
  if point_num == 1.5 then
    if x_shift < a then
      point_num = 1
    else
      point_num = 2
    end
  end
  self.movepoint_num = point_num
  if point_num == 1 then
    self.attack = check_bounds(x_shift * max_stage_length * 4 / self.width)
  elseif point_num == 2 then
    self.decay = check_bounds((x_shift - a) * max_stage_length * 4 / self.width)
  elseif point_num == 3 then
    local sustain = 1 - y_shift/self.height
    if sustain < 0 then
      sustain = 0
    elseif sustain > 1 then
      sustain = 1
    end
    self.sustain = sustain
  elseif point_num == 4 then
    self.release = check_bounds((x_shift - s) * max_stage_length * 4 / self.width)
  end
end

function ADSR:handleMouseRelease()
  self.movepoint_num = nil
end

return ADSR
