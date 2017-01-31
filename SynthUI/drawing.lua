-- local colors = {} -- colors stack
local canvases = {love.graphics.getCanvas()} -- the canvas stack

return {
  newCanvas = function(width, height)
    return love.graphics.newCanvas(width, height, "rgba8", 10)
  end,

  drawCanvas = function(cnv, x, y)
    love.graphics.draw(cnv, x, y)
  end,

  pushCanvas = function(cnv)
    table.insert(canvases, cnv)
    love.graphics.setCanvas(cnv)
  end,

  popCanvas = function()
    local removed = table.remove(canvases, #canvases)
    love.graphics.setCanvas(canvases[#canvases])
    return removed
  end,

  drawRect = function(x, y, w, h, color, mode)
    mode = mode or "fill"
    local old_color = {love.graphics.getColor()}
    love.graphics.setColor(color)
    love.graphics.rectangle(mode, x, y, w, h)
    love.graphics.setColor(old_color)
  end,

  drawLine = function(x1, y1, x2, y2, color)
    local old_color = {love.graphics.getColor()}
    love.graphics.setColor(color)
    love.graphics.line(x1, y1, x2, y2)
    love.graphics.setColor(old_color)
  end,

  drawCircle = function(x, y, radius, color)
    local old_color = {love.graphics.getColor()}
    love.graphics.setColor(color)
    love.graphics.circle("fill", x, y, radius, 20)
    love.graphics.setColor(old_color)
  end,

  drawText = function(x, y, color, text)
    local old_color = {love.graphics.getColor()}
    love.graphics.setColor(color)
    love.graphics.print(text, x, y)
    love.graphics.setColor(old_color)
  end,
}
