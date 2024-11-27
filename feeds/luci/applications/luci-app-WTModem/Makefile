# rebuid by Manper

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-WTModem
PKG_VERSION:=1.3
PKG_RELEASE:=1

LUCI_TITLE:=LuCI for WTModem
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+kmod-usb-net +kmod-usb-core +kmod-usb-ohci +kmod-usb-serial +kmod-usb-serial-option +kmod-usb-uhci +kmod-usb2 +usb-modeswitch +usbutils


include $(TOPDIR)/feeds/luci/luci.mk

# $(eval $(call BuildPackage,luci-app-WTModem))
