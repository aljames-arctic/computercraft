-- Node preserver requires Thaumcraft 4
-- Place the ComputerCraft block directly adjacent to the node
-- Run a redstone signal from the ComputerCraft block to the Node Stabilizer


local pmemory = dofile("/apis/pmemory")
node = peripheral.wrap("bottom")
if node == nil then
    print "ERROR : No node found"
end

-- node has two functions, getAspectCount()
--                         getAspects()

aspects = pmemory.retrieve( "aspects" )

local NODE_CHARGING = 0
local NODE_CHARGED = 1

local state = NODE_CHARGED

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
            aspects[aspect] = count     -- update the maximum
            pmemory.store( "aspects", aspects )    -- overwrite the maximums
        elseif count == 1 then
            state = NODE_CHARGING       -- prevent the node from fully depleting
            return
        elseif count < maximum then
            all_maximized = false
        end
    end

    if all_maximized then
        state = NODE_CHARGED
    end
end

while true do
    inspect_aspects()

    if state == NODE_CHARGED then
        rs.output("back", true)     -- deactivate the node preserver
    elseif state == NODE_CHARGING then
        rs.output("back", false)    -- activate the node preserver until charged again
    end
    
    sleep(5)
end
