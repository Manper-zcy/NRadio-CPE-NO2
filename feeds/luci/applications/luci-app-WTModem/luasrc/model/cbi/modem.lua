local m, section, m2, s2

m = Map("modem", translate("模组蜂窝-移动网络配置"))
section = m:section(TypedSection, "ndis", translate("移动蜂窝参数设置"))
section.anonymous = true
section.addremove = false
section:tab("general", translate("常规设置"))
section:tab("advanced", translate("高级设置"))


enable = section:taboption("general", Flag, "enable", translate("模块开关"))
enable.rmempty  = false


simsel= section:taboption("general", ListValue, "simsel", translate("卡槽选择"))
simsel:value("0", translate("外置SIM卡1"))
simsel:value("3", translate("外置SIM卡2-仅限C5800"))
simsel:value("4", translate("外置SIM卡3-仅限C5800"))
simsel:value("5", translate("外置SIM卡4-仅限C5800"))
simsel:value("1", translate("内置SIM1"))
simsel:value("2", translate("内置SIM2"))
simsel.rmempty = true

pincode = section:taboption("general", Value, "pincode", translate("PIN-密码"))
pincode.default=""
------
apnconfig = section:taboption("general", Value, "apnconfig", translate("APN配置"))
apnconfig.rmempty = true

------
local cmd = io.popen("cat /tmp/modconf.conf")
local content = cmd:read("*all") or ""
cmd:close()
if (content and string.find(content, "RM520")) or (content and string.find(content, "RM500U")) then
    -- RM520NSIN卡状态查询
    sim_card_stat = section:taboption("general", DummyValue, "sim_card_stat", translate("SIM状态"))
    sim_card_stat.value = luci.sys.exec("cat /tmp/simcardstat")
else
    -- RM520NSIN卡状态查询
    sim_card_stat = section:taboption("general", DummyValue, "sim_card_stat", translate("SIM状态"))

    local sim_status_output =luci.sys.exec("cat /tmp/simcardstat")
    local sim_status_output = luci.sys.exec("sendat 1 'AT^SIMSQ?' | awk '/^\\^SIMSQ:/ {split($0, a, \",\"); print a[2]}'")
    if sim_status_output == "" then
        local sim_status_description = "未获取到值,请刷新。"
    else
        sim_status_output = sim_status_output:match("%S+")
    end
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
        sim_card_stat.value = sim_status_description
    end
    -- MT5700SIN卡状态查询

current_mod = section:taboption("general", Value, "current_mod", translate("当前模组"))
current_mod.rmempty = true
current_mod.default = ""

function current_mod.cfgvalue(self, section)
    if nixio.fs.access("/tmp/modconf.conf") then
        return luci.sys.exec("cat /tmp/modconf.conf")
    else
        return "未知模块或未接入模式"
    end
end
------------


smode = section:taboption("advanced", ListValue, "smode", translate("网络制式"))
smode.default = "0"
smode:value("0", translate("自动"))
smode:value("1", translate("4G网络"))
smode:value("2", translate("5G网络"))

if (content and string.find(content, "RM520")) or (content and string.find(content, "RM500U")) then
    nrmode = section:taboption("advanced", ListValue, "nrmode", translate("5G模式"))
    nrmode:value("0", translate("SA/NSA双模"))
    nrmode:value("1", translate("SA模式"))
    nrmode:value("2", translate("NSA模式"))
    nrmode:depends("smode","2")
else
    nrmode = section:taboption("advanced", ListValue, "nrmode", translate("5G模式"))
    nrmode:value("1", translate("SA模式"))
    nrmode:depends("smode","2")
end


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

if (content and string.find(content, "RM520")) or (content and string.find(content, "RM500U")) then
bandlist_nsa = section:taboption("advanced", ListValue, "bandlist_nsa", translate("5G-NSA频段"))
bandlist_nsa.default = "0"
bandlist_nsa:value("0", translate("自动"))
bandlist_nsa:value("41", translate("BAND 41"))
bandlist_nsa:value("78", translate("BAND 78"))
bandlist_nsa:value("79", translate("BAND 79"))
bandlist_nsa:depends("nrmode","2")
end


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

--turnonipv6 = section:taboption("advanced", Flag, "turnonipv6", translate("打开ipv6"))
--turnonipv6.rmempty = true
--turnonipv6.default = 1

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

local cmd2 = io.popen("cat /tmp/modconf.conf")
local content = cmd2:read("*all") or ""
cmd2:close()

if (content and string.find(content, "MT5700")) or (content and string.find(content, "5700")) then
    enable_imei = section:taboption("advanced", Flag, "enable_imei", translate("MT5700修改IMEI"))
    enable_imei.default = false
    enable_imei.rmempty = true
    enable_imei:depends("simsel", "0")

    modify_imei = section:taboption("advanced", Value, "modify_imei", translate("IMEI"))
    modify_imei.default = luci.sys.exec("sendat 1 AT+CGSN | sed -n '2p'")
    modify_imei:depends("enable_imei", "1")
    modify_imei.validate = function(self, value)
       if not value:match("^%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d$") then
           return nil, translate("IMEI必须是15位数字")
      end
      return value
