require "utils"
require "classes.classes"

function love.load()
    math.randomseed(os.clock())
    screenWidth, screenHeight = love.graphics.getDimensions()
    spaceSize = 200

    -- Create stars with random positions
    stars = {}
    for i = 0, 200 do
        stars[i] = {
            x = math.random(-spaceSize, spaceSize),
            y = math.random(-spaceSize, spaceSize),
            z = math.random(-spaceSize, spaceSize)
        }
    end

    -- Initialize objects using the model class
    objects = {
        [0] = model.new({
            color = {0.5, -0.2, -0.2},
            x = 0, y = 0, z = 0,
            file = "./src/models/skull.obj",
            size = 16
        }),
    }
    objectsEnabled = true

    Player = player.new()      -- Create the player
    mouseLock = false          -- Controls whether the mouse is locked
    FaceAmount = 0             -- Stores number of faces on screen
end

function love.keypressed(key)
    if key == "escape" then
        mouseLock = false
        love.mouse.setRelativeMode(false)
        love.mouse.setPosition(screenWidth / 2, screenHeight / 2)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        mouseLock = true
        love.mouse.setRelativeMode(true)
        love.mouse.setPosition(screenWidth / 2, screenHeight / 2)
    end
end

function love.wheelmoved(x, y)
    if y ~= 0 then
        local delta = love.keyboard.isDown("e") and 1 or 0.1
        Player.speed = Player.speed + (y > 0 and delta or -delta)
    end
end

function love.update(dt)
    Player:update(dt)

    if objectsEnabled then
        for i = 0, #objects do
            objects[i]:update()
        end
    end
end

function love.draw()
    FaceAmount = 0
    love.graphics.setColor(1, 1, 1)

    -- Draw world-space cube
    local s = spaceSize
    drawLine(-s, -s, -s,  s, -s, -s)
    drawLine(-s, -s, -s, -s,  s, -s)
    drawLine( s, -s, -s,  s,  s, -s)
    drawLine(-s,  s, -s,  s,  s, -s)
    drawLine( s,  s,  s, -s,  s,  s)
    drawLine( s,  s,  s,  s, -s,  s)
    drawLine(-s,  s,  s, -s, -s,  s)
    drawLine( s, -s,  s, -s, -s,  s)
    drawLine(-s, -s, -s, -s, -s,  s)
    drawLine( s,  s,  s,  s,  s, -s)
    drawLine(-s,  s, -s, -s,  s,  s)
    drawLine( s, -s,  s,  s, -s, -s)

    -- Draw stars
    for i = 0, #stars do
        drawPoint(stars[i].x, stars[i].y, stars[i].z, 1)
    end

    -- Gather objects to draw
    local drawNear = {}
    if objectsEnabled then
        for i = 0, #objects do
            table.insert(drawNear, objects[i])
        end
    end

    -- Sort objects by distance to player
    table.sort(drawNear, function(a, b)
        return Player:getDistance(a.x, a.y, a.z) > Player:getDistance(b.x, b.y, b.z)
    end)

    -- Merge all triangles for drawing
    local triangles = {}
    for _, obj in ipairs(drawNear) do
        obj:draw()
        table.move(obj.Triangles, 1, #obj.Triangles, #triangles + 1, triangles)
    end

    -- Sort triangles by average Z
    table.sort(triangles, function(a, b) return a.avg_z > b.avg_z end)

    -- Draw triangles
    for _, tri in ipairs(triangles) do
        if tri.Clip1 > Player.nearClipPlane
           and tri.Clip2 > Player.nearClipPlane
           and tri.Clip3 > Player.nearClipPlane then
            love.graphics.setColor(tri.color)
            love.graphics.polygon("fill", tri.X1, tri.Y1, tri.X2, tri.Y2, tri.X3, tri.Y3)
            FaceAmount = FaceAmount + 1
        end
    end

    -- Draw HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS())
    love.graphics.print("X Y Z: " .. math.floor(Player.x) .. "," .. math.floor(Player.y) .. "," .. math.floor(Player.z), 0, 20)
    love.graphics.print("Speed: " .. Player.speed, 0, 40)
    love.graphics.print("FaceAmount: " .. FaceAmount, 0, 60)
end
