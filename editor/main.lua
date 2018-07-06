package.path = package.path .. ";../?.lua"

json = require "../lib/json"
lume = require "../lib/lume"

OBJ = {
  BOX = { ID = "box", WIDTH = 50, HEIGHT = 50, COLOR = {0.647, 0.408, 0.165}, DRAW = function(inst)
    love.graphics.setColor(OBJ.BOX.COLOR)
    love.graphics.rectangle("line", inst[1], inst[2], OBJ.BOX.WIDTH, OBJ.BOX.HEIGHT)
    drawEraseDist(inst[1], inst[2])
  end},
  PLAYER = { ID = "player", WIDTH = 40, HEIGHT = 60, COLOR = {1, 1, 1}, DRAW = function(inst)
    love.graphics.setColor(OBJ.PLAYER.COLOR)
    love.graphics.rectangle("line", inst[1], inst[2], OBJ.PLAYER.WIDTH, OBJ.PLAYER.HEIGHT)
    drawEraseDist(inst[1], inst[2])
  end},
  BLOCK = { ID = "block", WIDTH = 50, HEIGHT = 50, COLOR = {0, 0, 1}, DRAW = function(inst)
    love.graphics.setColor(OBJ.BLOCK.COLOR)
    love.graphics.rectangle("line", inst[1], inst[2], OBJ.BLOCK.WIDTH, OBJ.BLOCK.HEIGHT)
    drawEraseDist(inst[1], inst[2])
  end},
  FINISH = { ID = "finish", WIDTH = 25, HEIGHT = 25, COLOR = {0, 1, 0}, DRAW = function(inst)
    love.graphics.setColor(OBJ.FINISH.COLOR)
    love.graphics.rectangle("line", inst[1], inst[2], OBJ.FINISH.WIDTH, OBJ.FINISH.HEIGHT)
    if inst[3] and inst[4] then
      love.graphics.setColor(0, 1, 1)
      local w, h = OBJ.FINISH.WIDTH/2, OBJ.FINISH.HEIGHT/2
      love.graphics.circle("fill", inst[1] + w + w * inst[3], inst[2] + h + h * inst[4], 3)
    end
    drawEraseDist(inst[1], inst[2])
  end},
  DEATH = { ID = "death", WIDTH = 25, HEIGHT = 25, COLOR = {1, 0, 0}, DRAW = function(inst)
    love.graphics.setColor(OBJ.DEATH.COLOR)
    love.graphics.rectangle("line", inst[1], inst[2], OBJ.DEATH.WIDTH, OBJ.DEATH.HEIGHT)
    drawEraseDist(inst[1], inst[2])
  end},
  APPLE = { ID = "apple", WIDTH = 30, HEIGHT = 30, COLOR = {0.2, 0.8, 0.2}, DRAW = function(inst)
    love.graphics.setColor(OBJ.APPLE.COLOR)
    love.graphics.rectangle("fill", inst[1], inst[2], OBJ.APPLE.WIDTH, OBJ.APPLE.HEIGHT)
    drawEraseDist(inst[1], inst[2])
  end},
  WIN = { ID = "win", WIDTH = 30, HEIGHT = 30, COLOR = {1, 1, 0.5}, DRAW = function(inst)
    love.graphics.setColor(OBJ.WIN.COLOR)
    love.graphics.rectangle("fill", inst[1], inst[2], OBJ.WIN.WIDTH, OBJ.WIN.HEIGHT)
    drawEraseDist(inst[1], inst[2])
  end}
}

EDIT_MODE = true
level_name = "level"
level_index = 0
extension = ".json"
previous_text = ""
last_x, last_y = 0, 0
delete_mode = false
w, h = 1366, 768
view_x, view_y = 0, 0
function getWorldCoords(x, y) return -view_x + x, -view_y + y end

erase_distance = 18
function drawEraseDist(x, y)
  love.graphics.setColor(1, 1, 0)
  love.graphics.circle("line", x, y, erase_distance)
end

saved = false
changes_made = false
current_object = OBJ.BOX
level = {}

current_finish_direction = math.pi

function fileExists(path)
  local f = io.open(path, "rb")
  if f then f:close() end
  return f ~= nil
end

function readFile(path)
  local ret = ""
  local file = io.open(path, "r")
  if file then
    ret = file:read()
    file:close()
    return ret
  end
  print("File at "..path.." not found!")
  file:close()
  return nil
end

function saveFile()
  -- Clear file
  file:close()
  file = io.open(level_name..level_index..extension, "w+")
  -- Write to file
  io.output(file)
  io.write(json.encode(level))
  changes_made = false
  saved = true
