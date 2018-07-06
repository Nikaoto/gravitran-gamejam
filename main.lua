require "util"
require "conf"
require "sound"

inspect = require "lib/inspect"
json = require "lib/json"
Object = require "lib/classic"
Camera = require "lib/Camera"
wf = require "lib/windfield"
lume = require "lib/lume"
Timer = require "lib/Timer"

-- Objects
require "obj/Player"
require "obj/Block"
require "obj/Box"
require "obj/Finish"
require "obj/Death"
require "obj/Apple"
require "obj/Win"

FULLSCREEN = true

COLL_CLASS = {
  WALL = "WALL_CC",
  PLAYER = "PLAYER_CC",
  PLAYER_FEET = "PLAYER_FEET_CC",
  BLOCK = "BLOCK_CC",
  BOX = "BOX_CC",
  FINISH = "FINISH_CC",
  DEATH = "DEATH_CC",
  APPLE = "APPLE_CC",
  WIN = "WIN_CC"
}

level_index = 0
level_dir = "editor/"
level_extension = ".json"
level = json.decode(readFile(level_dir.."level"..level_index..level_extension))
respawn_x, respawn_y = 0, 0

function loadLevel(index)
  level_index = index
  local path = level_dir.."level"..level_index..level_extension
  if fileExists(path) then
    print("LEVEL LOADED")
    level = json.decode(readFile(path))
  end
end

gravity_mult = 3000
game_won = false

function love.load()
  love.window.setFullscreen(FULLSCREEN)
  love.window.setTitle("Gravitran")
  local w, h = love.graphics.getDimensions()
  math.randomseed(os.time())

  camera = Camera(w/2, h/2, w, h)
  camera:setFollowStyle("SCREEN_BY_SCREEN")
  camera:setFollowLerp(0.4)

  initWorld()

  -- Player
  respawn_x, respawn_y = level["player"][1][1], level["player"][1][2]
  player = Player(world, respawn_x, respawn_y, setGravity)
end

function initWorld()
  local w, h = love.graphics.getDimensions()

  -- World
  objects = {}
  gravity = {0, 0}
  world = wf.newWorld(0, 0, false)

  -- Init collision classes
  world:addCollisionClass(COLL_CLASS.PLAYER_FEET)
  world:addCollisionClass(COLL_CLASS.WALL, { ignores = {COLL_CLASS.PLAYER_FEET} })
  world:addCollisionClass(COLL_CLASS.PLAYER, { ignores = {COLL_CLASS.PLAYER_FEET} })
  world:addCollisionClass(COLL_CLASS.BLOCK, { ignores = {COLL_CLASS.PLAYER_FEET} })
  world:addCollisionClass(COLL_CLASS.BOX, { ignores = {COLL_CLASS.PLAYER_FEET} })
  world:addCollisionClass(COLL_CLASS.FINISH, { ignores = {COLL_CLASS.PLAYER, COLL_CLASS.PLAYER_FEET} })
  world:addCollisionClass(COLL_CLASS.APPLE, { 
    ignores = {COLL_CLASS.PLAYER, COLL_CLASS.PLAYER_FEET, COLL_CLASS.BOX, COLL_CLASS.BLOCK} })
  world:addCollisionClass(COLL_CLASS.WIN, { 
    ignores = {COLL_CLASS.PLAYER, COLL_CLASS.PLAYER_FEET, COLL_CLASS.BOX, COLL_CLASS.BLOCK} })
  world:addCollisionClass(COLL_CLASS.DEATH, { ignores = lume.values(COLL_CLASS) })

  -- Boxes
  for _, box in pairs(level["box"]) do
    table.insert(objects, Box(world, box[1], box[2]))
  end

  -- Blocks
  for _, block in pairs(level["block"]) do
    table.insert(objects, Block(world, block[1], block[2]))
  end

  -- Force fields / Finish
  for _, finish in pairs(level["finish"]) do
    table.insert(objects, Finish(world, finish[1], finish[2], {finish[3], finish[4]}))
  end

  -- Death blocks
  for _, death in pairs(level["death"]) do
    table.insert(objects, Death(world, death[1], death[2]))
  end

  -- Apple blocks
  for _, apple in pairs(level["apple"]) do
    table.insert(objects, Apple(world, apple[1], apple[2]))
  end

  -- Win blocks
  for _, win in pairs(level["win"]) do
    table.insert(objects, Win(world, win[1], win[2]))
  end
end

function setGravity(x, y)
  -- Set global gravity
  gravity = { lume.clamp(x, -1, 1) * gravity_mult, lume.clamp(y, -1, 1) * gravity_mult }

  -- Set gravity of all gravitable objects
  for _, obj in pairs(objects) do
    if obj.setGravity then
      obj:setGravity(gravity[1], gravity[2])
    end
  end
end

function isObjectVisible(obj)
  local w, h = love.graphics.getDimensions()
  return lume.aabb(obj.body:getX() - obj.width/2, obj.body:getY() - obj.height/2, obj.width, obj.height, 
          camera.x - w/2, camera.y - h/2, w, h*1.1)
end

function love.update(dt)
  camera:update(dt)
  camera:follow(player:getX(), player:getY())
  world:update(dt)
  player:update(dt)

  -- Update bodies and remember dead ones for clearing
  local rem = {}
  for i, obj in pairs(objects) do
    if obj.dead then
      table.insert(rem, i)
    elseif obj.update then
      if obj.body and obj.width and obj.height then
        if isObjectVisible(obj) then
          obj:update(dt)
        end
      else
        obj:update(dt)
      end
    end
  end

  -- Clear dead bodies
  for k, v in pairs(rem) do
    table.remove(objects, v)
  end
end

function love.draw()
  if not game_won then
    camera:attach()
    --world:draw()

    for _, obj in pairs(objects) do
      if obj.draw then
        if obj.body then
          if isObjectVisible(obj) then
            obj:draw()
          end
        else
          obj:draw()
        end
      end
    end

    player:draw()
    camera:detach()
    camera:draw()
  else
    local w, h = love.graphics.getDimensions()
    love.graphics.print("WIN", w/2, h/2, 0, 2, 2)
  end
end

function love.keypressed(k)
  if k == "escape" then
    love.event.quit()
  end

  if k == "r" then
    sound.play("reset")
    initWorld()
    player = Player(world, respawn_x, respawn_y, setGravity)
  end

  player:keyPressed(k)
end