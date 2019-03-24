local state = dofile("/apis/state")
local slot16iscobble = dofile("/apis/state")
local turtle = dofile("/apis/turtle")
local pmemory = dofile("/apis/pmemory")

local checkpoint
if pmemory.add("checkpoint") then
  checkpoint = turtle.position()
  checkpoint.f = turtle.facing()
  pmemory.write("checkpoint", checkpoint, "table")
end

if pmemory.add("direction") then pmemory.write("direction","right","string") end
if pmemory.add("row") then pmemory.write("row",0,"number") end

args = {...}
if pmemory.add("diameter") or pmemory.read("diameter","number") == nil then
  if #args ~= 1 then
    print "startup <diameter>"
    print "RECOMMENDED : bucket in inventory slot 1"
    return
  elseif tonumber(args[1]) < 1 then
    print "Requires a positive diameter"
    return
  end
  pmemory.write("diameter", tonumber(args[1]), "number")
end
local diameter = pmemory.read("diameter","number")

-- arg=1 returns true if fuel level <= distance to home
--       returns false otherwise
-- arg=2 returns distance to checkpoint * 2 - fuel level if > 0
--       returns false otherwise
local function require_refuel(n)
  if n == 1 then
    local pos = turtle.position()
    local dist = math.abs(pos.x) + math.abs(pos.y) + math.abs(pos.z) + 10
    if turtle.getFuelLevel() <= dist then
      turtle.selectFuel()
      return not turtle.refuel(1)
    end
    return false

  elseif n == 2 then
    local pos1 = pmemory.read("checkpoint","table")
    local pos2 = turtle.position()
    
    -- calculate distance from current location to the checkpoint
    -- and from the checkpoint back to 0,0,0
    local dist = math.abs(pos1.x-pos2.x) + math.abs(pos1.y-pos2.y) + math.abs(pos1.z-pos2.z)
          dist = dist + math.abs(pos1.x) + math.abs(pos1.y) + math.abs(pos1.z)

    if turtle.getFuelLevel() < dist then
      repeat turtle.refuel(1)
      until not turtle.selectFuel() or turtle.getFuelLevel() >= dist
      if turtle.getFuelLevel() < dist then
        return dist - turtle.getFuelLevel()
      end
    end
    return 0

  end
  return true
end

-- cobblestone goes to slot 16 so just try that
local function cobblestone_full()
  if slot16iscobble.get() == 1 and turtle.getItemCount(16) > 32 then
    turtle.select(16)
    turtle.drop()
    slot16iscobble.set(0)
    turtle.select(2)
  end
end

-- if 16 slots are full then it drops droppables
-- returns true if inventory is full of non-dropables
-- returns false otherwise
local function inventory_full()
  cobblestone_full() -- check if cobblestone is full
  if turtle.emptySlot() then return false end
  if slot16iscobble.get() == 1 then
    turtle.select(16)
    turtle.drop()
    slot16iscobble.set(0)
    turtle.select(2)
  end
  return true
end

-- the turtle is facing chests
-- empty inventory into the chests
-- if the inventory is NOT a chest, return false
-- if the turtle can not unload completely, return false
-- otherwise return true
local function unload_inventory()
  _, item = turtle.inspect()
  if item.name ~= "minecraft:chest" then
    return false
  end

  local retval = true
  local firstfuel = true
  for i=2,16 do -- our first inventory slot is reserved for a bucket
    turtle.select(i)
    if firstfuel and turtle.refuel(0) then
      firstfuel = false
    else
      turtle.drop()
      retval = retval and turtle.getItemCount(i) == 0
    end
  end
  return retval
end

-- mining function
-- check if it is stone/cobblestone 
-- if it is select slot 16
local function mine(dir)
  local _, item = turtle.inspect(dir)
  if item.name == "minecraft:stone" or item.name == "minecraft:cobblestone" then
    turtle.select(16)
    slot16iscobble.set(1)

  elseif item.name == "minecraft:flowing_lava" then
    -- grab your bucket and get some free fuel!
    turtle.select(1)
    turtle.place(dir)
    turtle.refuel(1)

  elseif item.name == "minecraft:bedrock" and dir ~= "down" then
    state.set(5)
    if dir == "up" then
      turtle.move("back",true)
    end
  end
    
  return turtle.dig(dir)
end