end

end

if (content and string.find(content, "520")) or (content and string.find(content, "RM520")) then
    enable_imei = section:taboption("advanced", Flag, "enable_imei", translate("修改IMEI"))
    enable_imei.default = false
    enable_imei.rmempty = true
    enable_imei:depends("simsel", "0")

    modify_imei = section:taboption("advanced", Value, "modify_imei", translate("IMEI"))
    modify_imei.default = luci.sys.exec("sendat 2 'AT+CGSN'| grep -oE '[0-9]+'")
    modify_imei:depends("enable_imei", "1")
    modify_imei.validate = function(self, value)
        if not value:match("^%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d$") then
            return nil, translate("IMEI必须是15位数字")
        end
        return value
    end           
end


local cmd2 = io.popen("cat /tmp/modconf.conf")
local content2 = cmd2:read("*all") or ""
cmd2:close()

--Check if the content is not empty
if content2 ~= "" then
    --Check if the content contains "RM520"
   if string.find(content2, "RM520") then
       section:tab("nativeipv6", translate("RM520N原生IPV6"), translate("模组RM520N功能，用于启用模块的原生IPV6支持。如需启用直接在当前页面点击保存按钮后等待至少1分钟再刷新页面观察是否连接成功"))
   else
      if string.find(content2, "MT5700") then
          section:tab("nativeipv6", translate("巴龙MT5700-IPV6"), translate("MT5700M模组默认开启了IPV6设置，不需要设置以下参数！"))
      end
       --section:tab("nativeipv6"):addoption("note", translate("当前模组暂不支持IPV6设置"))
   end
else
   section:tab("nativeipv6", translate("未检测到模组信息或不支持"), translate("当前未检测到模组信息，请不要操作以下参数。"))
end

if content2 ~= "" then
    --Check if the content contains "RM520"
   if string.find(content2, "RM520") then
    adbkey = section:taboption("nativeipv6", DummyValue, "adbkey", translate("模块解锁请求码"))
    local adbkey_value = luci.sys.exec("sendat 2 'at+qadbkey?' | grep '+QADBKEY:' | awk -F ' ' '{print $2}' | tr -d '\r\n'")
    luci.sys.exec("logger 'adbkey_value: " .. adbkey_value .. "'")
    adbunlockkey = section:taboption("nativeipv6", Value, "adbunlockkey", translate("自动计算的ADB解锁码："))
    if adbkey_value ~= "" then
        adbkey.value = adbkey_value
        local adbunlockkey_value = luci.sys.exec("RMUnlock " .. adbkey_value .. " | tr -d '\r\n'")
        luci.sys.exec("logger 'adbunlockkey_value: " .. adbunlockkey_value .. "'")
        adbunlockkey.default = adbunlockkey_value  -- 使用 default 来初始化默认值
    else
        adbkey.value = "未获取到解锁请求码"
    end
    adb_status = section:taboption("nativeipv6", DummyValue, "adb_status", translate("模块ADB状态"))
    local adb_value = luci.sys.exec("adb devices | awk 'NR>1 {print $1}' | head -n -1")
    adb_status.value = (adb_value ~= "" and adb_value) or "设备ADB连接失败"
    adb_status.description = "模块成功启用adb后此处会出现设备标识，请务必看到设备标识后再启用IPV6!"
    enable_native_ipv6 = section:taboption("nativeipv6", Flag, "enable_native_ipv6", translate("启用原生IPV6支持"))
    if adb_value == "" then
        enable_native_ipv6.readonly = true
    end
    nativeIPV6_status = section:taboption("nativeipv6", DummyValue, "nativeIPV6_status", translate("IPV6状态"))
    local nativeIPV6_status_value = luci.sys.exec("cat /tmp/ipv6prefix")
    nativeIPV6_status.value = (nativeIPV6_status_value ~= "" and nativeIPV6_status_value) or "Native IPV6未使能"
    module_uptime = section:taboption("nativeipv6", DummyValue, "module_uptime", translate("模块运行时间"))
    module_uptime.value = luci.sys.exec("adb shell uptime") 
   else
    adbkey = section:taboption("nativeipv6", DummyValue, "adbkey", translate("请尝试开启中继后使用IPV6通信。"))
    --local adbkey_value ="当前IPV6已开启，请尝试打开中继使用IPV6通信。"
   end
end  

local apply = luci.http.formvalue("cbi.apply")
local sys = require "luci.sys"
local file = io.open("/tmp/modconf.conf", "r")
if apply then
    if file then
        local content = file:read("*all")
        file:close()
        if content and string.find(content, "RM520") then
            io.popen("/usr/share/modem/rm520n.sh &")
        elseif content and string.find(content, "RM500U") then
            io.popen("/usr/share/modem/500U.sh &")  
            sys.call("/sbin/ifup wan")
            sys.call("/sbin/ifup wan6")
        elseif content and string.find(content, "MT5700") then
			io.popen("/usr/share/modem/mt5700m.sh &")     
        end
    end
end
return m,m2

