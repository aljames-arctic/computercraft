-- Universal wrapper script -- provides ~ escape character to all scripts
local quit = false
local ESC_KEY = '~'
local program = dofile("/active_program")

function quitProgram()
    local event, param = os.pullEvent("char")
    if param == ESC_KEY then quit = true end
end

term.clear()
term.setCursorPos(1,1)
print ("Welcome to the "..program.name)
print ("-------------------------------")
print (" Press "..ESC_KEY.." to quit")

parallel.waitForAny( quitProgram, program.run )
if quit then
    print("Quitting...")
    program.running = false
    sleep(5) -- give the program 5 seconds to exit gracefully
end