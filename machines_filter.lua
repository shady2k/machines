-- Program: Machines filter 0.1
-- Author: shady2k
-- Description: redpower filter replace. Only for turtles.

function load(name)
local file = fs.open(name,"r")
local data = file.readAll()
file.close()
return textutils.unserialize(data)
end

function save(table,name)
local file = fs.open(name,"w")
file.write(textutils.serialize(table))
file.close()
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

save(slots, "machines_filter_db")

return slots
end

--program begin

local i = 0
local i2 = 0
local is_drop = false
local items_count = 0
local slots = {}

rednet.open("right")

--init
if fs.exists("machines_filter_db") then
slots = load("machines_filter_db")
else
slots = init()
end
--init end

while 1 do
for i = 1, 16, 1 do
	turtle.select(i)
	items_count = turtle.getItemCount(i)
	
	if slots["i"..tostring(i)] then --было в фильтре
	
		if items_count > 1 then
			turtle.dropDown(items_count - 1)
		end
	
	else --не было в фильтре
		
		is_drop = false
		
		for i2 = 1, 16, 1 do
		if slots["i"..tostring(i2)] and i2 ~= i then --было в фильтре
			if turtle.compareTo(i2) then
				turtle.dropDown(items_count)
				is_drop = true
			end
		end
		end

		if not is_drop then turtle.dropUp(items_count) end
	end
end
end
