local m, section, m2, s2
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
    m = Map("modem-AK68", translate("AK68已断开或未接入！请接入后重试。"))
    return m
end

m = Map("modem-AK68", translate("AK68移动网络设置"))
section = m:section(TypedSection, "ndis", translate("AK68模组设置-巴龙MT5700M"))
section.anonymous = true
section.addremove = false

section:tab("general", translate("模组参数设置"))
section:tab("advanced", translate("高级设置"))

enable = section:taboption("general", Flag, "enable", translate("启用模块"))
enable.rmempty  = false

simsel= section:taboption("general", ListValue, "simsel", translate("当前SIM卡"))
simsel:value("0", translate("外置SIM卡"))
--simsel:value("1", translate("内置SIM1"))
--simsel:value("2", translate("内置SIM2"))
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
sim_status_output = sim_status_output:match("%S+")
-- 根据输出解析 SIM 卡状态
local sim_status_description = ""
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

current_mod = section:taboption("general", Value, "current_mod", translate("外接模组"))
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
    local value = luci.sys.exec("cat /sys/class/gpio/cpe-pwr/value 2>/dev/null")
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
    local value = luci.sys.exec("cat /sys/class/gpio/cpe-pwr/value 2>/dev/null")
    value = value:match("%d") or "0"
    if value == "1" then
        os.execute("echo 0 > /sys/class/gpio/cpe-pwr/value")
    else
        os.execute("echo 1 > /sys/class/gpio/cpe-pwr/value")
    end
    refreshPoeStatus(section)
end
local apply = luci.http.formvalue("cbi.apply")
local sys = require "luci.sys"
local file = io.open("/tmp/modconf-AK68.conf", "r")
if apply then
    function m.on_commit(map)
        update_rf_mode()
    end
    if file then
        local content = file:read("*all")
        file:close()
        if content and string.find(content, "RM520") then
            --io.popen("/usr/share/modem-AK68/rm520n-AK68.sh &")
        elseif content and string.find(content, "MT5700") then
            --io.popen("/usr/share/modem-AK68/MT5700-AK68.sh &") 
            --luci.sys.exec("/usr/share/modem-AK68/MT5700-AK68.sh &") 
        end
    end
end
return m,m2

