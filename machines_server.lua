-- Program: Machines server 0.1
-- Author: shady2k

function save(table,name)
local file = fs.open(name,"w")
file.write(textutils.serialize(table))
file.close()
end

function load(name)
local file = fs.open(name,"r")
local data = file.readAll()
file.close()
return textutils.unserialize(data)
end

function SendMessage(msg)
msg = textutils.serialize(msg)
last_msg = msg
rednet.send(client_id, msg);
print("Send message: "..msg.."\n")
if glog ~= nil then save(glog, "machines_log") end
end

function SendAndWaitForMessage(msg, timeout)

local msg = textutils.serialize(msg)
last_msg = msg
rednet.send(client_id, msg)

print("Send message: "..msg.."\n")
if glog ~= nil then save(glog, "machines_log") end

if timeout ~= 0 then local timer = os.startTimer(1) end

while 1 do

local event, param, data = os.pullEvent()

if event == "timer" and param == timer then
timeout = timeout - 1

if timeout <= 0 then
return -1
end

timer = os.startTimer(1)
end

if event == "rednet_message" and param == client_id then --rednet_message
local msg = textutils.unserialize(data)
print("Receive message: "..data.."\n")

if msg.action == "#need_last_message#" then
rednet.send(client_id, last_msg)
print("Send message: "..last_msg.."\n")
else
return msg.user_text
end

end --rednet_message

end

end

function WaitForMessages()

while 1 do --while

local event, param, data = os.pullEvent()

if event == "rednet_message" and param == client_id then --rednet_message
print("Receive message: "..data.."\n")

msg = textutils.unserialize(data)

if msg.action == "#need_last_message#" then
print("Send message: "..last_msg.."\n")
rednet.send(client_id, last_msg)
end

end --rednet_message

if event == "redstone" then --redstone_event
return
end --redstone_event

end --while

end

function SleepAndWaitForMessages(sleep_time)

local timer = os.startTimer(sleep_time)

while 1 do --while

local event, param, data = os.pullEvent()

if event == "timer" and param == timer then --timer_event
return
end --timer_event

if event == "rednet_message" and param == client_id then --rednet_message
print("Receive message: "..data.."\n")

msg = textutils.unserialize(data)

if msg.action == "#need_last_message#" then
print("Send message: "..last_msg.."\n")
rednet.send(client_id, last_msg)
end

end --rednet_message

end --while

end

function type_pin()

local pin
local pin2
local char
local i
local is_na = true
local login

while is_na do

is_na = false

pin = SendAndWaitForMessage({action = "read", term_clear = true, set_cursor = true, is_secure = true, posx = 1, posy = 1, text = "Пожалуйста, придумайте и введите пароль для оформления заказа:"}, 60)

if pin == -1 then return -1 end

pin2 = SendAndWaitForMessage({action = "read", term_clear = false, set_cursor = false, is_secure = true, text = "Введите пароль еще раз для подтверждения:"}, 60)

if pin2 == -1 then return -1 end

if pin ~= pin2 then
SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Введенные пароли не совпадают, попробуйте еще раз."})
is_na = true;
end

if string.len(pin) < 4 then
SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Пароль должен быть длиной от 4 символов."})
is_na = true;
end

char = string.sub(pin,1,1);
pin2 = "";
for i=1,string.len(pin) do
pin2 = pin2..char;
end

if pin == pin2 then
SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Введенный пароль состоит из одного и того же символа. Ввиду низкой надежности ввод будет отклонен, попробуйте еще раз."})
is_na = true;
end

if is_na then sleep(1) end;
end

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Пароль принят, спасибо."})

sleep(1);
return pin

end

function validate_pin(pin2)

local pin;
local is_na = true;

while is_na do

is_na = false;

pin = SendAndWaitForMessage({action = "read", term_clear = true, set_cursor = true, is_secure = true, posx = 1, posy = 1, text = "Пожалуйста, для выдачи предметов введите ваш пароль:"}, 0)

if pin ~= pin2 then
SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Неверный пароль."})
is_na = true;
end

if is_na then sleep(1) end;
end

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Пароль принят, спасибо."})

sleep(1);
return 0

end

--programm begin
--colors:
-- colors.white 	1 	0x1 	0000000000000001
-- colors.orange 	2 	0x2 	0000000000000010
	-- colors.magenta 	4 	0x4 	0000000000000100
	-- colors.lightBlue 	8 	0x8 	0000000000001000
