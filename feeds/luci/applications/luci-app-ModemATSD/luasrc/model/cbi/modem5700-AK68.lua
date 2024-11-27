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
simsel:value("1", translate("内置SIM1"))
--simsel:value("2", translate("内置SIM2"))
simsel.rmempty = true

------------
pincode = section:taboption("general", Value, "pincode", translate("PIN-密码"))
pincode.default=""
------
apnconfig = section:taboption("general", Value, "apnconfig", translate("APN配置"))
apnconfig.rmempty = true


-------------------------------------------------
smode = section:taboption("advanced", ListValue, "smode", translate("网络制式"))
smode.default = "0"
smode:value("0", translate("自动"))
smode:value("1", translate("4G网络"))
smode:value("2", translate("5G网络"))

nrmode = section:taboption("advanced", ListValue, "nrmode", translate("5G模式"))
nrmode:value("1", translate("SA模式"))
nrmode:depends("smode","2")

bandlist_lte = section:taboption("advanced", ListValue, "bandlist_lte", translate("LTE频段"))
bandlist_lte.default = "0"
bandlist_lte:value("0", translate("自动"))
bandlist_lte:value("1", translate("BAND 1"))
bandlist_lte:value("3", translate("BAND 3"))
bandlist_lte:value("5", translate("BAND 5"))
bandlist_lte:value("8", translate("BAND 8"))
bandlist_lte:value("34", translate("BAND 34"))
bandlist_lte:value("38", translate("BAND 38"))
bandlist_lte:value("39", translate("BAND 39"))
bandlist_lte:value("40", translate("BAND 40"))
bandlist_lte:value("41", translate("BAND 41"))
bandlist_lte:depends("smode","1")

bandlist_sa = section:taboption("advanced", ListValue, "bandlist_sa", translate("5G-SA频段"))
bandlist_sa.default = "0"
bandlist_sa:value("0", translate("自动"))
bandlist_sa:value("1", translate("BAND 1"))
bandlist_sa:value("3", translate("BAND 3"))
bandlist_sa:value("5", translate("BAND 5"))
bandlist_sa:value("8", translate("BAND 8"))
bandlist_sa:value("28", translate("BAND 28"))
bandlist_sa:value("41", translate("BAND 41"))
bandlist_sa:value("78", translate("BAND 78"))
bandlist_sa:value("79", translate("BAND 79"))
bandlist_sa:depends("nrmode","1")

earfcn = section:taboption("advanced", Value, "earfcn", translate("频点EARFCN"))
earfcn:depends("bandlist_lte","1")
earfcn:depends("bandlist_lte","3")
earfcn:depends("bandlist_lte","5")
earfcn:depends("bandlist_lte","8")
earfcn:depends("bandlist_lte","34")
earfcn:depends("bandlist_lte","38")
earfcn:depends("bandlist_lte","39")
earfcn:depends("bandlist_lte","40")
earfcn:depends("bandlist_lte","41")

earfcn:depends("bandlist_sa","1")
earfcn:depends("bandlist_sa","3")
earfcn:depends("bandlist_sa","5")
earfcn:depends("bandlist_sa","8")
earfcn:depends("bandlist_sa","28")
earfcn:depends("bandlist_sa","41")
earfcn:depends("bandlist_sa","78")
earfcn:depends("bandlist_sa","79")

earfcn:depends("bandlist_nsa","41")
earfcn:depends("bandlist_nsa","78")
earfcn:depends("bandlist_nsa","79")

earfcn.rmempty = true

cellid = section:taboption("advanced", Value, "cellid", translate("小区PCI"))
cellid:depends("bandlist_lte","1")
cellid:depends("bandlist_lte","3")
cellid:depends("bandlist_lte","5")
cellid:depends("bandlist_lte","8")
cellid:depends("bandlist_lte","34")
cellid:depends("bandlist_lte","38")
cellid:depends("bandlist_lte","39")
cellid:depends("bandlist_lte","40")
cellid:depends("bandlist_lte","41")

cellid:depends("bandlist_sa","1")
cellid:depends("bandlist_sa","3")
cellid:depends("bandlist_sa","5")
cellid:depends("bandlist_sa","8")
cellid:depends("bandlist_sa","28")
cellid:depends("bandlist_sa","41")
cellid:depends("bandlist_sa","78")
cellid:depends("bandlist_sa","79")

cellid:depends("bandlist_nsa","41")
cellid:depends("bandlist_nsa","78")
cellid:depends("bandlist_nsa","79")
cellid.rmempty = true

dataroaming = section:taboption("advanced", Flag, "datarroaming", translate("国际漫游"),"适用于行动网路漫游的数据体验，可能会产生高昂的费用。")
dataroaming.rmempty = true

smode2 = section:taboption("advanced", ListValue, "smode2", translate("网络制式"))
smode2.default = "0"
smode2:value("0", translate("自动"))
smode2:value("1", translate("4G网络"))
smode2:value("2", translate("5G网络"))
smode2:depends("switchNetwork","1")
-----------------------------------------------------
--sim_card_stat = section:taboption("general", DummyValue, "sim_card_stat", translate("SIM卡状态"))
--sim_card_stat.value = luci.sys.exec("cat /tmp/simcardstat-AK68")
sim_card_stat = section:taboption("general", DummyValue, "sim_card_stat", translate("SIM卡状态"))
-- 执行命令并获取输出
local sim_status_output =luci.sys.exec("cat /tmp/simcardstat-AK68")
local sim_status_output = luci.sys.exec("atsd_tools_cli -i cpe -c 'AT^SIMSQ?' | awk '/^\\^SIMSQ:/ {split($0, a, \",\"); print a[2]}'")
sim_status_output = sim_status_output:match("%S+")
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
    sim_status_output = "未获取到值,请刷新。"
else

    sim_status_description = "状态码:"..sim_status_description.."  请参考AT手册"
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
local poe_status = section:taboption("advanced", Button, "poe_control", translate("正在加载..."),"POE开关仅适用于WT9111主板以上")
function refreshPoeStatus(section)
    local value = luci.sys.exec("cat /sys/class/gpio/cpe1-pwr/value 2>/dev/null")
    value = value:match("%d") or "0"

    if value == "1" then
        poe_status.title = translate("POE供电")
        poe_status.inputtitle = translate("POE正在供电(点击关闭POE供电)")
    else
        poe_status.title = translate("POE供电")
        poe_status.inputtitle = translate("POE未供电(点击打开POE供电)")
    end
end
-----------------------------
enable_imei = section:taboption("advanced", Flag, "enable_imei", translate("MT5700修改IMEI"))
enable_imei.default = false
enable_imei.rmempty = true
enable_imei:depends("simsel", "0")

modify_imei = section:taboption("advanced", Value, "modify_imei", translate("IMEI"))
modify_imei.default = luci.sys.exec("atsd_tools_cli -i cpe -c AT+CGSN | sed -n '2p'")
modify_imei:depends("enable_imei", "1")
modify_imei.validate = function(self, value)
   if not value:match("^%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d$") then
       return nil, translate("IMEI必须是15位数字")
  end
  return value
end
---------------------------------------
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
------------
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
            io.popen("/usr/share/modem-AK68/MT5700-AK68.sh &") 
            --luci.sys.exec("/usr/share/modem-AK68/MT5700-AK68.sh &") 
        end
    end
end
return m,m2


