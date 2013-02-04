-- Program: Machines filter 0.1
-- Author: shady2k
-- Description: redpower filter replace. Only for turtles.

function load(name)
local file = fs.open(name,"r")
local data = file.readAll()
file.close()
return textutils.unserialize(data)
end

function init()
local slots = {}
local i = 0

for i = 1, 16, 1 do

turtle.select(i)

  if turtle.getItemCount(i) ~= 0 then
		slots["i"..i] = true
	else
		slots["i"..i] = false
	end

end


return slots
end

--program begin

local i = 0
local items_count = 0

--init
if fs.exists("machines_filter_db") then
local slots = load("machines_filter_db")
else
local slots = init()
end
--init end

while 1 do
for i = 1, 16, 1 do
	turtle.select(i)
	items_count = turtle.getItemCount(i)
	
	if slots["i"..i] then --было в фильтре
	
		if items_count > 1 then
			turtle.drop(items_count - 1)
		end
	
	else --не было в фильтре
		turtle.dropUp(items_count)
	end
end
end
