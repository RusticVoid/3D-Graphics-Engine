model = {}
model.__index = model

function model.new(settings)
    local self = setmetatable({}, model)

    self.x = settings.x
    self.y = settings.y
    self.z = settings.z
    self.oldX = self.x
    self.oldY = self.y
    self.oldZ = self.z

    self.model = {}
    self.drawOrder = {}
    self.vectNorms = {}
    self.vectNormOrder = {}
    self.modelFile = settings.file
    self.size = settings.size

    self.file = io.open(self.modelFile, "r")
    for line in self.file:lines() do
        local char = line:sub(1, 2)
        if char == "v " then
            local axis = 1
            local vert = {}
            vert[axis] = ""
            for i = 3, #line do
                if (line:sub(i, i) == " ") or (i == #line) then
                    vert[axis] = tonumber(vert[axis])*self.size
                    if axis+1 > 3 then
                        vert[2] = -vert[2]

                        vert[1] = vert[1] + self.x
                        vert[2] = vert[2] + self.y
                        vert[3] = vert[3] + self.z

                        self.model[#self.model+1] = vert
                        break
                    end
                    axis = axis+1
                    vert[axis] = ""
                else
                    vert[axis] = vert[axis]..line:sub(i, i)
                end
            end
        end
    end

    self.file = io.open(self.modelFile, "r")
    for line in self.file:lines() do
        local char = line:sub(1, 3)
        if char == "vn " then
            local axis = 1
            local vertNormal = {}
            vertNormal[axis] = ""
            for i = 4, #line do
                if (line:sub(i, i) == " ") or (i == #line) then
                    if (i == #line) then
                        vertNormal[axis] = vertNormal[axis]..line:sub(i, i)
                    end
                    vertNormal[axis] = tonumber(vertNormal[axis])--*self.size
                    if axis+1 > 3 then
                        vertNormal[2] = -vertNormal[2]
                        self.vectNorms[#self.vectNorms+1] = vertNormal
                        break
                    end
                    axis = axis+1
                    vertNormal[axis] = ""
                else
                    vertNormal[axis] = vertNormal[axis]..line:sub(i, i)
                end
            end
        end
    end

    self.file = io.open(self.modelFile, "r")
    for line in self.file:lines() do
        local char = line:sub(1, 2)
        if char == "f " then
            local point = ""
            for i = 3, #line do
                if (line:sub(i, i) == " ") or (i == #line) then
                    if i == #line then
                        point = point..line:sub(i, i)
                    end
                    if not (point == "") then
                        local Vpoint = ""
                        local VTpoint = ""
                        local VNpoint = ""
                        for j = 1, #point do
                            if (point:sub(j, j) == "/") then
                                for k = j+1, #point do
                                    if (point:sub(k, k) == "/") then
                                        for l = k+1, #point do
                                            if ((line:sub(l, l) == " ") or (l == #point)) then
                                                if (l == #point) then
                                                    VNpoint = VNpoint..point:sub(l, l)
                                                end
                                                if VNpoint == "" then
                                                    VNpoint = VNpoint..point:sub(l, l)
                                                end
                                                break
                                            else
                                                VNpoint = VNpoint..point:sub(l, l)
                                            end
                                        end
                                        break
                                    else
                                        VTpoint = VTpoint..point:sub(k, k)
                                    end
                                end
                                break
                            else
                                Vpoint = Vpoint..point:sub(j, j)
                            end
                        end

                        self.drawOrder[#self.drawOrder+1] = tonumber(Vpoint)
                        self.vectNormOrder[#self.vectNormOrder+1] = tonumber(VNpoint)
                        
                        
                        point = ""
                    end
                else
                    point = point..line:sub(i, i)
                end
            end
        end
    end

    self.color = settings.color or {0,0,0}

    self.faceColor = {}
    for i = 1, #self.drawOrder, 3 do
        if not (self.vectNorms[self.vectNormOrder[i]] == nil) then
                self.faceColor[i] = {
                ((self.vectNorms[self.vectNormOrder[i]][1]+1)/2)+self.color[1],
                ((self.vectNorms[self.vectNormOrder[i]][1]+1)/2)+self.color[2],
                ((self.vectNorms[self.vectNormOrder[i]][1]+1)/2)+self.color[3]
            }
        else
            print("BAD FACE!")
            self.faceColor[i] = {1,0,0}
        end
    end

    return self
end

function model:move(x, y, z)
    self.x = self.x+x
    self.y = self.y+y
    self.z = self.z+z
end
function model:setPos(x, y, z)
    self.x = x
    self.y = y
    self.z = z
end

function model:update()
    if ((not (self.oldX == self.x)) or (not (self.oldY == self.y)) or (not (self.oldX == self.x))) then
        for i = 1, #self.model do
            self.model[i][1] = self.model[i][1]+(self.oldX-self.x)
            self.model[i][2] = self.model[i][2]+(self.oldY-self.y)
            self.model[i][3] = self.model[i][3]+(self.oldZ-self.z)
        end
        self.oldX = self.x
        self.oldY = self.y
        self.oldZ = self.z
    end
end

function model:draw()
    self.Triangles = {}

    for i = 1, #self.drawOrder, 3 do
        local X1, Y1, Z1 = project(self.model[self.drawOrder[i]][1],self.model[self.drawOrder[i]][2],self.model[self.drawOrder[i]][3])
        local X2, Y2, Z2 = project(self.model[self.drawOrder[i+1]][1],self.model[self.drawOrder[i+1]][2],self.model[self.drawOrder[i+1]][3])
        local X3, Y3, Z3 = project(self.model[self.drawOrder[i+2]][1],self.model[self.drawOrder[i+2]][2],self.model[self.drawOrder[i+2]][3])
        
        local avg_x, avg_y, avg_z = project(
            (self.model[self.drawOrder[i]][1] + self.model[self.drawOrder[i+1]][1] + self.model[self.drawOrder[i+2]][1]) / 3,
            (self.model[self.drawOrder[i]][2] + self.model[self.drawOrder[i+1]][2] + self.model[self.drawOrder[i+2]][2]) / 3, 
            (self.model[self.drawOrder[i]][3] + self.model[self.drawOrder[i+1]][3] + self.model[self.drawOrder[i+2]][3]) / 3
        )

        self.Triangles[#self.Triangles+1] = {
            Clip1 = Z1,
            Clip2 = Z2,
            Clip3 = Z3,

            avg_x = avg_x,
            avg_y = avg_y,
            avg_z = avg_z,
            
            X1 = ((X1/Z1)*Player.fl)+(screenWidth/2),
            Y1 = ((Y1/Z1)*Player.fl)+(screenHeight/2),

            X2 = ((X2/Z2)*Player.fl)+(screenWidth/2),
            Y2 = ((Y2/Z2)*Player.fl)+(screenHeight/2),
            
            X3 = ((X3/Z3)*Player.fl)+(screenWidth/2),
            Y3 = ((Y3/Z3)*Player.fl)+(screenHeight/2),

            color = self.faceColor[i]
        }
    end

    table.sort(self.Triangles, function(a, b)
        return a.avg_z > b.avg_z
    end)

    for i = 1, #self.Triangles, 1 do
        if (self.Triangles[i].Clip1 > Player.nearClipPlane) 
        and (self.Triangles[i].Clip2 > Player.nearClipPlane) 
        and (self.Triangles[i].Clip3 > Player.nearClipPlane) then
            love.graphics.setColor(self.Triangles[i].color)
            love.graphics.polygon("fill", self.Triangles[i].X1, self.Triangles[i].Y1, self.Triangles[i].X2, self.Triangles[i].Y2, self.Triangles[i].X3, self.Triangles[i].Y3)
            FaceAmount = FaceAmount + 1
        end
    end
end