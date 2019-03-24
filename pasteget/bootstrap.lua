-- [ New version of pasteget! Use github! ]--
local username ="aljames-arctic"

http_request = {
  ["pastebin"] = { 
    {name = "github", tag = "caMmH484", replace = true},
  },
  ["github"] = {
    {name = "pasteget", tag = username.."/computercraft/master/pasteget.lua", replace = true},
  }
}

for service, list in pairs(http_request) do
  print("Using service "..service.." and downloading...")
  for _, program in ipairs(list) do
    if program.replace then shell.run( "rm", program.name ) end
    print( "Downloading "..program.name.." from "..service )
    shell.run( service, "get", program.tag, program.name )
  end
end