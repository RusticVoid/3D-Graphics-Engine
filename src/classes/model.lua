model = {}
model.__index = model

-- Helper to parse a line of floats
function parseFloats(str)
    local result = {}
    for num in str:gmatch("[^%s]+") do
        table.insert(result, tonumber(num))
    end
    return result
end

function model.new(settings)
    local self = setmetatable({}, model)

    -- Position
    self.x, self.y, self.z = settings.x, settings.y, settings.z
    self.oldX, self.oldY, self.oldZ = self.x, self.y, self.z

    -- Model data
    self.model = {}
    self.drawOrder = {}
    self.vectNorms = {}
    self.vectNormOrder = {}
    self.modelFile = settings.file
    self.size = settings.size
    self.color = settings.color or {0,0,0}
    self.invert = settings.invert or false
    self.faceColor = {}

    -- Read model file once
    local file = io.open(self.modelFile, "r")
    if not file then error("Failed to open file: "..self.modelFile) end

    for line in file:lines() do
        if line:sub(1,2) == "v " then
            -- Vertex
            local vert = parseFloats(line:sub(3))
            vert[1] = vert[1] * self.size + self.x
            vert[2] = -vert[2] * self.size + self.y
            vert[3] = vert[3] * self.size + self.z
            table.insert(self.model, vert)
        elseif line:sub(1,3) == "vn " then
            -- Vertex normal
            local norm = parseFloats(line:sub(4))
            norm[2] = -norm[2]
            table.insert(self.vectNorms, norm)
        elseif line:sub(1,2) == "f " then
            -- Face
            for point in line:sub(3):gmatch("%S+") do
                local v, vt, vn = point:match("(%d+)/?(%d*)/?(%d*)")
                table.insert(self.drawOrder, tonumber(v))
                table.insert(self.vectNormOrder, tonumber(vn))
            end
        end
    end
    file:close()

    -- Assign face colors
    for i = 1, #self.drawOrder, 3 do
        local normIndex = self.vectNormOrder[i]
        if self.vectNorms[normIndex] then
            local n = self.vectNorms[normIndex]
            self.faceColor[i] = {
                (n[1]+1)/2 + self.color[1],
                (n[1]+1)/2 + self.color[2],
                (n[1]+1)/2 + self.color[3],
            }
        else
            print("BAD FACE!")
            self.faceColor[i] = {1,0,0}
        end
    end

    return self
end

-- Movement
function model:move(x, y, z)
    self.x = self.x + x
    self.y = self.y + y
    self.z = self.z + z
end

function model:setPos(x, y, z)
    self.x, self.y, self.z = x, y, z
end

-- Update vertex positions if model moved
function model:update()
    if self.oldX ~= self.x or self.oldY ~= self.y or self.oldZ ~= self.z then
        local dx, dy, dz = self.oldX - self.x, self.oldY - self.y, self.oldZ - self.z
        for _, vert in ipairs(self.model) do
            vert[1] = vert[1] + dx
            vert[2] = vert[2] + dy
            vert[3] = vert[3] + dz
        end
        self.oldX, self.oldY, self.oldZ = self.x, self.y, self.z
    end
end

-- Draw model
function model:draw()
    self.Triangles = {}

    for i = 1, #self.drawOrder, 3 do
        local v1 = self.model[self.drawOrder[i]]
        local v2 = self.model[self.drawOrder[i+1]]
        local v3 = self.model[self.drawOrder[i+2]]

        -- Compute two edge vectors of the triangle
        local ux, uy, uz = v2[1]-v1[1], v2[2]-v1[2], v2[3]-v1[3]
        local vx, vy, vz = v3[1]-v1[1], v3[2]-v1[2], v3[3]-v1[3]

        -- Triangle normal using cross product
        local nx = uy*vz - uz*vy
        local ny = uz*vx - ux*vz
        local nz = ux*vy - uy*vx

        -- Vector from triangle to camera (player)
        local camX, camY, camZ = Player.x - v1[1], Player.y - v1[2], Player.z - v1[3]

        -- Dot product of normal and camera vector
        local dot = nx*camX + ny*camY + nz*camZ

        if self.invert == false then
            if dot >= 0 then
                goto continue
            end
        else
            if dot <= 0 then
                goto continue
            end
        end
        

        -- Project vertices
        local X1, Y1, Z1 = project(v1[1], v1[2], v1[3])
        local X2, Y2, Z2 = project(v2[1], v2[2], v2[3])
        local X3, Y3, Z3 = project(v3[1], v3[2], v3[3])

        local avg_x, avg_y, avg_z = project(
            (v1[1]+v2[1]+v3[1])/3,
            (v1[2]+v2[2]+v3[2])/3,
            (v1[3]+v2[3]+v3[3])/3
        )

        -- Add triangle to list
        self.Triangles[#self.Triangles+1] = {
            Clip1 = Z1,
            Clip2 = Z2,
            Clip3 = Z3,

            avg_x = avg_x,
            avg_y = avg_y,
            avg_z = avg_z,

            X1 = (X1/Z1)*Player.fl + screenWidth/2,
            Y1 = (Y1/Z1)*Player.fl + screenHeight/2,
            X2 = (X2/Z2)*Player.fl + screenWidth/2,
            Y2 = (Y2/Z2)*Player.fl + screenHeight/2,
            X3 = (X3/Z3)*Player.fl + screenWidth/2,
            Y3 = (Y3/Z3)*Player.fl + screenHeight/2,

            color = self.faceColor[i]
        }

        ::continue::
    end
end
