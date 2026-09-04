
# Copyright (C) 2026 leochien0102
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for the ssr-plus tunnel watchdog
# luci-app-ssr-plus is a hard dependency for two reasons: the page hangs off
# its menu node, and every path the watchdog reads is an ssr-plus internal.
# Without it this package has nothing to watch and nowhere to appear.
LUCI_DEPENDS:=+luci-app-ssr-plus
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-ssrp-watch
PKG_VERSION:=1
PKG_RELEASE:=3

define Package/$(PKG_NAME)/conffiles
/etc/config/ssrp-watch
endef

include $(TOPDIR)/feeds/luci/luci.mk
# call BuildPackage - OpenWrt buildroot signature
