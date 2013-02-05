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

local timer = os.startTimer(1) 

while 1 do

local event, param, data = os.pullEvent()

if event == "timer" and param == timer then
timeout = timeout - 1

if timeout <= -1 then timeout = -1 end
if timeout == 0 then return -1 end

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

pin = SendAndWaitForMessage({action = "read", term_clear = true, set_cursor = true, is_secure = true, posx = 1, posy = 1, text = "Пожалуйста, придумайте и введите пароль для оформления заказа в английской раскладке не менее 4 символов:"}, 30)

if pin == -1 then return -1 end

pin2 = SendAndWaitForMessage({action = "read", term_clear = true, set_cursor = true, posx = 1, posy = 1, is_secure = true, text = "Введите пароль еще раз для подтверждения:"}, 30)

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

pin = SendAndWaitForMessage({action = "read", term_clear = true, set_cursor = true, is_secure = true, posx = 1, posy = 1, text = "Пожалуйста, для выдачи предметов введите ваш пароль:"}, -1)

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

client_id = 6484
local sel
local pin
local last_msg
local charge_time = 0
local InCounter = 0
local AddCounter = 0
local UnprocessedCounter = 0
local OutCounter = 0
local InCounter_id = 6577
local AddCounter_id = 6587
local OutCounter_id = 6575
local is_all_detectors = false

--os.pullEvent = os.pullEventRaw;
rednet.open("left")

if fs.exists("machines_start") then --В прошлый раз не закончили
redstone.setBundledOutput("back", 0)

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "В процессе работы возникла критическая ошибка. Пожалуйста, обратитесь к администрации магазина.\n\nПриносим извинения за причененные неудобства."})

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

while not rs.testBundledInput("back", colors.black) do
WaitForMessages()
end

redstone.setBundledOutput("back", colors.cyan)

--проверка датчиков
SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Пожалуйста, подождите. Выполняется проверка готовности системы к работе."})
rednet.broadcast(textutils.serialize({action = "ping"}))
local timer = os.startTimer(2)

while not is_all_detectors do --while

local event, param = os.pullEvent()

if event == "timer" and param == timer then --timer_event
redstone.setBundledOutput("back", colors.purple)
SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Один из компонентов системы не отвечает, сервис временно недоступен. Попробуйте, пожалуйста, позже.\n\nПриносим извинения за неудобства."})
sleep(10)
os.reboot()
end --timer_event

if event == "rednet_message" then --rednet_message

if param == InCounter_id then
InCounter = InCounter + 1
end

if param == AddCounter_id then
AddCounter = AddCounter + 1
end

if param == OutCounter_id then
OutCounter = OutCounter + 1
end

end

if InCounter > 0 and AddCounter > 0 and OutCounter > 0 then
is_all_detectors = true
end
end

InCounter = 0
AddCounter = 0
OutCounter = 0
--end проверка датчиков

sel = SendAndWaitForMessage({action = "VertMenu", menu_table = {"1. Зарядка", "2. Дробилка + печь", "Выход"}, menu_path = "Главное меню"}, 30)

if sel == -1 or sel == 3 then

if rs.testBundledInput("back", colors.black) then
SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Пожалуйста, покиньте вагонетку."})
end

while rs.testBundledInput("back", colors.black) do
WaitForMessages()
end  

os.reboot()
end

login = SendAndWaitForMessage({action = "read", term_clear = true, set_cursor = true, is_secure = false, posx = 1, posy = 1, text = "Пожалуйста, введите ваш игровой логин в английской раскладке.\nВ случае возникновения технических трудностей, либо других проблем, ваш игровой логин поможет вам вернуть ваши вещи:"}, 30)

if login == -1 then
os.reboot()
end

pin = type_pin();

if pin == -1 then
os.reboot()
end

if sel == 1 then --если зарядка, запрашиваем время
while (charge_time < 30 or charge_time > 120) and charge_time ~= -1 do
charge_time = SendAndWaitForMessage({action = "read", term_clear = true, set_cursor = true, is_secure = false, posx = 1, posy = 1, text = "Пожалуйста, введите время в секундах, в течение которого будет заряжаться каждый предмет (от 30 до 120 секунд):"}, 30)

if tonumber(charge_time) == nil then charge_time = 0 end

