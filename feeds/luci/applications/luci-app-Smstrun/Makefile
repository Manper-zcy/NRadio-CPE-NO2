include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-Smstrun
PKG_VERSION:=1.4.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-Smstrun
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Luci App Smstrun
  DEPENDS:=+luci
endef

define Build/Compile
endef

define Package/luci-app-Smstrun/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/Smstrun.lua $(1)/usr/lib/lua/luci/controller/Smstrun.lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./luasrc/model/cbi/Smstrun.lua $(1)/usr/lib/lua/luci/model/cbi/Smstrun.lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/Smstrun
	$(INSTALL_DATA) ./luasrc/view/Smstrun/settings.htm $(1)/usr/lib/lua/luci/view/Smstrun/settings.htm
endef

$(eval $(call BuildPackage,luci-app-Smstrun))
