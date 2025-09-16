player = {}
player.__index = player

function player.new()
    local self = setmetatable({}, player)
    self.x = 0
    self.y = 0
    self.z = 0
    self.speed = 0.1
    self.rotX = 0
    self.rotY = 0
    self.rotSpeed = 0.1
    self.nearClipPlane = 0.001
    self.fl = 400
    self.sinX = math.sin(self.rotX)
    self.cosX = math.cos(self.rotX)
    self.sinY = math.sin(self.rotY)
    self.cosY = math.cos(self.rotY)
    self.vx = 0
    self.vy = 0
    self.vz = 0
    self.friction = 5
    return self
end

function player:update(dt)
    self.sinX = math.sin(self.rotX)
    self.cosX = math.cos(self.rotX)
    self.sinY = math.sin(self.rotY)
    self.cosY = math.cos(self.rotY)

    Player.vx = ((Player.vx + (btn(love.keyboard.isDown("w"))-btn(love.keyboard.isDown("s"))) * Player.speed * dt) * (1 - math.min(dt * Player.friction, 1)))
    Player.vz = ((Player.vz + (btn(love.keyboard.isDown("d"))-btn(love.keyboard.isDown("a"))) * Player.speed * dt) * (1 - math.min(dt * Player.friction, 1)))
    Player.vy = (Player.vy + (btn(love.keyboard.isDown("lshift"))-btn(love.keyboard.isDown("space"))) * Player.speed * dt) * (1 - math.min(dt * Player.friction, 1))

    self.x = self.x+Player.vx*-self.sinX
    self.z = self.z+Player.vx*self.cosX
    self.x = self.x+Player.vz*self.cosX
    self.z = self.z+Player.vz*self.sinX

    self.y = self.y+Player.vy

    if (not (love.mouse.getX() == love.graphics.getWidth()/2)) or (not (love.mouse.getY() == love.graphics.getHeight()/2)) then
        if mouseLock == true then
            self.rotX = self.rotX-((self.rotSpeed-((love.graphics.getWidth()/2)-love.mouse.getX()))*dt)
            self.rotY = self.rotY-((self.rotSpeed+((love.graphics.getHeight()/2)-love.mouse.getY()))*dt)
            love.mouse.setPosition(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
        end
    end

    if self.rotY < math.rad(-90) then
        self.rotY = math.rad(-90)
    end
    if self.rotY > math.rad(90) then
        self.rotY = math.rad(90)
    end
end

function player:getDistance(x1,y1,z1)
    return getDistance(self.x,self.y,self.z, x1,y1,z1)
end
