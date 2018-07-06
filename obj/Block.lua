Block = Object:extend()

Block.sprite = love.graphics.newImage("res/block.png")
Block.width = 50
Block.height = 50
Block.body_type = "static"
Block.fixed_rotation = true

function Block:new(world, x, y)
  self.x = x
  self.y = y

  self.sx = self.width / self.sprite:getWidth()
  self.sy = self.height / self.sprite:getHeight()
  self.ox, self.oy = self.width/2 / self.sx, self.height/2 / self.sy
  self.sprite:setFilter("nearest")

  self.body = world:newRectangleCollider(self.x, self.y, self.width, self.height)
  self.body:setCollisionClass(COLL_CLASS.BLOCK)
  self.body:setFixedRotation(self.fixed_rotation)
  self.body:setType(self.body_type)

  self.body:setObject(self)
end

function Block:update(dt)
end

function Block:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.sprite, self.body:getX(), self.body:getY(), 0, self.sx, self.sy, self.ox, self.oy)
end