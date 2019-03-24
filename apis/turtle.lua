
--********************************************************
--  Module:   Advanced Turtle Control (Adds functionality)
--  Author:   aljames-arctic
--  License:  Do what you want
--
--  Description:
--    Overwrites/Supplements the basic CC Turtle API with a robust
--    suite of features.
--
--********************************************************

--**********************************
-- Module initialization
-- #include required submodules
--**********************************
local self = {}
local util = dofile("/apis/util")
local position = dofile("/apis/position")

--**********************************
-- Module local variables
--**********************************
local SOUTH, WEST, NORTH, EAST = 0, 1, 2, 3

--**********************************
-- Some Turtle Commands No Changes
-- These are included to allow backwards compatability
--**********************************
function self.equipLeft()
  return turtle.equipLeft()
end

function self.equipRight()
  return turtle.equipRight()
end

function self.getSelectedSlot()
  return turtle.getSelectedSlot()
end

function self.select(slot)
  return turtle.select(slot) 
end

function self.getItemDetail(slot)
  return turtle.getItemDetail(slot)
end

function self.getFuelLevel()
  return turtle.getFuelLevel()
end

function self.getFuelLimit()
  return turtle.getFuelLimit()
end

function self.inspectUp()
  return turtle.inspectUp()
end

function self.inspectDown()
  return turtle.inspectDown()
end

function self.attackUp()
  return turtle.attackUp()
end

function self.attackDown()
  return turtle.attackDown()
end

function self.digUp()
  return turtle.digUp()
end

function self.digDown()
  return turtle.digDown()
end

function self.detectUp()
  return turtle.detectUp()
end

function self.detectDown()
  return turtle.detectDown()
end

function self.suckUp()
  return turtle.suckUp()
end

function self.suckDown()
  return turtle.suckDown()
end

function self.compareTo(slot)
  return turtle.compareTo(slot)
end

function self.getItemCount(slot)
  return turtle.getItemCount(slot)
end

function self.getItemSpace(slot)
  return turtle.getItemSpace(slot)
end

function self.refuel(quantity)
  if quantity then return turtle.refuel(quantity)
  else return turtle.refuel()
  end
end

function self.dropUp(quantity)
  if quantity then return turtle.dropUp(quantity)
  else return turtle.dropUp()
  end
end

function self.dropDown(quantity)
  if quantity then return turtle.dropDown(quantity)
  else return turtle.dropDown()
  end
end

function self.placeUp()
  local current_slot = self.getSelectedSlot()
  local retv = turtle.placeUp()
  return retv, self.getItemCount(current_slot)
end

function self.placeDown()
  local current_slot = self.getSelectedSlot()
  local retv = turtle.placeDown()
  return retv, self.getItemCount(current_slot)
end


--**********************************
-- Turtle Commands Slight Tweaks
-- Tweaks are made to maintain backwards compatability
--**********************************
function self.craft(quantity)
  self.select(16)
  return turtle.craft(quantity)
end

--**********************************
-- Return persistant memory position
-- Directional Primitives
--**********************************
function self.position()
  return position.position()
end

function self.directions()
  return position.directions()
end

function self.facing()
  return position.facing()
end

--**********************************
--  Returns the opposite direction headed
--    ( useful for turning around )
--**********************************
function self.switch(dir)
  if dir == "forward" or dir == "front" then
    return "backward"
  elseif dir == "backward" or dir == "back" then
    return "forward"
  elseif dir == "right" then
    return "left"
  elseif dir == "left" then
    return "right"
  elseif dir == "up" or dir == "top" then
    return "down"
  elseif dir == "down" or dir == "bottom" then
    return "up"
  end
end

--**********************************
--  Advanced turn functionality
--**********************************
function self.turnLeft()
  turtle.turnLeft()
  position.update("left")
  return true
end

function self.turnRight()
  turtle.turnRight()
  position.update("right")
  return true
end

function self.turn( dir )
  if dir == "front" or dir == "top" or dir == "bottom" then
    return true
  elseif dir == "right" then
    return self.turnRight()
  elseif dir == "left" then
    return self.turnLeft()
  elseif dir == "back" then
    return self.turn( "right" ) and self.turn("right")
  elseif type(dir) == "number" then
    local difference = math.floor( dir - self.facing() ) % 4
    if difference == 3 then self.turn("left")
    elseif difference > 0 then 
      for i=1,difference do self.turn("right") end 
    end
    return true
  else
    return false
  end
end

function self.unturn( dir )
  if dir == "front" or dir == "top" or dir == "bottom" then
    return true
  elseif dir == "right" then
    return self.turnLeft()
  elseif dir == "left" then
    return self.turnRight()
  elseif dir == "back" then
    return self.turn("right") and self.turn("right")
  end
end

