-- [ New version of pasteget! ]--
iargs = {...}
folder = {}

github = {}
pastebin = {}

mygit = "aljames-arctic/computercraft/integration"
-- [ specify which files to download for a specific run ] --
if iargs[1] == "3rd_party" and iargs[2] == "quarry" then
  table.insert(pastebin, {name="smart_quarry", tag="rpXRAZs4", replace=true})
elseif iargs[1] =="chess" then
  if iargs[2] == "build" then
    table.insert(github, {name="build", tag=mygit.."/chess/setup/build/board.lua", replace=true})

    table.insert(github, {name="piece", tag=mygit.."/chess/setup/build/pieces.lua", replace=true})
    table.insert(github, {name="piece-startup", tag=mygit.."/chess/pieces/startup.lua", replace=true})
    table.insert(github, {name="disk-startup", tag=mygit.."/chess/setup/drive/startup.lua", replace=true})
  elseif iargs[2] == "master" then
  elseif iargs[2] == "piece" then
    table.insert(github, {name="startup", tag=mygit.."/chess/pieces/startup.lua", replace=true})
  end
elseif iargs[1] == "api" or iargs[1] == "apis" then
  table.insert(folder, "apis")
  table.insert(github, {name="/apis/util", tag=mygit.."/apis/util.lua", replace=true})
  table.insert(github, {name="/apis/state", tag=mygit.."/apis/state.lua", replace=true})
  table.insert(github, {name="/apis/turtle", tag=mygit.."/apis/turtle.lua", replace=true})
  table.insert(github, {name="/apis/pmemory", tag=mygit.."/apis/pmemory.lua", replace=true})
  table.insert(github, {name="/apis/position", tag=mygit.."/apis/position.lua", replace=true})
  table.insert(github, {name="/apis/touchscreen", tag=mygit.."/apis/touchscreen.lua", replace=true})
  table.insert(github, {name="/apis/rednetRelay", tag=mygit.."/apis/rednetRelay.lua", replace=true})
elseif iargs[1] == "nexus" then
  if iargs[2] == "master" then
    table.insert(folder, "apis")
    table.insert(github, {name="/apis/util", tag=mygit.."/apis/util.lua", replace=true})
    table.insert(github, {name="/apis/pmemory", tag=mygit.."/apis/pmemory.lua", replace=true})
    table.insert(github, {name="/apis/touchscreen", tag=mygit.."/apis/touchscreen.lua", replace=true})
    table.insert(github, {name="config", tag=mygit.."/nexus/master/config.lua", replace=false})
    table.insert(github, {name="startup", tag=mygit.."/nexus/master/startup.lua", replace=true})
  elseif iargs[2] == "router" then
    table.insert(folder, "apis")
    table.insert(github, {name="/apis/util", tag=mygit.."/apis/util.lua", replace=true})
    table.insert(github, {name="/apis/turtle", tag=mygit.."/apis/turtle.lua", replace=true})
    table.insert(github, {name="startup", tag=mygit.."/nexus/router/startup.lua", replace=true})
  elseif iargs[2] == "slave" then
    table.insert(folder, "apis")
    table.insert(github, {name="/apis/util", tag=mygit.."/apis/util.lua", replace=true})
    table.insert(github, {name="/apis/turtle", tag=mygit.."/apis/turtle.lua", replace=true})
    table.insert(github, {name="config", tag=mygit.."/nexus/slave/config.lua", replace=false})
    table.insert(github, {name="startup", tag=mygit.."/nexus/slave/startup.lua", replace=true})
  end
elseif iargs[1] == "standard" then
  if iargs[2] == "lumberjack" then
    table.insert(github, {name="active_program", tag=mygit.."/standard/lumberjack.lua", replace=true})
    table.insert(github, {name="startup", tag=mygit.."/startup.lua", replace=true})
  elseif iargs[2] == "quarry" then
    table.insert(github, {name="active_program", tag=mygit.."/standard/quarry.lua", replace=true})
    table.insert(github, {name="startup", tag=mygit.."/startup.lua", replace=true})
  elseif iargs[2] == "nether" then
    table.insert(github, {name="nether", tag=mygit.."/nether_passage.lua", replace=true})
  end
elseif iargs[1] == "miner" then
  if iargs[2] == "sphere" then
    table.insert(github, {name="startup", tag=mygit.."/requests/sphere_miner.lua", replace=true})
  elseif iargs[2] == "walker" then
    table.insert(github, {name="walk", tag=mygit.."/requests/walker.lua", replace=true})
  end
else
  table.insert(github, {name="pasteget", tag=mygit.."/pasteget.lua", replace=true})
end

-- [ create the file system architecture ] --
for _, name in ipairs( folder ) do
  if not fs.exists( name ) then fs.makeDir( name ) end
end

-- [ download/redownload the requested files ] --
http_request = { github=github, pastebin=pastebin }
for service, list in pairs( http_request ) do
  if #list > 0 then print("Using service "..service.." and downloading...") end
  for _, program in ipairs( list ) do
    if program.replace and fs.exists( program.name ) then shell.run( "rm", program.name ) end
    if not fs.exists( program.name ) then
      print( program.name )
      shell.run( service, "get", program.tag, program.name )
    end
  end
end
