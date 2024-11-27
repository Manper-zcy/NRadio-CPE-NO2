include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-Secondsystem660
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-Secondsystem660
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Luci App Secondsystem660
  DEPENDS:=+luci
endef

define Build/Compile
endef

define Package/luci-app-Secondsystem660/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/Secondsystem660.lua $(1)/usr/lib/lua/luci/controller/Secondsystem660.lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./luasrc/model/cbi/Secondsystem660.lua $(1)/usr/lib/lua/luci/model/cbi/Secondsystem660.lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/Secondsystem660
	$(INSTALL_DATA) ./luasrc/view/Secondsystem660/settings.htm $(1)/usr/lib/lua/luci/view/Secondsystem660/settings.htm
endef

$(eval $(call BuildPackage,luci-app-Secondsystem660))