--**********************************
-- Selects fuel if able. Otherwise no change
--
-- Returns true if current slot has fuel
-- Otherwise returns true if any slot has fuel
-- Otherwise returns false
--**********************************
function self.selectFuel()
  local current_slot = self.getSelectedSlot()
  if turtle.refuel(0) then return true end

  for slot=1,16 do
    self.select(slot)
    if turtle.refuel(0) then
      return true
    end
  end
  self.select(current_slot)
  return false
end

--**********************************
-- Turtle inspect functionality
--**********************************
function self.inspect(dir)
  local s, r = nil, nil
    
  self.turn(dir)

  if dir == "up" then s, r = turtle.inspectUp()
  elseif dir == "down" then s, r = turtle.inspectDown()
  else s, r = turtle.inspect()
  end

  self.unturn(dir)

  return s, r
end

--**********************************
-- Turtle attack functionality
--**********************************
function self.attack(dir)
  if dir == "front" then 
    return self.attack()
  elseif dir == "top" then 
    return self.attackUp()
  elseif dir == "bottom" then 
    return self.attackDown()
  elseif dir == "left" or dir == "right" or dir == "back" then 
    self.turn(dir) 
    return self.attack()
  else 
    return turtle.attack()
  end
end

--**********************************
-- Turtle dig functionality
--**********************************
function self.dig(dir)
  if dir == "front" or dir == "forward" then 
    return self.dig()
  elseif dir == "top" or dir == "up" then 
    return self.digUp()
  elseif dir == "bottom" or dir == "down" then 
    return self.digDown()
  elseif dir == "left" or dir == "right" or dir == "back" then 
    self.turn(dir) 
    return self.dig()
  else 
    return turtle.dig()
  end
end

--**********************************
-- Turtle movement functionality
--**********************************
function self.forward()
  local fuel = self.getFuelLevel()
  turtle.forward()
  local moved = fuel ~= self.getFuelLevel()
  if moved then position.update("forward") end
  return moved
end

function self.back()
  local fuel = self.getFuelLevel()
  turtle.back()
  local moved = fuel ~= self.getFuelLevel()
  if moved then position.update("back") end
  return moved
end

function self.up()
  local fuel = self.getFuelLevel()
  turtle.up()
  local moved = fuel ~= self.getFuelLevel()
  if moved then position.update("up") end
  return moved
end

function self.down()
  local fuel = self.getFuelLevel()
  turtle.down()
  local moved = fuel ~= self.getFuelLevel()
  if moved then position.update("down") end
  return moved
end

--**********************************
--Provide a value for optional to allow digging/attacking
--**********************************
local function moveForward(optional)
  while not self.forward() do
    if optional ~= nil then
      self.attack()
      self.dig()
    end
    sleep(0.5)
  end
  return true
end

local function moveBack(optional)
  if optional == nil then
    while not self.back() do
      sleep(0.5)
    end
  else
    if not self.back() then
      self.turn("back")
      moveForward(optional) -- attack/dig forward
      self.turn("back")
    end
  end
  return true
end

local function moveUp(optional)
  while not self.up() do
    if optional ~= nil then
      self.attackUp()
      self.digUp()
    end
    sleep(0.5)
  end
  return true
end

local function moveDown(optional)
  while not self.down() do 
    if optional ~= nil then
      self.attackDown()
      self.digDown()
    end
    sleep(0.5) 
  end
  return true
end

--**********************************
-- Multiple block movement
--
-- Provide a value for optional to allow dig/attack
--**********************************
function self.move(dir, optional)
  if dir == "forward" then
    moveForward(optional)
  elseif dir == "right" or dir == "left" then
    self.turn(dir)
    moveForward(optional)
    self.unturn(dir)
  elseif dir == "backward" or dir == "back" then
    moveBack(optional)
  elseif dir == "up" then
    moveUp(optional)
  elseif dir == "down" then
    moveDown(optional)
  else assert(false)
  end
end

function self.place(dir, text)
  local current_slot = self.getSelectedSlot()
  if dir == "top" or dir == "up" then 
    return self.placeUp()
  elseif dir == "bottom" or dir == "down" then 
    return self.placeDown()
  end

  self.turn(dir)
  local retv = false
  if text == nil then retv = turtle.place()
  else retv = turtle.place(text)
  end
  self.unturn(dir)

  return retv, self.getItemCount(current_slot)
end

function self.detect(dir)
  local is_obj = false
  self.turn(dir)
  
  if dir == "up" then is_obj = self.detectUp()
  elseif dir == "down" then is_obj = self.detectDown()
  else is_obj = turtle.detect()
  end
  
  self.unturn(dir)
  return is_obj
end

function self.compareUp(optional)
  local current_slot = self.getSelectedSlot()
  if optional == nil then
    return turtle.compareUp()
  end

  for slot=1,16 do
    if self.getItemCount(slot) > 0 then
      self.select(slot)
      if turtle.compareUp() then
        self.select(current_slot)
        return true, slot
      end
    end
  end

  return false, 0
end

