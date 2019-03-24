
--********************************************************
--  Module:   Advanced Position Awareness
--  Author:   aljames-arctic
--  License:  Do what you want
--
--  Description:
--    For every movement (turn/move) records the turtle's
--    new offset from initial start as soon as the movement
--    is completed.
--
--  Note: Turtle initializes at 0,0,0 pointing in Y+ direction
--        Unlike minecraft maps, Z+ is vertical up
--
--  Race Condition Warning: If the turtle moves and does
--    not save its new movement before the chunk is unloaded
--    then it will be off by one. Empirically this is minor.
--********************************************************

--**********************************
-- Module initialization
-- #include required submodules
--**********************************
local self = {}
local pmemory = dofile("/apis/pmemory")

--**********************************
-- Module local variables
--**********************************
pmemory.initialize("position",{x=0,y=0,z=0,x_dir=0,y_dir=1},"table")
local position = pmemory.read("position","table")
local x, y, z = position.x, position.y, position.z
local x_dir, y_dir = position.x_dir, position.y_dir

--**********************************
-- Force a reset of any saved position
--**********************************
function self.initialize()
  pmemory.add("position")
  pmemory.write("position",{x=0,y=0,z=0,x_dir=0,y_dir=1},"table")
  position = pmemory.read("position","table")
end

--**********************************
-- Return locally stored position
--**********************************
function self.position()
  return {x = position.x, y = position.y, z = position.z}
end

--**********************************
-- Return locally stored direction +/-
--**********************************
function self.directions()
  return {x_dir = position.x_dir, y_dir = position.y_dir}
end

--**********************************
-- Return the facing direction integer
--**********************************
function self.facing()
  if y_dir ~= 0 then return 1-y_dir
  else return 2+x_dir
  end
end

--**********************************
-- Update persistant memory
--**********************************
function self.update(action)
  if action == "forward" then
    x = x + x_dir
    y = y + y_dir
  elseif action == "back" then
    x = x - x_dir
    y = y - y_dir
  elseif action == "down" then
    z = z - 1
  elseif action == "up" then
    z = z + 1
  elseif action == "right" then
    x_dir, y_dir = -y_dir, x_dir
  elseif action == "left" then
    x_dir, y_dir = y_dir, -x_dir
  end 
  
  pmemory.write("position",{x=x,y=y,z=z,x_dir=x_dir,y_dir=y_dir},"table")
  position = pmemory.read("position","table")
end


--**********************************
-- Reset persistant memory values to
-- provided values.
--**********************************
function self.set(X,Y,Z,XDIR,YDIR)
  pmemory.write("position",{x=X,y=Y,z=Z,x_dir=XDIR,y_dir=YDIR},"table")
  position = pmemory.read("position","table")
end

return self
