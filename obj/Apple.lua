Apple = Object:extend()

Apple.sprite = love.graphics.newImage("res/apple.png")
Apple.width = 30
Apple.height = 30
Apple.body_type = "static"
Apple.fixed_rotation = true

function Apple:new(world, x, y)
  self.x = x
  self.y = y

  self.sx = self.width / self.sprite:getWidth()
  self.sy = self.height / self.sprite:getHeight()
  self.ox, self.oy = self.width/2 / self.sx, self.height/2 / self.sy
  self.sprite:setFilter("nearest")

  self.body = world:newRectangleCollider(self.x, self.y, self.width, self.height)
  self.body:setCollisionClass(COLL_CLASS.APPLE)
  self.body:setFixedRotation(self.fixed_rotation)
  self.body:setType(self.body_type)

  self.picked = false

  self.body:setObject(self)
end

function Apple:update(dt)
  if not self.picked then
    if self.body:enter(COLL_CLASS.PLAYER) then
      self:pick()
    end
  end
end

function Apple:draw()
  if not self.picked then
    love.graphics.setColor(1, 1, 1)
  else
    love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
  end
  love.graphics.draw(self.sprite, self.body:getX(), self.body:getY(), 0, self.sx, self.sy, self.ox, self.oy)
end

function Apple:pick()
  sound.play("apple")
  self.picked = true
end