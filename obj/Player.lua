Player = Object:extend()

Player.sprite = love.graphics.newImage("res/player.png")
Player.eye_sprite = love.graphics.newImage("res/eye.png")
Player.eye_width = 14
Player.eye_height = 10
Player.width = 40
Player.height = 60
Player.run_speed = 1200
Player.default_speed = 280
Player.speed = 280
Player.jump_impulse = 1500
Player.mass = 250
Player.restitution = 0.15
Player.linear_damping = 5
Player.fixed_rotation = true
Player.gravity_mult = 3900
Player.tp_mult = 30 -- teleport mult between levels

Player.feet_width = Player.width * 0.7
Player.feet_height = Player.height * 0.25

function Player:new(world, x, y, setGravityCallback)
  self.x = x
  self.y = y
  self.sx = self.width / self.sprite:getWidth()
  self.sy = self.height / self.sprite:getHeight()
  self.ox, self.oy = self.width/2 / self.sx, self.height/2 / self.sy
  self.direction = -1

  self.eye_sx = self.eye_width / self.eye_sprite:getWidth()
  self.eye_sy = self.eye_height / self.eye_sprite:getHeight()

  self.setGravityCallback = setGravityCallback

  self.body = world:newRectangleCollider(self.x, self.y, self.width, self.height)
  self.body:setCollisionClass(COLL_CLASS.PLAYER)
  self.body:setMass(self.mass)
  self.body:setLinearDamping(self.linear_damping)
  self.body:setRestitution(self.restitution)
  self.body:setFixedRotation(self.fixed_rotation)

  self.feet = world:newRectangleCollider(0, 0, self.feet_width, self.feet_height)
  self.feet:setCollisionClass(COLL_CLASS.PLAYER_FEET)
  self.feet:setMass(0)
  self.feet:setFixedRotation(true)

  self.jumping = true
  self.land = nil -- current object on which the player stands

  self.eye_timer = Timer()

  self.float_timer = Timer()
  self.max_float_y = 4
  self.float_y = self.max_float_y
  self.float = function(self) 
    self.float_timer:tween(1, self, {float_y = -self.float_y}, "in-out-sine", function() 
      self:float() 
    end) 
  end

  self.float_timer:tween(1, self, {float_y = -self.float_y}, "in-out-sine", function()
    self:float()
  end)


  local offx = 8
  local offy = 5
  local x = self.body:getX()
  local y = self.body:getY() + self.float_y - self.max_float_y
  local dest_ex = -self.eye_width/2 + lume.clamp(gravity[1], -1, 1) * offx
  local dest_ey = -self.height*0.36 - self.eye_height/2 + lume.clamp(gravity[2], -1, 1) * offy
  self.ex = dest_ex
  self.ey = dest_ey

  self.body:setObject(self)
end

function Player:update(dt)
  self.float_timer:update(dt)
  self.eye_timer:update(dt)
  self:udpateControls(dt)
  self:updateFeet(dt)
  self:applyGravity(0, self.gravity_mult)

  -- Finish collision
  if self.body:enter(COLL_CLASS.FINISH) then
    sound.play("finish")
    local finish = self.body:getEnterCollisionData(COLL_CLASS.FINISH).collider
    local tx = finish:getObject().tp[1] or ((self.body:getX() + self.width/2) + 30 )
    local ty = finish:getObject().tp[2] or ((self.body:getY() - self.height/2) - 10)
    tx, ty = math.ceil(tx) * self.tp_mult, math.ceil(ty) * self.tp_mult
    respawn_x = self.body:getX() - self.width/2 + tx
    respawn_y = self.body:getY() - self.height/2 + ty
    initWorld()
    player = Player(world, respawn_x, respawn_y, setGravity)
  end

  -- Death collision
  if self.body:enter(COLL_CLASS.DEATH) then
    sound.play("death")
    camera:shake(25, 0.35)
    initWorld()
    player = Player(world, respawn_x, respawn_y, setGravity)
  end

  -- Apple collision
  if self.body:enter(COLL_CLASS.WIN) then
    sound.play("win")
    game_won = true
  end
end

function Player:udpateControls(dt)
  local dx = 0

  if love.keyboard.isDown("lshift") then
    self.speed = self.run_speed
  else
    self.speed = self.default_speed
  end

  if love.keyboard.isDown("a") then
    self.direction = 1
    dx = -self.speed
  end

  if love.keyboard.isDown("d") then
    self.direction = -1
    dx = self.speed
  end

  --local _, vy = self.body:getLinearVelocity()
  self.body:applyLinearImpulse(dx, 0)
end

function Player:updateFeet(dt)
  local x, y = self.body:getPosition()
  self.feet:setPosition(x, y + self.height/2)

  lume.each({COLL_CLASS.BLOCK, COLL_CLASS.BOX, COLL_CLASS.WALL}, function(class)
    if self.feet:enter(class) then
      self.land = self.feet:getEnterCollisionData(class).collider
      self.jumping = false
    end
  end)
end

function Player:draw()
  love.graphics.setColor(1, 1, 1)
  local x = self.body:getX()
  local y = self.body:getY() + self.float_y - self.max_float_y
  love.graphics.draw(self.sprite, x, y, 0, self.sx * self.direction, self.sy, self.ox, self.oy)

  -- Eye
  --love.graphics.setColor(0.5, 0.2, 0.6, 0.2)
  love.graphics.setColor(1, 1, 1, 0.25)
  love.graphics.circle("fill", x + self.ex + self.eye_width/2, y + self.ey + self.eye_height/2, 10)
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.eye_sprite, x + self.ex, y + self.ey, 0, self.eye_sx, self.eye_sy)
end

function Player:jump()
  sound.play("jump")
  self.jumping = true
  local f = -self.jump_impulse * self.body:getMass()
  self.body:applyLinearImpulse(0, f)

  if self.land then
    if self.knock_on_jump then
      self.land:applyLinearImpulse(0, -f*0.9)
    end
  end
end

function Player:applyGravity(x, y)
  self.body:applyForce(x, y * self.body:getMass())
end

function Player:keyPressed(k)
  if k == "w" then
    if not self.jumping then
      self:jump()
    end
  end

  if k == "left" then
    self.knock_on_jump = true
    self:setGlobalGravity(-1, 0)
    self:eyeTween()
  end

  if k == "right" then
    self.knock_on_jump = true
    self:setGlobalGravity(1, 0)
    self:eyeTween()
  end

  if k == "up" then
    self.knock_on_jump = true
    self:setGlobalGravity(0, -1)
    self:eyeTween()
  end

  if k == "down" then
    self.knock_on_jump = false
    self:setGlobalGravity(0, 1)
    self:eyeTween()
  end
end

function Player:eyeTween()
  local offx = 6
  local offy = 5
  local x = self.body:getX()
  local y = self.body:getY() + self.float_y - self.max_float_y
  local dest_ex = -self.eye_width/2 + lume.clamp(gravity[1], -1, 1) * offx
  local dest_ey = -self.height*0.36 - self.eye_height/2 + lume.clamp(gravity[2], -1, 1) * offy
  self.eye_timer:tween(0.3, self, {ex = dest_ex, ey = dest_ey}, "out-cubic")
end

function Player:setGlobalGravity(x, y)
  if self.setGravityCallback then
    self.setGravityCallback(x, y)
    sound.play("trans")
  end
end

function Player:getX() return self.body:getX() end
function Player:getY() return self.body:getY() end