end

function love.load()
  love.window.setMode(w, h, { fullscreen = true })

  if EDIT_MODE and fileExists(level_name..level_index..extension) then
    local path = level_name..level_index..extension
    previous_text = readFile(path)
    level = json.decode(previous_text)
    file = io.open(path, "w+")
  else
    while fileExists(level_name..level_index..extension) do
      level_index = level_index + 1
    end
    file = io.open(level_name..level_index..extension, "w+")
  end

  io.output(file)
end

function love.update(dt)
  if love.keyboard.isDown("space") then
    local x, y = love.mouse.getPosition()
    view_x, view_y = view_x + (w/2 - x)*0.1, view_y + (h/2 - y)*0.1
  end
end

function love.draw()
  -- Ui
  love.graphics.setColor(1, 1, 1)
  love.graphics.circle("fill", w/2, h/2, 8)
  love.graphics.print(level_name..level_index..extension)
  if delete_mode then
    love.graphics.print("\nDELETE MODE")
  end

  -- View
  love.graphics.translate(view_x, view_y)

  -- Level objects
  for _, O in pairs(OBJ) do
    if level[O.ID] then
      for _, obj in pairs(level[O.ID]) do
        O.DRAW(obj)
      end
    end
  end
end

function love.mousepressed(x, y, b)
  if b == 1 then
    if not delete_mode then
      placeObject(current_object.ID, x, y)
    else
      -- Delete/Remove objet
      local x, y = getWorldCoords(x, y)
      local rem = {}
      for i, obj_group in pairs(level) do
        for j, obj in pairs(obj_group) do
          if lume.distance(x, y, obj[1], obj[2]) < erase_distance then
            table.insert(rem, {i = i, j = j })
            last_x, last_y = level[i][j][1], level[i][j][2]
          end
        end
      end

      for _, v in pairs(rem) do
        table.remove(level[v.i], v.j)
        changes_made = true
        saved = false
      end
    end
  end

  -- Move view
  if b == 2 then
    view_x, view_y = view_x + w/2 - x, view_y + h/2 - y
  end
end

function placeObject(obj_id, x, y, is_world)
  local is_world = is_world or false
  local x, y = x, y
  if not is_world then
    x, y = getWorldCoords(x, y)
  end
  if not level[obj_id] then
    level[obj_id] = {}
  end

  table.insert(level[obj_id], newObject(obj_id, x, y))
  changes_made = true
  saved = false
  last_x, last_y = x, y
end

-- Returns lua table from object id
function newObject(id, x, y)
  if id == "finish" then
    local tpx, tpy = 0, 0
    if current_finish_direction == math.pi/2 then
      tpx, tpy = -1, 0
    elseif current_finish_direction == math.pi then
      tpx, tpy = 0, -1
    elseif current_finish_direction == math.pi*3/2 then
      tpx, tpy = 1, 0  
    elseif current_finish_direction == math.pi*2 then
      tpx, tpy = 0, 1  
    end
    return {x, y, tpx, tpy}
  end
  return {x, y}
end

function love.keypressed(k)
  if k == "escape" then
    if previous_text ~= "" and not saved then
      io.write(previous_text)
    end

    io.close(file)
    love.event.quit()
  end

  -- Player
  if k == "p" then
    current_object = OBJ.PLAYER
  end

  -- Box
  if k == "b" then
    current_object = OBJ.BOX
  end

  -- Block
  if k == "l" then
    current_object = OBJ.BLOCK
  end

  -- Finish
  if k == "f" then
    current_object = OBJ.FINISH
    current_finish_direction = current_finish_direction + math.pi/2
    if current_finish_direction > math.pi*2 then
      current_finish_direction = math.pi/2
    end
  end

  -- Death
  if k == "d" then
    current_object = OBJ.DEATH
  end

  -- Apple
  if k == "a" then
    current_object = OBJ.APPLE
  end

  -- Apple
  if k == "w" then
    current_object = OBJ.WIN
  end

  if k == "x" then
    delete_mode = not delete_mode
  end

  -- Clone block in direction
  if k == "left" then
    placeObject(current_object.ID, last_x - current_object.WIDTH, last_y, true)
  end

  if k == "right" then
    placeObject(current_object.ID, last_x + current_object.WIDTH, last_y, true)
  end

  if k == "up" then
    placeObject(current_object.ID, last_x, last_y - current_object.HEIGHT, true)
  end

  if k == "down" then
    placeObject(current_object.ID, last_x, last_y + current_object.HEIGHT, true)
  end

  -- Save
  if k == "s" then
    saveFile()
  end
end