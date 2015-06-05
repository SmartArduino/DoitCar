--DoitCar Ctronl Demo
--ap mode
--Created @ 2015/05/14 by Doit Studio
--Modified: null
--http://www.doit.am/
--http://www.smartarduino.com/
--http://szdoit.taobao.com/
--bbs: bbs.doit.am

print("\n")
print("ESP8266 Started")

local exefile="DoitCarControl"
local luaFile = {exefile..".lua"}
for i, f in ipairs(luaFile) do
	if file.open(f) then
      file.close()
      print("Compile File:"..f)
      node.compile(f)
	  print("Remove File:"..f)
      file.remove(f)
	end
 end

if file.open(exefile..".lc") then
	dofile(exefile..".lc")
else
	print(exefile..".lc not exist")
end
exefile=nil;luaFile = nil
collectgarbage()