local function task()
  while true do
    sleep(0.5)
    if state.curr == 1 then -- MINING STATE
      if require_refuel(1) then
        -- set return position
        checkpoint = turtle.position()
        checkpoint.f = turtle.facing()
        pmemory.write("checkpoint", checkpoint, "table")
        -- set state to returning for fuel
        state.set(2)
      elseif inventory_full() then
        -- set return position
        checkpoint = turtle.position()
        checkpoint.f = turtle.facing()
        pmemory.write("checkpoint", checkpoint, "table")
        -- set state to return to deposit
        state.set(3)
      else
        -- continue mining
        mine("forward")
        if state.curr ~= 5 then turtle.move("forward",true) end
        mine("up")
        mine("down")

        local pos = turtle.position()
        local dir = pmemory.read("direction","string")
        local row = pmemory.read("row","number")

        if pos.y == 0 or math.abs(pos.y) == diameter-1 then
          if (pos.x == 0 or math.abs(pos.x) == diameter-1)
            and row ~= 0 then
            pmemory.write("row",0,"number")
            for i=1,3 do
              local _, item = turtle.inspect("down")
              if item.name == "minecraft:bedrock" then
                if i == 1 or i == 2 then  -- i = 1 : the bottom layer of you you just mined has bedrock 
                  state.set(5)            -- i = 2 : the top layer of what you will mine has bedrock
                  break                   -- i = 3 : the middle layer of what you will mine has bedrock -- move up one
                end 
                turtle.move("up",true) 
              end
              turtle.move("down",true)
              mine("down")
            end
            turtle.turn("back")
          
          else
            pmemory.write("row",row+1,"number")
            turtle.turn(dir)
            mine("forward")
            if state.curr ~= 5 then turtle.move("forward",true) end
            mine("up")
            mine("down")
            turtle.turn(dir)

            if dir == "right" then pmemory.write("direction","left","string")
            else pmemory.write("direction","right","string")
            end
          end
        end
      end
    end

    if state.curr == 2 then -- REFUEL STATE
      turtle.to({"z:" .. 0, "x:" .. 0, "y:" .. 0, "f:" .. 0 },true)
      term.clear()
      term.setCursorPos(1,1)
      print ("Required fuel ... " .. require_refuel(2))
      -- wait for fuel then refill
      repeat
        os.pullEvent("turtle_inventory")
      until require_refuel(2) == 0
      -- set state to return to mining
      state.set(4)
    end

    if state.curr == 3 then -- UNLOAD STATE
      turtle.to({"z:" .. 0, "x:" .. 0, "y:" .. 0, "f:" .. 2 },true)
      print "Unloading ... "
      local unloaded = unload_inventory()
      while not unloaded do
        local _, item = turtle.inspect()
        if item.name == "minecraft:chest" then
          if require_refuel(1) or require_refuel(2) > 0 then
            -- refuel state
            state.set(2)
            break
          else 
            turtle.move("down",true)
            unloaded = unload_inventory()
          end
        else 
          -- invalid inventory enter error state
          state.set(6)
          break
        end
      end

      if unloaded and require_refuel(2) == 0 then
        state.set(4)
      else
        state.set(2)
      end
    end

    if state.curr == 4 then -- RETURN TO MINE STATE
      -- returning from refuel/deposit
      checkpoint = pmemory.read("checkpoint", "table")
      turtle.to({"y:" .. checkpoint.y, "x:" .. checkpoint.x, "z:" .. checkpoint.z, "f:" .. checkpoint.f})
      -- return to mining state
      state.set(1)
    end

    if state.curr == 5 then -- FINISHED STATE
      -- returning because finished
      turtle.to({"z:" .. 0, "x:" .. 0, "y:" .. 0, "f:" .. 0 })
      term.clear()
      term.setCursorPos(1,1)
      print "Excavation Completed"
      return
    end

    if state.curr == 6 then -- ERROR STATE
      turtle.to({"z: " .. 0})
      sleep(1)
      term.clear()
      term.setCursorPos(1,1)
      print "An error occurred!"
      print "Change my inventory to denote resolution"

      os.pullEvent("turtle_inventory")
      state.set(3) -- unload current
    end
  end
end

local function menu()
  while true do
    term.clear()
    term.setCursorPos(1,1)
    print "Welcome to the Turtle Excavater"
    print "-------------------------------"
    print " Press Q to quit"

    local e, k = os.pullEvent("key")

    os.pullEvent("char")
    term.clear()
    term.setCursorPos(1,1)

    if k == keys.q then return end
  end
end

state.initialize()
slot16iscobble.name = "cobble_state"
slot16iscobble.initialize()
if state.curr == 0 then
  turtle.initialize()
  state.set(1)
  mine("up")
  mine("down")
end
parallel.waitForAny( menu, task )
state.finalize()
slot16iscobble.finalize()
pmemory.delete("diameter")
pmemory.delete("direction")
pmemory.delete("row")
