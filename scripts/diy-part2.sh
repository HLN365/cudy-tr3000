#!/bin/bash
# diy-part2.sh — runs AFTER ./scripts/feeds install -a
# 修补镜像名/源码里的细节。

set -e

# 解决某些 host 上 Rust 构建失败:关闭 LLVM CI 模式
sed -i 's/ci-llvm=true/ci-llvm=false/g' feeds/packages/lang/rust/Makefile 2>/dev/null || true

# 镜像文件名加日期(20260101-cudy_tr3000-v1-...-sysupgrade.bin)
sed -i -e '/^IMG_PREFIX:=/i BUILD_DATE := $(shell date +%Y%m%d)' \
       -e '/^IMG_PREFIX:=/ s/\($(SUBTARGET)\)/\1-$(BUILD_DATE)/' include/image.mk

# ★ 把 LuCI 默认主题从 bootstrap 改成 argon(否则装了 argon 也不显示)
if [ -f feeds/luci/collections/luci/Makefile ]; then
  sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' \
    feeds/luci/collections/luci/Makefile 2>/dev/null || true
  echo "==== default LuCI theme set to argon ===="
fi

# 替换默认 IP 192.168.1.1 为 192.168.6.1(更符合 ImmortalWrt 默认,避开常见冲突)
if [ -f package/base-files/files/bin/config_generate ]; then
  sed -i 's/192.168.1.1/192.168.6.1/g' \
    package/base-files/files/bin/config_generate 2>/dev/null || true
fi
