
# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Access Control Configuration
# 无额外依赖。nft 与 iptables 都不写进来——运行期按 fw3/fw4 自动检测，
# 写死任一边都会强迫另一边的用户装用不上的包（见 README「依赖说明」）。
# luci.mk 会自动追加 +luci-lua-runtime，luci-base 由它带入。
LUCI_DEPENDS:=
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-accesscontrol-plus
PKG_VERSION:=1
PKG_RELEASE:=14

include $(TOPDIR)/feeds/luci/luci.mk
# call BuildPackage - OpenWrt buildroot signature
