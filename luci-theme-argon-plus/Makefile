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

PKG_NAME:=luci-theme-argon-plus

LUCI_TITLE:=Argon Plus - Argon theme with built-in configuration
LUCI_DEPENDS:=+luci-base +@wget-any +jsonfilter

PKG_VERSION:=2.4.3
PKG_RELEASE:=3

LUCI_MINIFY_CSS:=0

# The images this feed builds select this package instead of the upstream
# luci-theme-argon / luci-app-argon-config pair (see openwrt-actions
# configs); the uci-defaults script below cleans up what they left behind.
# Package-level Conflicts metadata is not expressible here: luci.mk
# synthesizes the Package/ define with no CONFLICTS field, and the
# buildroot's Package/Default reset clears global assignments before the
# dump ever sees them.

define Package/$(PKG_NAME)/conffiles
/etc/config/argon
/www/luci-static/argon-plus/background/
endef

# The uci-defaults script registers the theme in luci.themes; nothing takes it
# back out, so an uninstalled theme keeps its entry in the Design list and
# points it at a directory that is gone. Worse, removing the theme that is
# currently in use leaves mediaurlbase aimed at that same missing directory,
# and LuCI stops rendering at all -- recoverable only over ssh. Undo both.
define Package/$(PKG_NAME)/postrm
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] || {
	uci -q delete luci.themes.ArgonPlus
	[ "$$(uci -q get luci.main.mediaurlbase)" = "/luci-static/argon-plus" ] && \
		uci -q set luci.main.mediaurlbase=/luci-static/bootstrap
	uci -q commit luci
	rm -f /tmp/luci-indexcache* >/dev/null 2>&1 || true
	rm -rf /tmp/luci-modulecache >/dev/null 2>&1 || true
}

exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
