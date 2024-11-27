local fs = require "nixio.fs"

local m = Map("modem-webui", translate("RM520模组连接信息设置"))

local s = m:section(TypedSection, "settings", translate("设置（“蜂窝Webui”功能需要RM520启用了webui后可用。）"))
s.anonymous = true

local o = s:option(Value, "custom_address", translate("请填写自定义地址(IP或域名)："))

local file_path = "/usr/bin/info.conf"
o.default = fs.readfile(file_path) or ""

function o.write(self, section, value)
    print("Saving value: " .. value) -- 添加调试信息
    fs.writefile(file_path, value:gsub("\r\n", "\n"))
    luci.http.redirect(luci.dispatcher.build_url("admin/modem-webui/st"))

end

return m

