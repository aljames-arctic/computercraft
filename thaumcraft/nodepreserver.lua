-- Node preserver requires Thaumcraft 4
-- Place the ComputerCraft block directly adjacent to the node
-- Run a redstone signal from the ComputerCraft block to the Node Stabilizer

local self = {}
self.name = "Node Preserver"

local pmemory = dofile("/apis/pmemory")

-- initialize configuration options
if pmemory.add("config") then
    config = {}
    config.node_side = "front"
    config.rs_output = "bottom"
    config.limit = 10
    config.sleeptime = 20
    pmemory.store("config", config )
end
config = pmemory.retrieve("config")

local node = peripheral.wrap(config.node_side)

-- node has two functions, getAspectCount()
--                         getAspects()

aspects = pmemory.retrieve( "aspects" )

local NODE_CHARGING = 0
local NODE_CHARGED = 1

local state = NODE_CHARGED

function update_redstone()
    if state == NODE_CHARGED then
        rs.setOutput(config.rs_output, true)  -- disable stabilizer
    elseif state == NODE_CHARGING then
        rs.setOutput(config.rs_output, false) -- enable stabilizer
    else
        print("Unknown state")
    end
end

function inspect_aspects()
    local all_maximized = true

    node_aspects = node.getAspects()
    for _,aspect in pairs(node_aspects) do
        if aspects[aspect] == nil then
            aspects[aspect] = 0 -- add a new entry if necessary
        end

        maximum = aspects[aspect]
        count = node.getAspectCount(aspect)
        if maximum < count then
            aspects[aspect] = count                 -- update the maximum
            pmemory.store( "aspects", aspects )     -- overwrite the maximums
        elseif count < config.limit and count < maximum then   -- close to empty, if node was gaining then count == maximum on this aspect
            state = NODE_CHARGING                   -- prevent the node from fully depleting
            return
        elseif count < maximum then
            all_maximized = false
        end
    end

    if all_maximized then
        state = NODE_CHARGED
    end
end

local state_action = 
{
  [NODE_CHARGING] = function() 
                        inspect_aspects() 
                        update_redstone()
                    end,
  [NODE_CHARGED] = function() 
                        inspect_aspects() 
                        update_redstone()
                    end,
}

-- actual task to be run
function self.run()
  self.running = true
  while self.running do 
    state_action[state]() 
    term.setCursorPos(1,6)
    print("Current State: "..tostring(state))
    sleep(config.sleeptime)
  end
end

return self