charge_time = tonumber(charge_time)
if charge_time == -1 then
os.reboot()
end
end
glog[#glog]["charge_time"] = charge_time
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

if not rs.testBundledInput("back", colors.black) then
SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Пожалуйста, сядьте в вагонетку и не покидайте ее пока не загрузите все предметы."})
end

while not rs.testBundledInput("back", colors.black) do
WaitForMessages()
end  

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Пожалуйста, бросьте предметы в окно загрузки, в сторону зеленого света, после чего покиньте вагонетку."})

if rs.testBundledInput("back", colors.black) then
rs.setBundledOutput("back", colors.combine(colors.white, colors.cyan))
end  

glog[#glog]["status"] = 1

while rs.testBundledInput("back", colors.black) do
WaitForMessages()
end

redstone.setBundledOutput("back", 0) --закрываем окно загрузки
glog[#glog]["status"] = 2

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Предметы загружены, обработка."})

--включаю нужную линию
if sel == 1 then 
rs.setBundledOutput("back", colors.green)
elseif sel == 2 then
redstone.setBundledOutput("back", colors.lightBlue)
redstone.setBundledOutput("right", colors.white)
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
op_timer = 15
SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Поступило на обработку:\n0\nОбработано:\n0\nЗарядка (секунд):\n"..tostring(charge_time)})
else
SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Поступило на обработку:\n0\nПринято к обработке:\n0\nОтброшено:\n0\nОбработано:\n0"})
end

while not is_stop do

local sEvent, param, data = os.pullEvent()

if sEvent == "rednet_message" then

print("Receive message: "..data.."\n")
msg = textutils.unserialize(data)

if param == InCounter_id then
InCounter = InCounter + msg.count
finish_counter = 0
end

if param == AddCounter_id then
AddCounter = AddCounter + msg.count
UnprocessedCounter = UnprocessedCounter + msg.unprocessed_count
finish_counter = 0
end

if param == OutCounter_id then
OutCounter = OutCounter + msg.count
finish_counter = 0
end

end

if sEvent == "timer" and param == timer then

glog[#glog]["InCounter"] = InCounter
glog[#glog]["AddCounter"] = AddCounter
glog[#glog]["UnprocessedCounter"] = UnprocessedCounter
glog[#glog]["OutCounter"] = OutCounter

if is_eject then
is_eject = false
rs.setBundledOutput("back", colors.green)
end

if (InCounter + AddCounter) > OutCounter then

if sel == 1 then
SendMessage({action = "print", term_clear = false, set_cursor = true, posx = 1, posy = 2, text = InCounter})
SendMessage({action = "print", term_clear = false, set_cursor = true, posx = 1, posy = 4, text = OutCounter})
SendMessage({action = "print", term_clear = false, set_cursor = true, posx = 1, posy = 6, text = tostring(op_timer)})
else
SendMessage({action = "print", term_clear = false, set_cursor = true, posx = 1, posy = 2, text = InCounter})
SendMessage({action = "print", term_clear = false, set_cursor = true, posx = 1, posy = 4, text = AddCounter})
SendMessage({action = "print", term_clear = false, set_cursor = true, posx = 1, posy = 6, text = UnprocessedCounter})
SendMessage({action = "print", term_clear = false, set_cursor = true, posx = 1, posy = 8, text = OutCounter})
end

end

if (InCounter + AddCounter) <= OutCounter then
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

end

glog[#glog]["status"] = 4

redstone.setBundledOutput("back",  colors.gray) --останавливаем линии, включаем возврат некондиции
SleepAndWaitForMessages(5)

glog[#glog]["status"] = 45

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Обработка завершена."})

redstone.setBundledOutput("back", 0) --останавливаем линии
redstone.setBundledOutput("right", 0) --останавливаем линии

glog[#glog]["status"] = 5

if InCounter == 0 and OutCounter == 0 then
SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Выдавать нечего, завершиние работы."})

glog[#glog]["is_done"] = 1
glog[#glog]["status"] = 55
if glog ~= nil then save(glog, "machines_log") end
fs.delete("machines_start")

sleep(1)
os.reboot()
end	

glog[#glog]["status"] = 6

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Для начала выдачи, сядьте, пожалуйста, в вагонетку."})

while not rs.testBundledInput("back", colors.black) do
WaitForMessages()
end

rs.setBundledOutput("back", colors.cyan)

validate_pin(pin); --запрашиваем и проверяем пароль

glog[#glog]["status"] = 7

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "Для начала выдачи, сядьте, пожалуйста, в вагонетку. И не покидайте ее, пока не получили свои предметы."})

while not rs.testBundledInput("back", colors.black) do
WaitForMessages()
end

SendMessage({action = "print", term_clear = true, set_cursor = true, posx = 1, posy = 1, text = "После того, как вы получили все свои предметы, пожалуйста, покиньте вагонетку.\n\nНачинаю выдачу."})

rs.setBundledOutput("back", colors.combine(colors.orange, colors.cyan))

glog[#glog]["status"] = 8

while rs.testBundledInput("back", colors.black) do --проверка нажимной плиты перед окном загрузки
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
