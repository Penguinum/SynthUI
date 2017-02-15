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

--выводит список точек
function PolylineEdit:point_list()
  print("============")
  for i=1,#self.points do
    print("index=",i)
    print("x=",self.points[i][1])
    print("y=",self.points[i][2])
  end
end

--обновляет точки в массиве в зависимости от условий
--1-добавляет новую точку если её нет
--2-удаляет точку если она есть
--3-максимальное сближение точек 0.05 по нормализованной шкале
--4-все значения устредняются до сотых 0.00
function PolylineEdit:point_update(mouse_x,mouse_y)
  --получаем координаты виджета
  local x_min = PolylineEdit.parameters.left.value
  local x_max = PolylineEdit.parameters.width.value + x_min
  print(x_max)
  local y_min = PolylineEdit.parameters.top.value
  local y_max = PolylineEdit.parameters.height.value + y_min
  local y_old,x_old
  --убираем из координат курсора координаты основного окна
  if  mouse_y > y_min and mouse_y < y_max and
    mouse_x > x_min and mouse_x < x_max then
    mouse_x =  x_max - mouse_x
    mouse_y =  y_max - mouse_y
  end
  --нормализуем значения для отрисовки
  function toNormalCoords(sx, sy)
    local w, h = PolylineEdit.parameters.width.value, PolylineEdit.parameters.height.value
    return sy / w, 1 - sx / h
  end
  x_old,y_old = mouse_x,mouse_y--сохраняем изначальные координаты для проверки
  mouse_x,mouse_y = toNormalCoords(mouse_x,mouse_y)
  --усредняем значения до сотых
  function toNormalFloatingNumber(x,y,normal)
    x , y = x*normal, y*normal
    x , y = math.floor(x),math.floor(y)
    x , y = x/normal, y/normal
    return x,y
  end
  mouse_x,mouse_y = toNormalFloatingNumber(mouse_x,mouse_y,100)
  --проверяем есть ли на данных координатах точка
  --1-если да указываем что точка для удаления
  --2-если нет то указываем что точка для отрисовки
  local npoint = nil -- будет ли добавлена или удалена точка?
  local ppoint  --позиция удаляемой точки
  for i=1, #self.points do
    if self.points[i][1] < mouse_y+0.05  and self.points[i][1] >  mouse_y-0.05  and
      self.points[i][2] < mouse_x+0.05  and self.points[i][2] >  mouse_x-0.05  then
      npoint = false
      ppoint = i
      break
    else
      npoint = true
    end
  end
  --если такой точки нет то запоминаем её
  if npoint == true then
    print("новая позиция",mouse_x,mouse_y)--#debug
    --сначала найдём ближайшую с лева
    function findNeighbor()
      local neighbor --позиция ближайшего соседа по оси x
      for i =1,#self.points do
        if self.points[i][1] < mouse_y then
          neighbor = i
        end
      end
      print("зафиксировн индекс",neighbor)
      return neighbor
    end
    local neighbor = findNeighbor()
    --при занесении в общий массив сдвигаем новую точку
    --правее от найденного ближайшего соседа с лева
    if x_old < x_max and y_old < y_max then -- игнорируем обработку за границей виджета
      table.insert(self.points,neighbor+1 ,{mouse_y,mouse_x})
      print("вставлен в нидекс",neighbor+1) --#debug
    end
    return
    --если есть то удаляем
  elseif npoint == false    then
    print("точка уже существует",ppoint)--#debug
    --если точек две значит это неудаляемые точки
    if #self.points ~= 2 then
      table.remove(self.points,ppoint)
    end
    return
  end
end
----------------------------------------------------------------------
--передвигает точку между двумя соседними
--позиция перемещения ограничена с лева и с права соседними точками
--в соотвецтвии требования отсуцтвия точек на одной горизонтальной оси
--static - значения координат после одиночного клика
--dyn    - изменённые значения позиции после клика
npoint_move = false   --есть ли точка под курсором
ppoint_move = false   --позиция в массиве точки под курсором

