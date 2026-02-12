require "utils"
require "classes.classes"

function love.load()
    math.randomseed(os.clock())
    screenWidth, screenHeight = love.graphics.getDimensions()

    spaceSize = 200

    -- This creates the stars and gives them a random position
    stars = {}
    for i = 0, 200 do
        stars[i] = {}
        stars[i].x = math.random(-spaceSize, spaceSize)
        stars[i].y = math.random(-spaceSize, spaceSize)
        stars[i].z = math.random(-spaceSize, spaceSize)
    end

    -- This creates the rocks and gives them a random position and size.
    -- rocks = {}
    -- for i = 0, 200 do
    --     rocks[i] = rock.new({
    --         x = math.random(-spaceSize, spaceSize),
    --         y = math.random(-spaceSize, spaceSize),
    --         z = math.random(-spaceSize, spaceSize),
    --         size = math.random(5, 20)/20
    --     })
    -- end


    FaceAmount = 0 -- This stores the amount of faces on the screen

    -- This inits the objects using the model class
    objects = {}
    objects[0] = model.new({color={0.5,-0.2,-0.2}, x=0,y=0,z=0, file = "./src/models/monkey.obj", size = 16})
    objectsEnabled = true -- This is a debug to disable these objects

    Player = player.new() -- This creates the player

    mouseLock = false -- Controls weather or not to lock the mouse
end

function love.keypressed(key)
    -- When pressing escape the mouse will unlock and be set to the center of the screen
    if key == "escape" then
        mouseLock = false
        love.mouse.setRelativeMode(false)
        love.mouse.setPosition(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    end
end

function love.mousepressed(x, y, button)
    -- When left clicking on the screen the mouse will lock in the screen
    if button == 1 then
        mouseLock = true
        love.mouse.setRelativeMode(true)
        love.mouse.setPosition(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    end
end

function love.wheelmoved(x, y)
    -- When pressing E and scrolling the mouse whell the player will go up or down
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
    -- This updates the player
    Player:update(dt)

    -- If objects are enabled update them
    if objectsEnabled == true then
        for i = 0, #objects do
            objects[i]:update()
        end
    end
end

function love.draw()
    -- This resets the FaceAmount var to 0 so we can get the correct amount of faces on the screen
    FaceAmount = 0 
    love.graphics.setColor(1,1,1)

    -- This draws the cube around the world space
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

    -- This will loop through all the stars and draw them.
    for i = 0, #stars do
        love.graphics.setColor(1,1,1)
        drawPoint(stars[i].x,stars[i].y,stars[i].z, 1)
    end

    drawNear = {}
    -- This will gather the rocks distances to determine wether to draw them or not
    -- for i = 0, #rocks do
    --     if (Player:getDistance(rocks[i].x,rocks[i].y,rocks[i].z) < 800) then
    --         drawNear[#drawNear+1] = rocks[i]
    --     end
    -- end

    -- If objects are enabled, add them to the drawNear list
    if objectsEnabled == true then
        for i = 0, #objects do
            drawNear[#drawNear+1] = objects[i]
        end
    end
    
    -- This sorts the objects to determine there draw order based on the players distance to them
    table.sort(drawNear, function(a, b)
        return Player:getDistance(a.x,a.y,a.z) > Player:getDistance(b.x,b.y,b.z)
    end)

    -- This will merge all the objects faces / triangles into one list
    triangles = {}
    for i = 1, #drawNear do
        drawNear[i]:draw()
        table.move(drawNear[i].Triangles, 1, #drawNear[i].Triangles, #triangles + 1, triangles)
    end

    -- This sorts the all the merges faces / triangles to the correct draw order
    table.sort(triangles, function(a, b)
        return a.avg_z > b.avg_z
    end)

    -- This draws all the faces / trianglestrigangles
    for i = 1, #triangles, 1 do
        if (triangles[i].Clip1 > Player.nearClipPlane)
        and (triangles[i].Clip2 > Player.nearClipPlane)
        and (triangles[i].Clip3 > Player.nearClipPlane) then
            love.graphics.setColor(triangles[i].color)
            love.graphics.polygon("fill", triangles[i].X1, triangles[i].Y1, triangles[i].X2, triangles[i].Y2, triangles[i].X3, triangles[i].Y3)
            FaceAmount = FaceAmount + 1
        end
    end

    -- This chunk of code prints info to the screen
    love.graphics.setColor(1,1,1)
    love.graphics.print("FPS:"..love.timer.getFPS())
    love.graphics.print("X Y Z: "..math.floor(Player.x)..","..math.floor(Player.y)..","..math.floor(Player.z), 0, 20)
    love.graphics.print("Speed: "..Player.speed, 0, 40)
    love.graphics.print("FaceAmount: "..FaceAmount, 0, 60)
end