-- colors.yellow 	16 	0x10 	0000000000010000
-- colors.lime 	32 	0x20 	0000000000100000
	-- colors.pink 	64 	0x40 	0000000001000000
-- colors.gray 	128 	0x80 	0000000010000000
	-- colors.lightGray 	256 	0x100 	0000000100000000
-- colors.cyan 	512 	0x200 	0000001000000000
-- colors.purple 	1024 	0x400 	0000010000000000
-- colors.blue 	2048 	0x800 	0000100000000000
	-- colors.brown 	4096 	0x1000 	0001000000000000
-- colors.green 	8192 	0x2000 	0010000000000000
-- colors.red 	16384 	0x4000 	0100000000000000
-- colors.black 	32768 	0x8000 	1000000000000000 

local sel
local pin
local last_msg
local charge_time = 0
client_id = 6484
InCounter = 0
OutCounter = 0

--os.pullEvent = os.pullEventRaw;
rednet.open("left")

if fs.exists("machines_start") then --В прошлый раз не закончили
redstone.setBundledOutput("back", 0)

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "В процессе работы возникла критическая ошибка. Пожалуйста, обратитесь к администрации магазина.\n\nПриносим извенения за причененные неудобства."})

while 1 do
WaitForMessages()
end

end

if fs.exists("machines_log") then
glog = load("machines_log")
else
glog = {}
end

