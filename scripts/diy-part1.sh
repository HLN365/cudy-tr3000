#!/bin/bash
# diy-part1.sh — runs BEFORE ./scripts/feeds update -a
# 这里只在需要添加第三方 feed/源码包时才填。
set -e

# luci-theme-argon 不在 ImmortalWrt 默认 feeds,需要从 jerrykuku 拉源码
# jerrykuku 的仓库是扁平结构(Makefile 在 repo 根),OpenWrt 要求目录名 = PKG_NAME
# PKG_NAME = luci-theme-argon / luci-app-argon-config,所以直接 clone 到 package/<pkgname>/
cd /workdir/openwrt

# 如果之前失败过残留,先清掉
rm -rf package/luci-theme-argon package/luci-app-argon-config
rm -rf package/luci-theme-argon-src package/luci-app-argon-config-src

git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon.git \
  package/luci-theme-argon 2>&1 | tail -3
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git \
  package/luci-app-argon-config 2>&1 | tail -3
