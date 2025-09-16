require "utils"
require "classes.classes"

function love.load()
    math.randomseed(os.clock())
    screenWidth, screenHeight = love.graphics.getDimensions()

    spaceSize = 200

    stars = {}
    for i = 0, 200 do
        stars[i] = {}
        stars[i].x = math.random(-spaceSize, spaceSize)
        stars[i].y = math.random(-spaceSize, spaceSize)
        stars[i].z = math.random(-spaceSize, spaceSize)
    end

    rocks = {}
    for i = 0, 200 do
        rocks[i] = rock.new({
            x = math.random(-spaceSize, spaceSize),
            y = math.random(-spaceSize, spaceSize),
            z = math.random(-spaceSize, spaceSize),
            size = math.random(5, 20)/20
        })
    end

    FaceAmount = 0
    objects = {}
    objects[0] = model.new({x=0,y=0,z=0, file = "./src/models/skull.obj", size = 1})
    objects[1] = model.new({x=4,y=0,z=0, file = "./src/models/monkey.obj", size = 1})
    objectsEnabled = true

    Player = player.new()

    mouseLock = false
end

function love.keypressed(key)
    if key == "escape" then
        mouseLock = false
        love.mouse.setRelativeMode(false)
        love.mouse.setPosition(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        mouseLock = true
        love.mouse.setRelativeMode(true)
        love.mouse.setPosition(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    end
end

function love.wheelmoved(x, y)
    if y > 0 then
        if love.keyboard.isDown("e") then
            Player.speed = Player.speed + 1
        else
            Player.speed = Player.speed + 0.1
        end
    elseif y < 0 then
        if love.keyboard.isDown("e") then
            Player.speed = Player.speed - 1
        else
            Player.speed = Player.speed - 0.1
        end
    end
end

function love.update(dt)
    Player:update(dt)
    if objectsEnabled == true then
        for i = 0, #objects do
            objects[i]:update()
        end
    end
end

function love.draw()
    FaceAmount = 0
    love.graphics.setColor(1,1,1)
    drawLine(-spaceSize,-spaceSize,-spaceSize,  spaceSize,-spaceSize,-spaceSize)
    drawLine(-spaceSize,-spaceSize,-spaceSize, -spaceSize, spaceSize,-spaceSize)
    drawLine( spaceSize,-spaceSize,-spaceSize,  spaceSize, spaceSize,-spaceSize)
    drawLine(-spaceSize, spaceSize,-spaceSize,  spaceSize, spaceSize,-spaceSize)
    drawLine( spaceSize, spaceSize, spaceSize, -spaceSize, spaceSize, spaceSize)
    drawLine( spaceSize, spaceSize, spaceSize,  spaceSize,-spaceSize, spaceSize)
    drawLine(-spaceSize, spaceSize, spaceSize, -spaceSize,-spaceSize, spaceSize)
    drawLine( spaceSize,-spaceSize, spaceSize, -spaceSize,-spaceSize, spaceSize)
    drawLine(-spaceSize,-spaceSize,-spaceSize, -spaceSize,-spaceSize, spaceSize)
    drawLine( spaceSize, spaceSize, spaceSize,  spaceSize, spaceSize,-spaceSize)
    drawLine(-spaceSize, spaceSize,-spaceSize, -spaceSize, spaceSize, spaceSize)
    drawLine( spaceSize,-spaceSize, spaceSize,  spaceSize,-spaceSize,-spaceSize)

    for i = 0, #stars do
        love.graphics.setColor(1,1,1)
        drawPoint(stars[i].x,stars[i].y,stars[i].z, 1)
    end

    drawNear = {}
    for i = 0, #rocks do
        if (Player:getDistance(rocks[i].x,rocks[i].y,rocks[i].z) < 800) then
            drawNear[#drawNear+1] = rocks[i]
        end
    end

    if objectsEnabled == true then
        for i = 0, #objects do
            drawNear[#drawNear+1] = objects[i]
        end
    end
    
    table.sort(drawNear, function(a, b)
        return Player:getDistance(a.x,a.y,a.z) > Player:getDistance(b.x,b.y,b.z)
    end)

    for i = 1, #drawNear do
        drawNear[i]:draw()
    end

    love.graphics.setColor(1,1,1)
    love.graphics.print("FPS:"..love.timer.getFPS())
    love.graphics.print("X Y Z: "..math.floor(Player.x)..","..math.floor(Player.y)..","..math.floor(Player.z), 0, 20)
    love.graphics.print("Speed: "..Player.speed, 0, 40)
    love.graphics.print("FaceAmount: "..FaceAmount, 0, 60)
end