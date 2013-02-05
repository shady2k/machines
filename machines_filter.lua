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

function SendMessage(msg)
msg = textutils.serialize(msg)
rednet.send(server_id, msg);
print("Send message: "..msg.."\n")
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

function WaitForMessages()

while 1 do --while

local event, param, data = os.pullEvent()

if event == "rednet_message" and param == server_id then --rednet_message
print("Receive message: "..data.."\n")

msg = textutils.unserialize(data)

if msg.action == "ping" then
print("Send message: pong\n")
rednet.send(server_id, {action = "ans", user_text = "pong"})
end

end --rednet_message

end --while

end

function main()

local i = 0
local i2 = 0
local ping_count = 0
local is_drop = false
local items_count = 0
local slots = {}

while 1 do

ping_count = ping_count + 1

if ping_count > 500 then
SendMessage({ count = 0, unprocessed_count = 0})
ping_count = 0
end

for i = 1, 16, 1 do
	turtle.select(i)
	items_count = turtle.getItemCount(i)
	
	if slots["i"..tostring(i)] then --было в фильтре
	
		if items_count > 1 then
			turtle.dropDown(items_count - 1)
			SendMessage({action = "count", count = items_count, unprocessed_count = 0})
		end
	
	else --не было в фильтре
		
		is_drop = false
		
		for i2 = 1, 16, 1 do
		if slots["i"..tostring(i2)] and i2 ~= i then --было в фильтре
			if turtle.compareTo(i2) then
				turtle.dropDown(items_count)
				SendMessage({action = "count", count = items_count, unprocessed_count = 0})
				is_drop = true
			end
		end
		end

		if not is_drop then --не было в фильтре
		turtle.dropUp(items_count)
		SendMessage({action = "count", count = 0, unprocessed_count = items_count})
		end
	end
end
end

end

--program begin

server_id = 6478
local i = 0
local i2 = 0
local ping_count = 0
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
parallel.waitForAll(function() main() end, function() WaitForMessages() end)
end
