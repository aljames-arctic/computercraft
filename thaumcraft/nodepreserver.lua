-- Node preserver requires Thaumcraft 4
-- Place the ComputerCraft block directly adjacent to the node
-- Run a redstone signal from the ComputerCraft block to the Node Stabilizer

node = peripheral.wrap("bottom")
if node == nil then
    print "ERROR : No node found"
end

-- node has two functions, getAspectCount()
--                         getAspects()

esstable = node.getAspects()
for k,v in pairs(esstable) do
    print( tostring(k) .. ":" .. tostring(v) )
end
