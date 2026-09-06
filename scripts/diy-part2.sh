#!/bin/bash
# diy-part2.sh — runs AFTER ./scripts/feeds install -a
# 修补镜像名/源码里的细节。

# 解决某些 host 上 Rust 构建失败:关闭 LLVM CI 模式
sed -i 's/ci-llvm=true/ci-llvm=false/g' feeds/packages/lang/rust/Makefile 2>/dev/null || true

# 镜像文件名加日期(20260101-cudy_tr3000-v1-...-factory.ubi)
sed -i -e '/^IMG_PREFIX:=/i BUILD_DATE := $(shell date +%Y%m%d)' \
       -e '/^IMG_PREFIX:=/ s/\($(SUBTARGET)\)/\1-$(BUILD_DATE)/' include/image.mk