function self.compareDown(optional)
  local current_slot = self.getSelectedSlot()
  if optional == nil then
    return turtle.compareDown()
  end

  for slot=1,16 do
    if self.getItemCount(slot) > 0 then
      self.select(slot)
      if turtle.compareDown() then
        self.select(current_slot)
        return true, slot
      end
    end
  end

  return false, 0
end

function self.compare(optional)
  local current_slot = self.getSelectedSlot()
  if optional == nil then
    return turtle.compare()
  end

  for slot=1,16 do
    if self.getItemCount(slot) > 0 then
      self.select(slot)
      if turtle.compare() then
        self.select(current_slot)
        return true, slot
      end
    end
  end

  return false, 0
end

function self.drop(dir,quantity)
  if dir == "front" or dir == "forward" then 
    return self.drop(quantity)
  elseif dir == "top" or dir == "up" then 
    return self.dropUp(quantity)
  elseif dir == "bottom" or dir == "down" then 
    return self.dropDown(quantity)
  elseif dir == "left" or dir == "right" or dir == "back" or dir == "backward" then 
    self.turn(dir) 
    return self.drop(quantity)
  else 
    return turtle.drop()
  end
end

function self.suck(dir)
  if dir == "front" or dir == "forward" then 
    return self.suck()
  elseif dir == "top" or dir == "up" then 
    return self.suckUp()
  elseif dir == "bottom" or dir == "down" then 
    return self.suckDown()
  elseif dir == "left" or dir == "right" or dir == "back" or dir == "backward" then 
    self.turn(dir) 
    return self.suck()
  else 
    return turtle.suck()
  end
end

function self.transferTo(slot,quantity)
  local current_slot = self.getSelectedSlot()
  if not quantity then 
    quantity = self.getItemCount( current_slot )
  end
  return turtle.transferTo(slot,quantity)
end

function self.setPosition(x,y,z,xDir,yDir)
  position.set(x,y,z,xDir,yDir)
end

function self.emptySlot()
  for slot = 1,16 do
    if self.getItemCount(slot) == 0 then
      return slot
    end
  end
end

function self.selectEmptySlot()
  slot = self.emptySlot()
  if slot then
    self.select(slot)
  end
  return slot ~= nil
end

function self.swap(slot_a,slot_b)
  local current_slot = self.getSelectedSlot()
  empty = self.emptySlot()
  if empty == nil then return end

  self.select(slot_a)
  self.transferTo(empty)
  self.select(slot_b)
  self.transferTo(slot_a)
  self.select(empty)
  self.transferTo(slot_b)
  self.select(current_slot)
end

function self.enderFill(enderChest, dir, optional)
  local current_slot = self.getSelectedSlot()
  if dir == "left" or dir == "right" or dir == "back" then
    self.turn(dir)
    self.enderFill(enderChest, "forward", optional)
    self.unturn(dir)
  end

  self.select(enderChest)
  while not self.place(dir) do
    if optional then
      self.dig(dir)
      self.attack(dir)
    end
    sleep(0.5)
  end
  self.select(current_slot)
  while not self.suck(dir) do sleep(0.5) end
  self.select(enderChest)
  self.dig(dir)
  self.select(current_slot)
  return true
end

-- function made by TheNietsnie for a beekeeper program
-- updated to integrated use with Arctivlargl API
function self.to(directions,optional)
  for i = 1, #directions do
    local coord = util.strsplit(':', directions[i])        
    local coordValue = tonumber(coord[2])
    local pos = self.position()
    local currX, currY, currZ = pos.x, pos.y, pos.z

    if coord[1] == "x" then
      local distanceToMove = currX - coordValue
      if distanceToMove < 0 then self.turn(EAST)
      elseif distanceToMove > 0 then self.turn(WEST) end
      for i=1,math.abs(distanceToMove) do self.move("forward",optional) end
    elseif coord[1] == "y" then
      local distanceToMove = currY - coordValue
      if distanceToMove > 0 then self.turn(NORTH)
      elseif distanceToMove < 0 then self.turn(SOUTH) end
      for i=1,math.abs(distanceToMove) do self.move("forward",optional) end
    elseif coord[1] == "z" then                    
      local distanceToMove = currZ - coordValue
      if distanceToMove > 0 then
        for i=1,math.abs(distanceToMove) do self.move("down",optional) end
      elseif distanceToMove < 0 then
        for i=1,math.abs(distanceToMove) do self.move("up",optional) end
      end
    elseif coord[1] == "f" then
      self.turn(coordValue)
    end
    
    if coord[1] == "forward" then
      for i=1,math.abs(coordValue) do self.move("forward",optional) end
    elseif coord[1] == "backward" then
      for i=1,math.abs(coordValue) do self.move("backward",optional) end
    elseif coord[1] == "up" then
      for i=1,math.abs(coordValue) do self.move("up",optional) end
    elseif coord[1] == "down" then
      for i=1,math.abs(coordValue) do self.move("down",optional) end
    end
  end

  return true
end

--**********************************
-- Initialize Turtle
--**********************************
function self.initialize()
  position.initialize()
  self.select(1)
end

return self
