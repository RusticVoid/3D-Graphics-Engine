function project(X, Y, Z)
    local X, Y, Z = X-Player.x, Y-Player.y, Z-(Player.z)
    local X, Y, Z = (Z*Player.sinX)+(X*Player.cosX), Y, (Z*Player.cosX)-(X*Player.sinX)
    local X, Y, Z = X, (Y*Player.cosY)-(Z*Player.sinY), (Y*Player.sinY)+(Z*Player.cosY)
    return X, Y, Z
end

function drawLine(X, Y, Z, X2, Y2, Z2)
    local X, Y, Z = project(X, Y, Z)
    local X2, Y2, Z2 = project(X2, Y2, Z2)

    local clipPercent = 0
    if Z < Player.nearClipPlane then
        clipPercent = (Player.nearClipPlane-Z)/(Z2-Z)
        X, Y, Z = X-((X-X2)*clipPercent), Y-((Y-Y2)*clipPercent), Player.nearClipPlane
    end
    if Z2 < Player.nearClipPlane then
        clipPercent = (Player.nearClipPlane-Z2)/(Z-Z2)
        X2, Y2, Z2 = X2-((X2-X)*clipPercent), Y2-((Y2-Y)*clipPercent), Player.nearClipPlane
    end

    if clipPercent < 1 then
        love.graphics.line(
            ((X/Z)*Player.fl)+(screenWidth/2), ((Y/Z)*Player.fl)+(screenHeight/2),
            ((X2/Z2)*Player.fl)+(screenWidth/2), ((Y2/Z2)*Player.fl)+(screenHeight/2)
        )
    end
end

function drawPoint(X1, Y1, Z1, PS)
    local X, Y, Z = project(X1, Y1, Z1)

    if not (Z < Player.nearClipPlane) then
        love.graphics.setPointSize(PS)
        love.graphics.points(
            ((X/Z)*Player.fl)+(screenWidth/2), ((Y/Z)*Player.fl)+(screenHeight/2)
        )
    end
    love.graphics.setColor(1,1,1)
end

function getDistance(x,y,z, x1,y1,z1)
    return math.sqrt((x - x1)^2 + (y - y1)^2 + (z - z1)^2)
end

function btn(value)
  return value and 1 or 0
end
