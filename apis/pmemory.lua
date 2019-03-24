
--********************************************************
--  Module:    Persistent Memory
--  Author:    aljames-arctic
--  License:   Do what you want
--
--  Description:
--      Persistant memory module; saves variables to files
--      in turtles to maintain knowledge across unloading
--      chunks/server restarts.
--********************************************************

--**********************************
-- Module initialization
-- #include required submodules
--**********************************
local pmemory = {}
pmemory.path = "/pmemory"

--**********************************
-- Change the save directory
--**********************************
function pmemory.changeDir(path)
  pmemory.path = path
  if not fs.exists(pmemory.path) then fs.makeDir(pmemory.path) end
end
pmemory.changeDir(pmemory.path)

--**********************************
-- Allocate memory for a variable
--    Returns false if variable exists
--    Returns true if variable is created
--**********************************
function pmemory.add(variable)
  if fs.exists(pmemory.path.."/"..variable) then return false
  else file = io.open(pmemory.path.."/"..variable,"w") return true
  end
end

--**********************************
-- Check if a variable already exists
--**********************************
function pmemory.exists(variable)
  return fs.exists(pmemory.path.."/"..variable)
end

--**********************************
-- Deallocate memory for a variable
--**********************************
function pmemory.remove(variable)
  local file = pmemory.path.."/"..variable
  fs.delete(file)
end

--**********************************
-- Deallocate memory for a variable
--**********************************
function pmemory.delete(variable)
  local file = pmemory.path.."/"..variable
  if not fs.exists(file) then return false
  else shell.run("rm",file)
  end
end

--**********************************
-- Write variable to persistant memory
--**********************************
function pmemory.write(variable, value, data_type)
  pmemory.add(variable) -- create the file if it doesn't exist
  file = io.open(pmemory.path.."/"..variable, "r")
  if file then
    file:close()
    file = io.open(pmemory.path.."/"..variable,"w")

    local data
    if data_type == "table" then 
      assert(type(value)=="table","write expected a table")
      data = textutils.serialize(value)
    elseif data_type == "number" or data_type == "#" then
      assert(type(value)=="number","write expected a number")
      data = tostring(value)
    elseif data_type == "string" then
      assert(type(value)=="string","write expected a string")
      data = value
    elseif data_type == nil then
      if type(value) == "string" then data = value
      else data = textutils.serialize(value)
      end
    else print("Unknown data type for pmemory API")
    end

    file:write(data)
    file:close()
  end
end

--**********************************
-- Read persistant memory variable
--**********************************
function pmemory.read(variable, data_type)
  file = fs.open(pmemory.path.."/"..variable, "r")
  if file then
    data = file:readAll()
    file:close()

    if data_type == "number" or data_type == "#" then
      return tonumber(data)
    elseif data_type == "string" then
      return data
    elseif data_type == "table" then
      return textutils.unserialize(data)
    else
      print("Unknown data type for pmemory API -- returning as string")
      return data
    end
  end
end

--**********************************
-- Initialize a variable if it does
-- not exist yet. Otherwise do nothing
--**********************************
function pmemory.initialize(variable, value, data_type)
  if pmemory.add(variable) then
    pmemory.write(variable, value, data_type)
  end
end

return pmemory
