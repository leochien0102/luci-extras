#
# Copyright (C) 2008-2019 Jerrykuku
# Copyright (C) 2026 leochien0102
#
# This is free software, licensed under the Apache License, Version 2.0 .
#
# Argon Plus = upstream luci-theme-argon + luci-app-argon-config merged into
# one package. The configuration UI is embedded below the theme selector on
# the System Properties -> Language and Style page (see
# htdocs/luci-static/resources/argon-plus-settings.js); no menu entry of its
# own. Based on the luci feed's openwrt-25.12 branch.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=Argon Plus - Argon theme with built-in configuration
LUCI_DEPENDS:=+luci-base +@wget-any +jsonfilter

PKG_VERSION:=2.4.3
PKG_RELEASE:=1

LUCI_MINIFY_CSS:=0

define Package/$(PKG_NAME)/conffiles
/etc/config/argon
/www/luci-static/argon-plus/background/
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
