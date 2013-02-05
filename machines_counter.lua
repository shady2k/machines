-- Program: Machines counter 0.1
-- Author: shady2k
-- Description: redpower item detector replace. Only for turtles. Sends data via rednet.

function SendMessage(msg)
msg = textutils.serialize(msg)
rednet.send(server_id, msg);
print("Send message: "..msg.."\n")
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

local i = 1
local c = 2
local items_count = 0

while 1 do
items_count = 0

turtle.select(i)
items_count = turtle.getItemCount(i)

if items_count ~= 0 then
check_counter = 0
turtle.drop()
SendMessage({action = "count", count =  items_count})
else

if i == 1 then
i = c
c = c + 1
if c > 16 then c = 2 end
else
i = 1
end

end

end
end

--program begin
server_id = 6478
rednet.open("right")

while 1 do
parallel.waitForAll(function() main() end, function() WaitForMessages() end)
end
