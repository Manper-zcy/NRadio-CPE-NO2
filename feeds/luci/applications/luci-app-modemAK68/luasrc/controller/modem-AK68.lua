module("luci.controller.modem-AK68", package.seeall)
function index()
	entry({"admin", "modem-AK68"}, firstchild(), _("ATSD蜂窝"), 25).dependent = false
	local file = io.open("/tmp/modconf-AK68.conf", "r")
	local template_name = "zmode-AK68/net_status-AK68"
	local modem_cbi = "modem5700-AK68"  -- 默认设置为 modem5700-AK68
	if file then
		local content = file:read("*all")
		file:close()
		if content and string.find(content, "RM520") then
			template_name = "zmode-AK68/net_status_RM520-AK68"
			modem_cbi = "modem-AK68"
		elseif content and string.find(content, "MT5700") then
			template_name = "zmode-AK68/net_status_MT5700-AK68"
			modem_cbi = "modem5700-AK68" 
		end
	end
	entry({"admin", "modem-AK68", "nets"}, template(template_name), _("信号状态"), 97)
	entry({"admin", "modem-AK68", "at"}, template("zmode-AK68/at"), _("调试工具"), 98)
	entry({"admin", "modem-AK68", "modem"}, cbi(modem_cbi), _("模块设置"), 98) 
	entry({"admin", "modem-AK68", "get_csq"}, call("action_get_csq"))
end

function action_get_csq()
    -- 读取配置文件
    local conf_file_path = "/tmp/modconf-AK68.conf"
    local conf_file = io.open(conf_file_path, "r")
    local modem_type = nil

    if conf_file then
        modem_type = conf_file:read("*line") -- 假设需要的信息在第一行
        conf_file:close()
    else
        error("Unable to open configuration file: " .. conf_file_path)
    end

    -- 根据配置文件内容决定执行哪个脚本
    if modem_type:find("RM520") then
        io.popen("/usr/share/modem-AK68/zinfo-AK68.sh")
    elseif modem_type:find("MT5700") then
        io.popen("/usr/share/modem-AK68/zinfo5700-AK68.sh")
    else
        error("Unsupported modem type")
    end

    local file, file2
    local stat = "/tmp/cpe_cell-AK68.file"
    local stat2 = "/tmp/stsss.file"

    file = io.open(stat, "r")
    file2 = io.open(stat2, "r")

    if not file or not file2 then
        error("Error opening status files.")
    end

    local rv = {}
    rv["stsss"] = file2:read("*line")
    rv["modem"] = file:read("*line")
    rv["conntype"] = file:read("*line")
    rv["firmware"] = file:read("*line")
    rv["temper"] = file:read("*line")
    rv["date"] = file:read("*line")
	--------------------------------
	rv["simsel"] = file:read("*line")
	rv["cops"] = file:read("*line")
	rv["imei"] = file:read("*line")
	rv["imsi"] = file:read("*line")
	rv["iccid"] = file:read("*line")
	rv["phone"] = file:read("*line")
	--------------------------------
	rv["mode"] = file:read("*line")
	rv["per"] = file:read("*line")
	rv["rssi"] = file:read("*line")
	rv["rsrq"] = file:read("*line")
	rv["rscp"] = file:read("*line")
	rv["sinr"] = file:read("*line")
	-------------------------------
	rv["mcc"] = file:read("*line")
	rv["lac"] = file:read("*line")
	rv["cid"] = file:read("*line")
	rv["band"] = file:read("*line")
	rv["rfcn"] = file:read("*line")
	rv["pci"] = file:read("*line")
	rv["apn"] = file:read("*line")
	rv["down"] = file:read("*line")
	rv["up"] = file:read("*line")
	--------------------------------
	file:close()
    file2:close()
	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end

