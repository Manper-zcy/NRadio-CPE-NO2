module("luci.controller.modem-webui", package.seeall)

function index()
	entry({"admin", "modem-webui"}, firstchild(), _("蜂窝Webui"), 25).dependent=false
	entry({"admin", "modem-webui", "nets"}, template("mode-webui/webui"), _("模块管理"), 97)
	entry({"admin", "modem-webui", "net"}, template("mode-webui/net"), _("网络设置"), 98)
	entry({"admin", "modem-webui", "scan"}, template("mode-webui/scan"), _("基站扫描"), 99)
	entry({"admin", "modem-webui", "dev"}, template("mode-webui/dev"), _("模组信息"), 100)
	entry({"admin", "modem-webui", "set"}, template("mode-webui/set"), _("高级设置"), 101)
	entry({"admin", "modem-webui", "sms"}, template("mode-webui/sms"), _("短信功能"), 102)
	entry({"admin", "modem-webui", "cos"}, template("mode-webui/cos"), _("终端调试"), 103)
	entry({"admin", "modem-webui", "wat"}, template("mode-webui/wat"), _("Watchcat"), 104)
	entry({"admin", "modem-webui", "st"}, cbi("modem-webui"), _("连接设置"), 105) 
	entry({"admin", "modem-webui", "get_ip"}, call("action_get_ip"))
end

function action_get_ip()
	local ip = "192.168.225.1" -- default IP
	local file = io.open("/usr/bin/info.conf", "r")

	if file then
		local content = file:read("*a")
		file:close()
		if content and content:match("%S") then
			ip = content:match("%S+")
		end
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json({ ip = ip })
end


