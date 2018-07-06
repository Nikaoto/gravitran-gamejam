Box = Object:extend()

Box.sprite = love.graphics.newImage("res/box.png")
Box.width = 50
Box.height = 50
Box.mass = 5
Box.restitution = 0
Box.linear_damping = 3
Box.angular_damping = 0.9
Box.fixed_rotation = false

function Box:new(world, x, y, restitution)
  self.x = x
  self.y = y
  self.restitution = restitution or Box.restitution
  self.sx = self.width / self.sprite:getWidth()
  self.sy = self.height / self.sprite:getHeight()
  self.ox, self.oy = self.width/2 / self.sx, self.height/2 / self.sy
  self.sprite:setFilter("nearest")

  self.body = world:newRectangleCollider(self.x, self.y, self.width, self.height)
  self.body:setCollisionClass(COLL_CLASS.BOX)
  self.body:setMass(self.mass)
  self.body:setLinearDamping(self.linear_damping)
  self.body:setAngularDamping(self.angular_damping)
  self.body:setRestitution(self.restitution)
  self.body:setFixedRotation(self.fixed_rotation)

  self.gravity = {0, 0}

  self.body:setObject(self)
end

function Box:update(dt)
  self:applyGravity()

  if self.body:enter(COLL_CLASS.BLOCK) then
    local vx, vy  = self.body:getLinearVelocity()
    if sq(vx) + sq(vy) < 300 then
      sound.play("collide")
      camera:shake(2, 0.1)

    end
  end
end

function Box:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.sprite, self.body:getX(), self.body:getY(), self.body:getAngle(), self.sx, self.sy, self.ox, self.oy)
end

function Box:applyGravity()
  if not self.dead then
    self.body:applyForce(self.gravity[1] * self.mass, self.gravity[2] * self.mass)
  end
end

function Box:setGravity(x, y)
  self.gravity = {x, y}
end
