Win = Object:extend()

Win.width = 50
Win.height = 50
Win.body_type = "static"
Win.fixed_rotation = true

function Win:new(world, x, y)
  self.x = x
  self.y = y

  self.ox, self.oy = self.width/2, self.height/2

  self.body = world:newRectangleCollider(self.x, self.y, self.width, self.height)
  self.body:setCollisionClass(COLL_CLASS.WIN)
  self.body:setFixedRotation(self.fixed_rotation)
  self.body:setType(self.body_type)

  self.body:setObject(self)
end

function Win:update(dt)
end

function Win:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("fill", self.body:getX() - self.ox, self.body:getY() - self.oy, self.width, self.height)
end