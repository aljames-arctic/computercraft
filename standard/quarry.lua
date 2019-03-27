local self = {}
local state = dofile("/apis/state")
local turtle = dofile("/apis/turtle")
local pmemory = dofile("/apis/pmemory")

self.debug = false
self.name = "Quarry.exe"
self.running = true

-- State Machine
local UNINITIALIZED = 0   -- done
local BURROW = 1          -- done
local DIG_FORWARD = 2     -- done
local TURN = 3            -- done
local LAYER_END = 6       -- done
local END_PROGRAM = 7     -- done
local RETURN_FUEL = 8
local RETURN_INVENTORY = 9
local RETURN_JOB = 10

local HOME_FACE = 2
local home = turtle.position()
local init_state_variables = { home=home }
local state_variables = nil

local function gohome()
  turtle.go({"z:"..home.z, "x:"..home.x, "y:"..home.y, "f:"..HOME_FACE} )
end

local function return_fuel()
  gohome()

  term.setCursorPos(5,1)
  print("Waiting on a resupply of fuel")
  while( turtle.getFuelLevel() < 5000 )
    turtle.refuel(64)
    sleep(10)
  end

  state.set(RETURN_JOB)
end

local function return_inventory()
  gohome()

  for i = 1, 16, 1 do
    local attempt = 0
    while turtle.getItemCount > 0 and turtle.drop() == false then
      term.setCursorPos(5,1)
      attempt += 1
      print("Inventory full... attempt #"..attempt)
      sleep(10)
    end
  end

  state.set(RETURN_JOB)
end

local function return_job()
  turtle.to({"x:"..state_variables.saved_pos.x, "y:"..state_variables.saved_pos.y, "z:"..state_variables.saved_pos.z, "f:"..state_variables.saved_f}, true)
  state.set( state_variables.last_action )
end

local function fuel_low()
  local pos = turtle.position()
  distance = math.abs(home.x-pos.x) + math.abs(home.y-pos.y) + math.abs(home.z-pos.z)
  return ( turtle.getFuelLevel() <= distance )
end

local function inventory_full()
  return ( turtle.getItemCount(16) > 0 )
end

local function end_program()
  gohome()

  self.running = false
end

local function force_return()
  local position = turtle.position()

  if fuel_low() then
    state_variables.last_action = state.get()
    state_variables.saved_pos = turtle.position()
    state_variables.saved_f = turtle.facing()
    pmemory.write("state_variables", state_variables, "table")
    state.set(RETURN_FUEL)
    return true
  elseif inventory_full() then
    state_variables.last_action = state.get()
    state_variables.saved_pos = turtle.position()
    state_variables.saved_f = turtle.facing()
    pmemory.write("state_variables", state_variables, "table")
    state.set(RETURN_INVENTORY)
    return true
  end

  return false
end

local function layer_end()
  turtle.turn("left")
  turtle.turn("left")
  state.set(BURROW)
end

local function turn()
  if state_variables.turn_count == 1 or state_variables.turn_count == 3 then
    turtle.move("forward")
    -- NOTE!!! UNsaved_pos STATE
  end

  if state_variables.turn_count < 2 then
    turtle.turn("right")
  else
    turtle.turn("left")
  end

  state_variables.turn_count = (state_variables.turn_count + 1) % 4
  pmemory.write( "state_variables", state_variables, "table" )

  if state_variables.turn_count == 2 or state_variables.turn_count == 0 then
    state.set(DIG_FORWARD)
  end
end

local function dig_forward()
  local position = turtle.position()
  local facing = turtle.facing()

  row_dist = math.abs(position.x - home.x)
  start_dist = position.y - home.y
  end_dist = nil
  increment = nil

  if facing == 0 then
    end_dist = state_variables.diameter - 1
    increment = 1
  else
    end_dist = 0
    increment = -1
  end

  for dig=start_dist, end_dist, increment do
    if force_return() then
      return
    end

    turtle.dig("up")
    turtle.dig("down")
    if dig ~= end_dist then
      turtle.dig("forward")
      turtle.move("forward")
    end
  end

  if row_dist == diameter then
    state.set(LAYER_END)
  else
    state.set(TURN)
  end
end

local function burrow()
  local position = turtle.position()
  local z_dist = math.abs(position.z - home.z)
  local burrow_again = ( z_dist % 3 ~= 0 ) 

  if force_return() then
    return
  end

  -- burrowing further ends the program (might leave a layer or 2 undone)
  if z_dist + 1 > state_variables.depth then
    state.set(END_PROGRAM)
    return
  end

  if burrow_again then
    turtle.dig("down")
    turtle.move("down")
  else
    state.set(DIG_FORWARD)
  end
end

local function prompt_param()
  write("Insert a diameter: ")
  local diameter = tonumber( read() )
  write("Insert a depth: ")
  local depth = tonumber( read() )

  state_variables.diameter = diameter
  state_variables.depth = depth
  state_variables.home = turtle.position()
  pmemory.write("state_variables", state_variables, "table")
  state.set(BURROW)
end

-- State Machine Functions
local state_action = 
{
  [PROMPT_PARAM] = function prompt_param() end,
  [BURROW] = function() burrow() end,
  [DIG_FORWARD] = function() dig_forward() end,
  [TURN] = function() turn() end,
  [LAYER_END] = function() layer_end() end,
  [END_PROGRAM] = function() end_program() end,
  [RETURN_FUEL] = function() return_fuel() end,
  [RETURN_INVENTORY] = function() return_inventory() end,
  [RETURN_JOB] = function() return_job() end,
}

-- actual task to be run
function self.run()
  state.initialize()
  if state.curr == UNINITIALIZED then
    turtle.initialize()
    pmemory.remove("state_variables") -- delete then re-add
    pmemory.add("state_variables")    -- to reset state
    pmemory.write("state_variables", init_state_variables, "table") -- initialize
    state.set(PROMPT_PARAM)
  end

  -- initialize internal state variables
  state_variables = pmemory.read("state_variables", "table")
  home = state_variables.home
  while self.running do state_action[state.curr]() end

  state.finalize()
end

return self