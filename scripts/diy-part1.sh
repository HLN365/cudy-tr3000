#!/bin/bash
# diy-part1.sh — runs BEFORE ./scripts/feeds update -a
# 这里只在需要添加第三方 feed/源码包时才填。
set -e

# luci-theme-argon 不在 ImmortalWrt 默认 feeds,需要从 jerrykuku 拉源码
# 用 master 分支(适配 OpenWrt 24.10 / ImmortalWrt 24.10)
mkdir -p package/luci-theme-argon-src
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon.git \
  package/luci-theme-argon-src 2>&1 | tail -3

# jerrykuku/luci-app-argon-config 配套的配置面板
mkdir -p package/luci-app-argon-config-src
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git \
  package/luci-app-argon-config-src 2>&1 | tail -3
