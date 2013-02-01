-- Program: Machines client 0.1
-- Author: shady2k

function VertMenu(tableofItems, path)
local selection = "";
local sIndex = 1;
local offset = 1;
local tx = 1;
local controls_text="Управл.: стрелка вверх/вниз, Enter";
while (selection == "") do
  term.clear();
  local xMax, yMax = term.getSize();
  yMax = yMax - 4;
  local y = math.floor(yMax/2) + math.floor(#tableofItems/2);
  local max_offset = math.ceil(#tableofItems / yMax);
  y = y - #tableofItems + 2;
  if y<3 then y = 3 end;
 
term.setCursorPos(1,1);
term.write(path);
term.setCursorPos(xMax - 24, 1);
term.write("|Зарядник shady2k");
 
term.setCursorPos(tx,yMax+4);
term.write("Страница "..offset.." из "..max_offset.." | ");
 
term.setCursorPos(xMax - string.len(controls_text) + 23, yMax+4);
term.write(controls_text);
 
        for tx=1, xMax do
        term.setCursorPos(tx,yMax+3);
        term.write("-")
        term.setCursorPos(tx,2);
        term.write("-")
        end  
 
local min_i = yMax * (offset - 1) + 1;
local max_i = offset * yMax;
if max_i > #tableofItems then max_i = #tableofItems end;
 
for i=min_i, max_i do
 
  if string.len(tableofItems[i]) >= xMax then
   term.clear();
   term.setCursorPos(1,1);
   print (("ERROR: List item # "..i).." is too long please reduce");
   return "";
  end
   --local x = math.floor(xMax/2) - math.floor(string.len(tableofItems[i])/2);
   local x = 2;
 
   if i == sIndex then x = x-1 end;
   term.setCursorPos(x,y);
   if i == sIndex then term.write("[") end;
   term.write(tableofItems[i]);
 
   if i == sIndex then term.write("]") end;
 
   y = y+1;
  end
 
 
  local r,s = os.pullEventRaw();
 
  if r == "rednet_message" and s == server_id then --rednet_message
  os.reboot()
  end 
 
  if r == "key" then
 
  if s == 209 then offset = offset +1 end;
  if s == 201 then offset = offset -1 end;
 
  if offset < 1 then offset = 1 end;
  if offset > max_offset then offset = max_offset end;
 
  min_i = yMax * (offset - 1) + 1;
  max_i = offset * yMax;  
  if max_i > #tableofItems then max_i = #tableofItems end;
 
  if s == 208 then sIndex = sIndex +1 end;
  if s == 200 then sIndex = sIndex -1 end;
 
  if s == 208 or s == 200 then
  if sIndex > max_i then sIndex = min_i end;
  if sIndex < min_i then sIndex = max_i end;    
  end
 
  if sIndex > max_i then sIndex = min_i end;
  if sIndex < min_i then sIndex = min_i end;
  if s == 28 then
    term.clear();
    term.setCursorPos(1,1);
    return sIndex
  end
 end
 
 
end
end

function getInput(is_secure)
if is_secure then user_input = read("*") else user_input = read() end
return
end

function wait_rednet()

while 1 do
local event, computer_id, data = os.pullEvent()

sleep(0)
if event == "rednet_message" and computer_id == server_id then --rednet_message
os.reboot()
end
end

end

--programm begin
server_id = 6478
local idle_count = 0
local timer = os.startTimer(1)
local is_init = false
user_input = ""

os.pullEvent = os.pullEventRaw

rednet.open("top")

term.clear()
term.setCursorPos(1, 1)
print("Инициализация. Пожалуйста, подождите.")

rednet.send(server_id, textutils.serialize({action = "#need_last_message#"}));

while 1 do --while

local event, param, data = os.pullEvent()

if event == "timer" and param == timer and not is_init then
idle_count = idle_count + 1

if idle_count > 5 then
term.clear()
term.setCursorPos(1, 1)
print("К сожалению, сервис сейчас недоступен. Попробуйте, пожалуйста, позже.\n\nСпасибо!")

idle_count = 100
end

timer = os.startTimer(1);
end

if event == "rednet_message" and param == server_id then --rednet_message
is_init = true
msg = textutils.unserialize(data)

--actions
if msg.action == "print" then -- print

if msg.term_clear then term.clear() end
if msg.set_cursor then 
term.setCursorPos(tonumber(msg.posx), tonumber(msg.posy)) 
term.clearLine()
end
print(msg.text)

end --print

if msg.action == "VertMenu" then --VertMenu
local sel

sel = VertMenu(msg.menu_table, msg.menu_path);
rednet.send(server_id, textutils.serialize({action = "ans", user_text = sel}));

is_init = false;
term.clear()
term.setCursorPos(1, 1)
print("Пожалуйста, подождите.")
timer = os.startTimer(1)
end --VertMenu

if msg.action == "read" then --read

if msg.term_clear then term.clear() end
if msg.set_cursor then 
term.setCursorPos(tonumber(msg.posx), tonumber(msg.posy)) 
term.clearLine()
end
print(msg.text)

parallel.waitForAny(function() wait_rednet() end, function() getInput(msg.is_secure) end)
--if msg.is_secure then user_input = read("*") else user_input = read() end
rednet.send(server_id, textutils.serialize({action = "ans", user_text = user_input}));

is_init = false;
term.clear()
term.setCursorPos(1, 1)
print("Пожалуйста, подождите.")
timer = os.startTimer(1)
end --read

--actions end

end --rednet_message

end --while
