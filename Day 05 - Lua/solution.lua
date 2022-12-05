function fileExists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
  end

function linesFrom(file)
  if not fileExists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

function splitByChunk(text, chunkSize)
    local s = {}
    for i=1, #text, chunkSize do
        s[#s+1] = text:sub(i,i+chunkSize - 1)
    end
    return s
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local file = 'input.txt'
local lines = linesFrom(file)

length = string.len(lines[1])
lanes = {}

-- Create empty lanes
for i=1,length/4 do
  lanes[i] = {}
end

-- Populate lanes
startFrom = 0
for k,v in pairs(lines) do
    -- Check if lane numbering has started
    if string.find(v, "%d") then 
        startFrom = k + 2
        break 
    end
    laneContents = splitByChunk(v, 4)
    for laneNo,match in pairs(laneContents) do
        item = match:sub(2, 2)
        if item ~= " " then
            table.insert(lanes[laneNo], 1, item)
        end
    end
end

-- Deepcopy for solution 2
lanesFast = deepcopy(lanes)

-- Move crates
for k,v in pairs(lines) do
    if k >= startFrom then
        local t = {}
        for i in v:gmatch("%d+") do  
            t[#t + 1] = i
        end 
        amountMove = tonumber(t[1])
        startIndex = #lanes[fromMove]-amountMove+1

        fromLane = lanes[tonumber(t[2])]
        toLane = lanes[tonumber(t[3])]
        fromLaneFast = lanesFast[tonumber(t[2])]
        toLaneFast = lanesFast[tonumber(t[3])]
        for _=1,amountMove do
            table.insert(toLane, fromLane[#fromLane])
            table.insert(toLaneFast, fromLaneFast[startIndex])
            table.remove(fromLane, #fromLane)
            table.remove(fromLaneFast, startIndex)
        end
    end
end

io.write("Solution 1: ")
for k,v in pairs(lanes) do
    io.write( v[#v] )
end
print()

io.write("Solution 2: ")
for k,v in pairs(lanesFast) do
    io.write( v[#v] )
end
print()
