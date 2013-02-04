-- Program: Machines filter 0.1
-- Author: shady2k
-- Description: redpower item detector replace. Only for turtles. Sends data via rednet.

function SendMessage(msg)
msg = textutils.serialize(msg)
rednet.send(server_id, msg);
print("Send message: "..msg.."\n")
end

--program begin

server_id = 6478
local i = 1
local items_count = 0
is_stop = false

while not is_stop do
items_count = 0
turtle.select(i)
items_count = turtle.getItemCount(i)
turtle.drop()
SendMessage({ count =  items_count})
end