function PolylineEdit:point_move(static_x,static_y,dyn_x,dyn_y)

  --получаем координаты виджета
  local x_min = PolylineEdit.parameters.left.value
  local x_max = PolylineEdit.parameters.width.value + x_min
  local y_min = PolylineEdit.parameters.top.value
  local y_max = PolylineEdit.parameters.height.value + y_min

  --убираем из координат курсора координаты основного окна
  if  static_y > y_min and static_y < y_max and
    static_x > x_min and static_x < x_max then
    static_x =  x_max - static_x
    static_y =  y_max - static_y
  else--если клик вне границ то просто выходим ничего не делая
    print("выход за границы виджета")--#debug
    return
  end

  --нормализуем значения для отрисовки
  function toNormalCoords(sx, sy)
    local w, h = PolylineEdit.parameters.width.value, PolylineEdit.parameters.height.value
    return sy / w, 1 - sx / h
  end

  static_x,static_y = toNormalCoords(static_x,static_y)
  --усредняем значения до сотых
  function toNormalFloatingNumber(x,y,normal)
    x , y = x*normal, y*normal
    x , y = math.floor(x),math.floor(y)
    x , y = x/normal, y/normal
    return x,y
  end
  static_x,static_y = toNormalFloatingNumber(static_x,static_y,100)

  --проверяем есть ли под указателем точка
  for i=1,#self.points do
    if  self.points[i][1] < static_y+0.05  and self.points[i][1] >  static_y-0.05  and
      self.points[i][2] < static_x+0.05  and self.points[i][2] >  static_x-0.05  then
      npoint_move = true
      ppoint_move = i
      break
    end
  end

  --если точка по курсором есть то устанавливаем границы перемещения
  --и обрабатываем динамические значения позиции курсора для установки новых значений
  if npoint_move == true and ppoint_move ~= false then

    local max_left,max_right = self.points[ppoint_move-1][1],self.points[ppoint_move+1][1]
    print("минимальная позиция",max_left)--#debug
    print("максимальная позиция",max_right)--#debug

    dyn_x,dyn_y = toNormalCoords(dyn_y,dyn_x)
    print("новая позиция=>",dyn_x,dyn_y)--#debug
    print("STATUS",npoint_move,ppoint_move)--#debug
    if dyn_x > max_left and dyn_x < max_right  and dyn_y >= 0 then

      dyn_y,dyn_x = toNormalFloatingNumber(dyn_y,dyn_x,100)
      self.points[ppoint_move][1]=dyn_x
      self.points[ppoint_move][2]=dyn_y
    end
  end
end

------------------------------------
local click_timerate = 0
local click_interval = 0.2
local single = false
local double = false
local static_x,static_y = nil

--устанавливает или удаляет точку
--по двойному клику
function PolylineEdit:point_handler()
  function love.mousepressed(x,y)
    local time = os.clock()
    if time - click_timerate <= click_interval then
      PolylineEdit:point_update(x,y)
      single = false
      double = true
    else
      click_timerate = time
      print("single")
      single = true
      double = false
      --запоминаем положение курсора при клике
      static_x,static_y = x,y
    end
  end

  --позиция курсора любой момент времени
  local dyn_x = love.mouse.getX()
  local dyn_y = love.mouse.getY()
  --узнаём осталась ли левая кнопка мыши нажатой
  down = love.mouse.isDown(1)
  --если кнопка опущена то и клика нет
  if down == false then single = false end
  --устанавливаем задержку, убеждаясь что клик действительно одиночный
  if os.clock() > (click_timerate + click_interval/4) then
    if down == true  and single == true  and double == false then
      print(down,single)--#debug
      print(dyn_x,dyn_y)--#debug
      print("static",static_x,static_y)--#debug
      PolylineEdit:point_move(static_x,static_y,dyn_x,dyn_y)
    end
  end
end


---------------------------------

function PolylineEdit:draw()

  local old_canvas = love.graphics.getCanvas()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()
  PolylineEdit.parameters.left.value = self.left
  PolylineEdit.parameters.top.value = self.top
  PolylineEdit.parameters.width.value = self.width
  PolylineEdit.parameters.height.value = self.height
  local x, y, w, h = self.left, self.top, self.width, self.height
  drawing.drawRect(0, 0, w, h, self.backgroundColor, "fill")
  drawing.drawRect(0, 0, w, h, self.outlineColor, "line")
  self:point_handler()--обработка нажатий перед конечной отрисовкой
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
  love.graphics.setCanvas(old_canvas)
  love.graphics.draw(self.canvas, x, y)
  return self
end
--[[
function PolylineEdit:toNormalCoords(sx, sy)
  local w, h = self.width, self.height
  return sx / w, 1 - sy / h
end
--]]
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
    points = {{0.0,0.0},{1.0,0.0}}
  }
  setmetatable(cbox, PolylineEdit):initDefaults()
  --rgba8 called Error: SynthUI/PolylineEdit.lua:84: Invalid texture format: rgba8
  cbox.canvas = love.graphics.newCanvas(cbox.width, cbox.height, "srgb", 10)
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
