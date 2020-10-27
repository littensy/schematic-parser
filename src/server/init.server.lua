
local SCHEM_LAYER = "##Layer"
local SCHEM_LAYER_END = "##End"

local replicatedStorage = game:GetService("ReplicatedStorage")


local function Decode(schematic)

    local tbl = {}

    local chunk, layer

    for token in schematic:gmatch("[^\n\r]+") do

        -- Schematic chunk:
        if (not chunk and token:find("##") == 1) then
            chunk = { name = token:sub(3) }
            table.insert(tbl, chunk)
            continue
        end

        -- Layers:
        if (token:sub(1, 7) == SCHEM_LAYER) then
            layer = { id = token:sub(9) }
            continue

        elseif (token:sub(1, 5) == SCHEM_LAYER_END) then
            table.insert(chunk, layer)
            continue
        end

        -- Layer rows:
        if (chunk and layer) then
            table.insert(layer, token:split(" "))
        end

    end

    return table.unpack(tbl)

end


local function PlaceBlock(id, x, y, z, parent)
    if (id > "0") then
        local block = replicatedStorage.Blocks[1]:Clone() -- Blocks[id]
        block.CFrame = CFrame.new(x*5, y*5, z*5)
        block.Parent = parent
        return block
    end
end


local function Parse(chunk)
    local folder = Instance.new("Folder")
    for y, layer in ipairs(chunk) do
        for z, row in ipairs(layer) do
            for x, blockId in ipairs(row) do
                PlaceBlock(blockId, x, y, z, folder)
            end
        end
    end
    folder.Parent = workspace
end


local str = require(script.Parent.ModuleScript)

local start = os.clock()
Parse(Decode(str))
print((os.clock() - start) * 1000)