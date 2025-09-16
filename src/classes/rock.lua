
rock = {}
rock.__index = rock

function rock.new(settings)
    local self = setmetatable({}, rock)

    self.x = settings.x or 0
    self.y = settings.y or 0
    self.z = settings.z or 0
    self.size = settings.size or 1

    self.color = {(math.random(1,256)/256)-0.5,(math.random(1,256)/256)-0.5,(math.random(1,256)/256)-0.5}
    self.model = model.new({color = self.color, x=self.x,y=self.y,z=self.z, file = "./src/models/ball.obj", size = self.size})


    return self
end

function rock:move(x, y, z)
    self.x = self.x+x
    self.y = self.y+y
    self.z = self.z+z
    self.model:setPos(self.x,self.y,self.z)
    self.model:update()
end

function rock:draw()
    if (Player:getDistance(self.x,self.y,self.z) < 200) then
        self.model:draw()
    else
        if (Player:getDistance(self.x,self.y,self.z) < 800) then
            love.graphics.setColor(self.color)
            drawPoint(self.x,self.y,self.z, 2)
        end
    end

    love.graphics.setColor(1,1,1)
end