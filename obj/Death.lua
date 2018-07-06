Death = Object:extend()

Death.sprite = love.graphics.newImage("res/box.png")
Death.width = 25
Death.height = 25
Death.body_type = "static"
Death.fixed_rotation = true

function Death:new(world, x, y)
  self.x = x
  self.y = y
  self.sx = self.width / self.sprite:getWidth()
  self.sy = self.height / self.sprite:getHeight()
  self.ox, self.oy = self.width/2 / self.sx, self.height/2 / self.sy
  self.sprite:setFilter("nearest")


  self.body = world:newRectangleCollider(self.x, self.y, self.width, self.height)
  self.body:setCollisionClass(COLL_CLASS.DEATH)
  self.body:setFixedRotation(self.fixed_rotation)
  self.body:setType(self.body_type)

  self.body:setObject(self)
end

function Death:draw()
  love.graphics.setColor(1, 0, 0)
  love.graphics.draw(self.sprite, self.body:getX(), self.body:getY(), self.body:getAngle(), self.sx, self.sy, self.ox, self.oy)
  love.graphics.setColor(1, 0, 0, 0.3)
  love.graphics.circle("fill", self.body:getX(), self.body:getY(), 30)
  love.graphics.setColor(1, 1, 1)
end