
--********************************************************
--  Module:   State Machine Memory
--  Author:   aljames-arctic
--  License:  Do what you want
--
--  Description:
--    Light weight state module for turtle activities where
--    you do multiple things.
--
--    eg: log cutter
--        1) plant tree
--        2) compare with log
--        3) chop forward
--        4) chop up & compare with log
--        5) return
--
--********************************************************

--**********************************
-- Module initialization
-- #include required submodules
--**********************************
local state = {}
local pmemory = dofile("/apis/pmemory")
state.curr = -1


--**********************************
-- Initialize the state
--**********************************
function state.initialize()
  pmemory.initialize("state", 0, "#")
  state.curr = pmemory.read("state","#")
end

--**********************************
-- Set the state to a new value
--**********************************
function state.set(new_state)
  pmemory.add("state")
  pmemory.write("state", new_state,"#")
  state.curr = new_state
end

--**********************************
-- Retrieve persistant memory state
--**********************************
function state.get()
  pmemory.initialize("state",0,"#")
  state.curr = pmemory.read("state","#")
  return state.curr
end

--**********************************
-- Deallocation call for state memory
--**********************************
function state.finalize()
  pmemory.delete("state")
  state.curr = -1
end


return state
