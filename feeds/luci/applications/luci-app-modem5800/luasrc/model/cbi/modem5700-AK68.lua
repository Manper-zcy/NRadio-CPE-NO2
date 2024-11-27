local m, section, m2, s2

local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"
local fs = require "nixio.fs"

-- 日志函数
local function log(message)
    fs.writefile("/tmp/moduleInit-AK68", message .. "\n", "a")
end

-- 执行AT命令函数
local function execute_at_command(command)
    local result = sys.exec(command)
    log("执行命令: " .. command)
    log("命令输出: " .. result)
    return result
end

-- GPIO设置函数
local function set_gpio(pin, value)
    local gpio_path = "/sys/class/gpio/" .. pin .. "/value"
    fs.writefile(gpio_path, tostring(value))
    log("设置GPIO: " .. pin .. " 为 " .. value)
end

local nixio = require "nixio"

-- 使用 nixio 来实现 sleep
local function sleep(seconds)
    nixio.nanosleep(seconds)
end

-- SIM选择逻辑
local function select_sim(simSel)
    log("当前SIM选择: " .. tostring(simSel))
    if simSel == "0" then
        set_gpio("cpe-sel3", 1)
        set_gpio("cpe-sel2", 0)
        set_gpio("cpe-sel1", 1)
        set_gpio("cpe-sel0", 0)
        execute_at_command("atsd_tools_cli -i cpe -c 'AT^SCICHG=0,1'")
        sleep(2)
        execute_at_command("atsd_tools_cli -i cpe -c 'HVSST=1,0'")
        execute_at_command("atsd_tools_cli -i cpe -c 'HVSST=1,1'")
        execute_at_command("atsd_tools_cli -i cpe -c 'AT+CFUN=0'")
        execute_at_command("atsd_tools_cli -i cpe -c 'AT+CFUN=1'")
        fs.writefile("/tmp/sim_sel-AK68", "0")
    elseif simSel == "1" then
        set_gpio("cpe-sel3", 1)
        set_gpio("cpe-sel2", 1)
        set_gpio("cpe-sel1", 1)
        set_gpio("cpe-sel0", 1)
        execute_at_command("atsd_tools_cli -i cpe -c 'AT^SCICHG=1,0'")
        sleep(2)
        execute_at_command("atsd_tools_cli -i cpe -c 'HVSST=1,0'")
        execute_at_command("atsd_tools_cli -i cpe -c 'HVSST=1,1'")
        execute_at_command("atsd_tools_cli -i cpe -c 'AT+CFUN=0'")
        execute_at_command("atsd_tools_cli -i cpe -c 'AT+CFUN=1'")
        fs.writefile("/tmp/sim_sel-AK68", "1")
    elseif simSel == "2" then
        set_gpio("cpe-sel3", 0)
        set_gpio("cpe-sel2", 1)
        set_gpio("cpe-sel1", 1)
        set_gpio("cpe-sel0", 1)
        execute_at_command("atsd_tools_cli -i cpe -c 'AT^SCICHG=1,0'")
        sleep(2)
        execute_at_command("atsd_tools_cli -i cpe -c 'HVSST=1,0'")
        execute_at_command("atsd_tools_cli -i cpe -c 'HVSST=1,1'")
        execute_at_command("atsd_tools_cli -i cpe -c 'AT+CFUN=0'")
        execute_at_command("atsd_tools_cli -i cpe -c 'AT+CFUN=1'")
        fs.writefile("/tmp/sim_sel-AK68", "2")
    elseif simSel == "3" then
        set_gpio("cpe-sel3", 1)
        set_gpio("cpe-sel2", 1)
        set_gpio("cpe-sel1", 1)
        set_gpio("cpe-sel0", 0)
        execute_at_command("atsd_tools_cli -i cpe -c 'AT^SCICHG=0,1'")
        sleep(2)
        execute_at_command("atsd_tools_cli -i cpe -c 'HVSST=1,0'")
        execute_at_command("atsd_tools_cli -i cpe -c 'HVSST=1,1'")
        execute_at_command("atsd_tools_cli -i cpe -c 'AT+CFUN=0'")
        execute_at_command("atsd_tools_cli -i cpe -c 'AT+CFUN=1'")
        fs.writefile("/tmp/sim_sel-AK68", "3")
    elseif simSel == "4" then
        set_gpio("cpe-sel3", 1)
        set_gpio("cpe-sel2", 1)
        set_gpio("cpe-sel1", 1)
        set_gpio("cpe-sel0", 1)
        execute_at_command("atsd_tools_cli -i cpe -c 'AT^SCICHG=0,1'")
        sleep(2)
        execute_at_command("atsd_tools_cli -i cpe -c 'HVSST=1,0'")
        execute_at_command("atsd_tools_cli -i cpe -c 'HVSST=1,1'")
        execute_at_command("atsd_tools_cli -i cpe -c 'AT+CFUN=0'")
        execute_at_command("atsd_tools_cli -i cpe -c 'AT+CFUN=1'")
        fs.writefile("/tmp/sim_sel-AK68", "4")
    elseif simSel == "5" then
        set_gpio("cpe-sel3", 1)
        set_gpio("cpe-sel2", 1)
        set_gpio("cpe-sel1", 0)
        set_gpio("cpe-sel0", 1)
        execute_at_command("atsd_tools_cli -i cpe -c 'AT^SCICHG=0,1'")
        sleep(2)
        execute_at_command("atsd_tools_cli -i cpe -c 'HVSST=1,0'")
        execute_at_command("atsd_tools_cli -i cpe -c 'HVSST=1,1'")
        execute_at_command("atsd_tools_cli -i cpe -c 'AT+CFUN=0'")
        execute_at_command("atsd_tools_cli -i cpe -c 'AT+CFUN=1'")
        fs.writefile("/tmp/sim_sel-AK68", "5")
        -- 添加其余的条件和GPIO设置
    end
    set_gpio("cpe-sel3", 1)
    set_gpio("cpe-sel2", 0)
    set_gpio("cpe-sel1", 1)
    set_gpio("cpe-sel0", 0)
    execute_at_command("atsd_tools_cli -i cpe -c 'AT^SCICHG=0,1'")
    sleep(2)
    execute_at_command("atsd_tools_cli -i cpe -c 'HVSST=1,0'")
    execute_at_command("atsd_tools_cli -i cpe -c 'HVSST=1,1'")
    execute_at_command("atsd_tools_cli -i cpe -c 'AT+CFUN=0'")
    execute_at_command("atsd_tools_cli -i cpe -c 'AT+CFUN=1'")
    fs.writefile("/tmp/sim_sel-AK68", "6")
    -- 添加更多的逻辑处理其他SIM选择
