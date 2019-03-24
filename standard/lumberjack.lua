local self = {}
local state = dofile("/apis/state")
local turtle = dofile("/apis/turtle")

self.debug = false
self.name = "Lumberjack.exe"
self.running = true
local SAPLING_SLOT = 16

-- Utility Functionality --
local logs = 
{ 
    ["minecraft:log"] = true,
    ["BiomesOPlenty:logs1"] = true
}
local function isLog(dir)
  local item = nil

  if dir == "front" then _, item = turtle.inspect()
  elseif dir == "up" then _, item = turtle.inspectUp()
  end

  if logs[item.name] then
    return true
  elseif item.name ~= nil and self.debug then
    print("Found <"..item.name.."> if this is a log add to loglist")
    return false
  end
end

-- State Machine
local UNINITIALIZED = 0
local WAITING_ON_TREE = 1
local TREE_HAS_GROWN = 2
local FELLING_TREE = 3
local RETURN_TO_GROUND = 4
local PLANTING_SAPLING = 5
local END_PROGRAM = 6

-- State Machine Functions
local function waiting_on_tree()
  turtle.suck() -- continue to suck any saplings from previous tree
  
  -- check if a tree has grown, otherwise fill up fuel
  if isLog("front") then 
    state.set(TREE_HAS_GROWN)
  else  -- turn right to check for more trees
    turtle.turnRight()
    sleep(10)
    if turtle.getFuelLevel() < 100 then
      turtle.selectFuel()
      turtle.refuel(10)
    end
  end
end

local function tree_has_grown()
  turtle.dig()            -- chop the tree
  turtle.move("forward")  -- move forward
  state.set(FELLING_TREE) -- dig upward until no tree
end

local function felling_tree()
  -- chopping upward
  while isLog("up") do
    turtle.digUp()
    turtle.move("up")
  end
  state.set(RETURN_TO_GROUND)
end

local function return_to_ground()
  if state.curr == RETURN_TO_GROUND then
    -- move back to initial location
    turtle.to({"z:" .. 0, "x:" .. 0, "y:" .. 0, "f:" .. turtle.facing()})
    state.set(PLANTING_SAPLING)
  end
end

local sapling =
{
  ["minecraft:sapling"] = true,
  ["BiomesOPlenty:saplings"] = true
}
local function planting_sapling()
  -- plant new tree
  for i = 1, 4 do 
    turtle.select(SAPLING_SLOT)
    turtle.place()
    turtle.turnRight()
  end


  _, item = turtle.inspect()
  if sapling[item.name] then
    state.set(WAITING_ON_TREE)
    return
  end
  
  if item.name ~= nil and self.debug then -- if the item we placed is not a sapling
    print("Out of saplings, placed <"..item.name.."> instead -- Ending program")
  elseif self.debug then 
    print("Out of saplings, load more into slot "..SAPLING_SLOT)
  end
  state.set(END_PROGRAM)
end

local function end_program()
  -- no saplings left
  self.running = false
end

local state_action = 
{
  [WAITING_ON_TREE] = function() waiting_on_tree() end,
  [TREE_HAS_GROWN] = function() tree_has_grown() end,
  [FELLING_TREE] = function() felling_tree() end,
  [RETURN_TO_GROUND] = function() return_to_ground() end,
  [PLANTING_SAPLING] = function() planting_sapling() end,
  [END_PROGRAM] = function() end_program() end,
}

-- actual task to be run
function self.run()
  state.initialize()
  if state.curr == UNINITIALIZED then
    turtle.initialize()
    state.set(WAITING_ON_TREE)
  end

  while self.running do state_action[state.curr]() end

  state.finalize()
end

return self