table.insert(glog, {id = #glog + 1})

redstone.setBundledOutput("back", colors.purple)

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Добро пожаловать!\n\nДля начала работы сядьте, пожалуйста, в вагонетку."})

while not colors.test(rs.getBundledInput("back"), colors.black) do
WaitForMessages()
end

redstone.setBundledOutput("back", colors.cyan)

sel = SendAndWaitForMessage({action = "VertMenu", menu_table = {"1. Зарядка", "Выход"}, menu_path = "Главное меню"}, 60)

if sel == -1 then return end

if sel == 2 then
os.reboot()
end

login = SendAndWaitForMessage({action = "read", term_clear = true, set_cursor = true, is_secure = false, posx = 1, posy = 1, text = "Пожалуйста, введите ваш игровой логин.\nВ случае возникновения технических трудностей, либо других проблем, ваш игровой логин поможет вам вернуть ваши вещи:"}, 60)

if login == -1 then return end

pin = type_pin();

if pin == -1 then return end

if sel == 1 then --если зарядка, запрашиваем время
while (charge_time < 1 or charge_time > 5) and charge_time ~= -1 do
charge_time = SendAndWaitForMessage({action = "read", term_clear = true, set_cursor = true, is_secure = false, posx = 1, posy = 1, text = "Пожалуйста, введите время в минутах, в течение которого будет заряжаться ваши вещи (от 1 до 5 минут):"}, 60)

if tonumber(charge_time) == nil then charge_time = 0 end

charge_time = tonumber(charge_time)
if charge_time == -1 then return end
end
glog[#glog]["charge_time"] = charge_time
charge_time = charge_time * 60
end --если зарядка, запрашиваем время

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Пожалуйста, подождите."})

local http1 = http.get("http://www.timeapi.org/d/now?%5Cd.%5Cm.%5CY%2520%5CH%3A%5CM%3A%5CS")
tdate = http1.readAll()
http1.close()

if tdate == nil then tdate = "" end

glog[#glog]["date"] = tdate
glog[#glog]["login"] = login
glog[#glog]["pin"] = pin
glog[#glog]["status"] = 0
glog[#glog]["is_done"] = 0
glog[#glog]["line"] = sel

local file = fs.open("machines_start","w")
file.close()

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Пожалуйста, бросьте предметы в окно загрузки, в сторону зеленого света, после чего покиньте вагонетку."})

if colors.test(rs.getBundledInput("back"), colors.black) then
rs.setBundledOutput("back", colors.combine(colors.white, colors.cyan))
else
os.reboot()
end  

glog[#glog]["status"] = 1

while colors.test(rs.getBundledInput("back"), colors.black) do
WaitForMessages()
end

redstone.setBundledOutput("back", 0) --закрываем окно загрузки
glog[#glog]["status"] = 2

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Предметы загружены, обработка."})

--включаю нужную линию
if sel == 1 then 
rs.setBundledOutput("back", colors.green)
elseif sel == 2 then
redstone.setBundledOutput("back", colors.yellow)
elseif sel == 3 then
redstone.setBundledOutput("back", colors.pink)
elseif sel == 4 then
redstone.setBundledOutput("back", colors.grey)
elseif sel == 5 then
redstone.setBundledOutput("back", colors.lime)
elseif sel == 6 then
redstone.setBundledOutput("back", colors.brown)
elseif sel == 7 then
redstone.setBundledOutput("back", colors.purple)
end

glog[#glog]["status"] = 3

--счетчики
local finish_counter = 0;
local is_stop = false;
local timer = os.startTimer(1);
local is_show = false;
local op_timer = 0
local is_eject = false

if sel == 1 then 
op_timer = charge_time
SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Поступило на обработку:\n0\nОбработано:\n0\nЗарядка (секунд)\n"..tostring(op_timer)})
else
SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Поступило на обработку:\n0\nОбработано:\n0"})
end

while not is_stop do

local sEvent, param1 = os.pullEvent()

if sEvent == "timer" and param1 == timer then

if is_eject then
is_eject = false
rs.setBundledOutput("back", colors.green)
end

if InCounter > OutCounter then
SendMessage({action = "print", term_clear = false, set_cursor = true, posx = 1, posy = 2, text = InCounter})
SendMessage({action = "print", term_clear = false, set_cursor = true, posx = 1, posy = 4, text = OutCounter})

local op_timer_str = ""
if op_timer < 10 then 
op_timer_str = "0"..tostring(op_timer)
else
op_timer_str = tostring(op_timer)
end

SendMessage({action = "print", term_clear = false, set_cursor = true, posx = 1, posy = 6, text = op_timer_str})
end

if InCounter <= OutCounter then
if not is_show and InCounter ~=0 and OutCounter ~= 0 then
is_show=true;
SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Пожалуйста, подождите. Подготовка к выдаче."})
end
finish_counter = finish_counter + 1;
if finish_counter > 15 then is_stop = true end;  
end

op_timer = op_timer - 1 --таймер задержки в приборе
if op_timer <= 0 then

if sel == 1 then 
op_timer = charge_time
if not is_eject then
is_eject = true
rs.setBundledOutput("back", colors.combine(colors.green, colors.lime))
end

end

glog[#glog]["status"] = 35
end --таймер задержки в приборе

timer = os.startTimer(1)
end

    if sEvent == "redstone" and colors.test(rs.getBundledInput("back"), colors.red) then
    InCounter = InCounter + 1;
	finish_counter = 0;
	glog[#glog]["InCounter"] = InCounter
    end

    if sEvent == "redstone" and colors.test(rs.getBundledInput("back"), colors.blue) then
    OutCounter = OutCounter + 1;
	finish_counter = 0;
	glog[#glog]["OutCounter"] = OutCounter
    end	

end

glog[#glog]["status"] = 4

redstone.setBundledOutput("back",  colors.gray) --останавливаем линии, включаем возврат некондиции
SleepAndWaitForMessages(15)

glog[#glog]["status"] = 45

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Обработка завершена."})

redstone.setBundledOutput("back", 0) --останавливаем линии

glog[#glog]["status"] = 5

validate_pin(pin); --запрашиваем и проверяем пароль

glog[#glog]["status"] = 6

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Для начала выдачи, сядьте, пожалуйста, в вагонетку."})

while not colors.test(rs.getBundledInput("back"), colors.black) do
WaitForMessages()
end

glog[#glog]["status"] = 7

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "После того, как вы получили все свои предметы, пожалуйста, покиньте вагонетку.\n\nНачинаю выдачу."})

rs.setBundledOutput("back", colors.combine(colors.orange, colors.cyan))

glog[#glog]["status"] = 8

while colors.test(rs.getBundledInput("back"), colors.black) do --проверка нажимной плиты перед окном загрузки
WaitForMessages()
end

glog[#glog]["status"] = 9

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Выдача завершена, спасибо за использование сервиса."})

glog[#glog]["status"] = 10
glog[#glog]["is_done"] = 1
if glog ~= nil then save(glog, "machines_log") end
fs.delete("machines_start")

sleep(1);

os.reboot();