end

-- 配置提交时的处理函数
function handle_sim_selection(self, section)
    local simSel = uci:get("modem-AK68", "@ndis[0]", "simsel") or "0"
    select_sim(simSel)
end

-- 检查配置文件内容并返回模块类型
local function get_module_type()
    local file = io.open("/tmp/modconf-AK68.conf", "r")
    local module_type = nil
    if file then
        local content = file:read("*all")
        file:close()
        if content and string.find(content, "MT5700") then
            module_type = "MT5700"
        end
    end
    return module_type
end

function update_rf_mode()
    local uci = require "luci.model.uci".cursor()
    local RF_Mode = uci:get("modem-AK68", "@ndis[0]", "smode") or "0"
    local RF_Mode_file = "/tmp/RF_Mode-AK68"
    local fs = require "nixio.fs"
    local last_RF_Mode = fs.readfile(RF_Mode_file) or "-1"
    if RF_Mode ~= last_RF_Mode then
        local sys = require "luci.sys"
        local command
        if RF_Mode == "0" then
            command = 'atsd_tools_cli -i cpe -c \'AT^SYSCFGEX="080302",2000000680380,1,2,1E200000095,,\''
            sys.exec(command .. " >> /tmp/moduleInit-AK68")
            fs.writefile("/tmp/moduleInit-AK68", "RF_Mode: " .. RF_Mode .. " 自动网络\n")
        elseif RF_Mode == "1" then
            command = 'atsd_tools_cli -i cpe -c \'AT^SYSCFGEX="03",2000000680380,1,2,1E200000095,,\''
            sys.exec(command .. " >> /tmp/moduleInit-AK68")
            fs.writefile("/tmp/moduleInit-AK68", "RF_Mode: " .. RF_Mode .. " 4G网络\n")
        elseif RF_Mode == "2" then
            command = 'atsd_tools_cli -i cpe -c \'AT^SYSCFGEX="08",2000000680380,1,2,1E200000095,,\''
            sys.exec(command .. " >> /tmp/moduleInit-AK68")
            sys.exec('atsd_tools_cli -i cpe -c \'AT^C5GOPTION=1,1,1\'')
            fs.writefile("/tmp/moduleInit-AK68", "RF_Mode: " .. RF_Mode .. " 5G网络\n")
        end
        fs.writefile(RF_Mode_file, RF_Mode)
    else
        fs.writefile("/tmp/moduleInit-AK68", "RF_Mode未变动, 不执行操作\n")
    end
end

-- 根据模块类型设置标题
local module_type = get_module_type()
if not module_type then
    m = Map("modem-AK68", translate("已断开或未接入模组！请接入后重试。"))
    return m
end

m = Map("modem-AK68", translate("C5800/AK68移动网络设置"))
section = m:section(TypedSection, "ndis", translate("C5800/AK68模组设置-巴龙MT5700M"))
section.anonymous = true
section.addremove = false

section:tab("general", translate("模组参数设置"))
section:tab("advanced", translate("高级设置"))

enable = section:taboption("general", Flag, "enable", translate("启用模块"))
enable.rmempty  = false

simsel= section:taboption("general", ListValue, "simsel", translate("卡槽选择-仅限内置巴龙"))
simsel:value("0", translate("外置SIM卡1-仅限内置巴龙"))
simsel:value("3", translate("外置SIM卡2-仅限内置巴龙"))
simsel:value("4", translate("外置SIM卡3-仅限内置巴龙"))
simsel:value("5", translate("外置SIM卡4-仅限内置巴龙"))
simsel:value("1", translate("内置SIM1-仅限内置巴龙"))
simsel:value("2", translate("内置SIM2-仅限内置巴龙"))

simsel.rmempty = true
------------
smode = section:taboption("general", ListValue, "smode", translate("网络制式"))
smode.default = "0"
smode:value("0", translate("自动"))
smode:value("1", translate("4G网络"))
smode:value("2", translate("5G网络"))

--sim_card_stat = section:taboption("general", DummyValue, "sim_card_stat", translate("SIM卡状态"))
--sim_card_stat.value = luci.sys.exec("cat /tmp/simcardstat-AK68")
sim_card_stat = section:taboption("general", DummyValue, "sim_card_stat", translate("SIM卡状态"))
-- 执行命令并获取输出
local sim_status_output =luci.sys.exec("cat /tmp/simcardstat-AK68")
local sim_status_output = luci.sys.exec("atsd_tools_cli -i cpe -c 'AT^SIMSQ?' | awk '/^\\^SIMSQ:/ {split($0, a, \",\"); print a[2]}'")
if sim_status_output == "" then
    local sim_status_description = "未获取到值,请刷新。"
else
    sim_status_output = sim_status_output:match("%S+")
end
-- 根据输出解析 SIM 卡状态
local sim_status_description = "未获取到值,请刷新。"
if sim_status_output == "0" then
    sim_status_description = "状态码:0 -SIM卡未插入"
elseif sim_status_output == "1" then
    sim_status_description = "状态码:1 -SIM卡已插入"
elseif sim_status_output == "2" then
    sim_status_description = "状态码:2 -SIM卡被锁"
elseif sim_status_output == "3" then
    sim_status_description = "状态码:3-SIMLOCK 锁定(暂不支持上报)"
elseif sim_status_output == "10" then
    sim_status_description = "状态码:10-卡文件正在初始化 SIM Initializing"
elseif sim_status_output == "11" then
    sim_status_description = "状态码:11-SIN卡已经正常 （可接入网络）"
elseif sim_status_output == "12" then
    sim_status_description = "状态码:12 -SIM卡正常工作"
elseif sim_status_output == "98" then
    sim_status_description = "状态码:98 -卡物理失效 （PUK锁死或者卡物理失效）"
elseif sim_status_output == "99" then
    sim_status_description = "状态码:99 -卡移除 SIM removed"
elseif sim_status_output == "Note2" then
    sim_status_description = "状态码:Note2 -不支持虚拟SIM卡"
elseif sim_status_output == "100" then
    sim_status_description = "状态码:100 -卡错误（初始化过程中，卡失败）"
elseif sim_status_output == "" then
    sim_status_description = "未获取到值,请刷新。"
else
    sim_status_description = "状态码:"..sim_status_output.."  请参考AT手册"
end
-- 将描述设置为选项的值
sim_card_stat.value = sim_status_description

current_mod = section:taboption("general", Value, "current_mod", translate("当前模组"))
current_mod.rmempty = true
current_mod.default = ""

function current_mod.cfgvalue(self, section)
    if nixio.fs.access("/tmp/modconf-AK68.conf") then
        return luci.sys.exec("cat /tmp/modconf-AK68.conf")
    else
        return "未知模块或未接入AK68模式"
    end
end
-- POE设置
local poe_status = section:taboption("general", Button, "poe_control", translate("正在加载..."))
function refreshPoeStatus(section)
    local value = luci.sys.exec("cat /sys/class/gpio/cpe1-pwr/value 2>/dev/null")
    value = value:match("%d") or "0"

    if value == "1" then
        poe_status.title = translate("POE供电状态")
        poe_status.inputtitle = translate("POE正在供电(点击关闭POE供电)")
    else
        poe_status.title = translate("POE供电状态")
        poe_status.inputtitle = translate("POE未供电(点击打开POE供电)")
    end
end

function poe_status.render(self, section)
    refreshPoeStatus(section)
    Button.render(self, section)
end

function poe_status.write(self, section)
    local value = luci.sys.exec("cat /sys/class/gpio/cpe1-pwr/value 2>/dev/null")
    value = value:match("%d") or "0"
    if value == "1" then
        os.execute("echo 0 > /sys/class/gpio/cpe1-pwr/value")
    else
        os.execute("echo 1 > /sys/class/gpio/cpe1-pwr/value")
    end
    refreshPoeStatus(section)
end
local apply = luci.http.formvalue("cbi.apply")
local sys = require "luci.sys"
local file = io.open("/tmp/modconf-AK68.conf", "r")
if apply then
    --handle_sim_selection()
    --function m.on_commit(map)
        --update_rf_mode()
    --end
    if file then
        local content = file:read("*all")
        file:close()
        if content and string.find(content, "RM520") then
            --io.popen("/usr/share/modem-AK68/rm520n-AK68.sh &")
        elseif content and string.find(content, "MT5700") then
            --io.popen("/usr/share/modem-AK68/MT5700-AK68.sh &") 
            luci.sys.exec("/usr/share/modem-AK68/MT5700-AK68.sh &") 
        end
    end
end
return m,m2


