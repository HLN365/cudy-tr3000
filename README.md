# Cudy TR3000 (128M) — GitHub Actions 编译方案

基于 [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6)
的 `openwrt-24.10-6.6` 分支,目标设备 **`cudy_tr3000-v1-ubootmod`**(就是你之前刷过的变体)。

**包含的内容**:
- USB 上网驱动(`kmod-usb-net-rndis` / `cdc-ether` / `kmod-usb-xhci-mtk` 等)
- `ttyd` + `luci-app-ttyd` Web 终端
- **argon 主题**(浅/深/自动三档,首次启动自动设为默认)
- `luci-app-turboacc-mtk`(MT7981 HNAT 硬件加速)
- `zram-swap` / `wrtbwmon` / `fitblk` / `automount` 等基础增强

**不启用联发科私有 mt_wifi 栈**,Wi-Fi 走上游 mt76(与设备 DTB 匹配)。

> **产物**:`*-squashfs-sysupgrade.bin`(约 30-50 MB,UBI 内核,128M NAND 装得下)
> **没有 factory.ubi**:ubootmod 版不能从原厂刷入,必须先装好过渡固件(你已经搞定)。
> 参考 [weekdaycare 仓库](https://github.com/weekdaycare/immortalwrt-mt7981-cudy-tr3000)
> 是 P3TERX 三段式套路,本仓库沿用,基于他的 baseline 删掉了 OpenClash / Bandix / Aurora 主题 / mtd-rw / upnp。

---

## 目录结构

```
tr3000-build/
├── .github/workflows/build.yml                       # GitHub Actions 主流程
├── config/tr3000.config                              # 目标 + 设备 + 包选择
├── scripts/diy-part1.sh                              # feeds update 之前(默认空)
├── scripts/diy-part2.sh                              # feeds install 之后(日期、修补)
├── files/etc/uci-defaults/99-argon-default-theme     # 首次启动把 argon 设为默认主题
└── README.md
```

## 1. 创建你自己的仓库

```bash
cd /Users/hl/Dev/WorkSpace/AIWorkSpace/Claude/tr3000-actions
git init -b main
git add . && git commit -m "init: Cudy TR3000 USB tethering + ttyd build"
git remote add origin git@github.com:<你的用户名>/tr3000-build.git
git push -u origin main
```

## 2. 触发构建

仓库 → **Actions** → 选 `Build ImmortalWrt for Cudy TR3000` → **Run workflow**。
也可等每月 1 号 02:00 (UTC) 自动跑。

## 3. 拿产物

跑完在 Actions 页面下方 **Artifacts** 区出现 `cudy-tr3000-firmware`,下载 ZIP,
里面有:

| 文件 | 用途 |
|---|---|
| `*cudy_tr3000-v1-ubootmod-squashfs-sysupgrade.bin` | OTA 升级用,就是你要的 .bin |
| `SHA256SUMS` | 校验 |

## 4. 刷入与启用 USB 上网

**首次刷入**:你已经完成(必须先按 ubootmod 教程装过渡固件,这一步不能跳过)。

**OTA 升级**:后台 → 系统 → 备份与升级 → 刷写新固件 → 选
`*cudy_tr3000-v1-ubootmod-squashfs-sysupgrade.bin`(**不要**勾选"保留配置")。

**USB 上网**:
1. USB-C 数据线接 Android 手机(必须是**数据线**,不是纯充电线)。
2. 手机端开"USB 网络共享"(大多数安卓走 RNDIS,会冒出一个 `usb0` 接口)。
3. Web → 网络 → 接口 → 新建 → 设备选 `usb0`,协议 DHCP,防火墙区域选 WAN。
4. `ifconfig usb0` 应能拿到 IP,`ping -I usb0 8.8.8.8` 通。

> 设备名按手机厂商可能不同:
> - 大多数安卓 RNDIS → `usb0`
> - 鸿蒙/部分新机 CDC-NCM → `wwan0` 或 `usb0`
> - iPhone(`kmod-usb-net-ipheth` 没装就拔线) → `eth1`

**ttyd**:服务 → 终端(ttyd) → 启用,默认 7681 端口,经 Luci 鉴权。

**argon 主题**:首次启动已自动设为默认。也可手动切换:服务 → Argon 配置 → 主题风格 选「argon」→ 应用;或 系统 → 系统 → 语言和界面 → 主题 选 argon。

## 5. 增加/删除软件包

只改一个地方:`config/tr3000.config`。

例如想加 `luci-app-eqos`:

```ini
CONFIG_PACKAGE_luci-app-eqos=y
```

push 即可,下次 Actions 重新编译。

如果加第三方 feed 源(比如 passwall、OpenClash),在
`scripts/diy-part1.sh` 里 `echo 'src-git xxx ...' >> feeds.conf.default`,
然后在 `config/tr3000.config` 加 `CONFIG_PACKAGE_xxx=y`。

## 6. 预置自定义文件

把文件放进 `files/etc/...` 即可被镜像 build 时 copy 进 rootfs 并在首次启动应用。
当前我们有一个 `files/etc/uci-defaults/99-argon-default-theme` 用作设置默认主题。

## 7. 常见问题

| 现象 | 处理 |
|---|---|
| Actions 跑超时(6h) | 改用 [self-hosted runner](https://docs.github.com/en/actions/hosting-your-own-runners);免费的 ubuntu-22.04 紧 |
| 编译报 OOM/ENOSPC | workflow 已清理预装;仍 OOM 换 self-hosted runner(≥ 30 GB SSD) |
| 报 `WARNING: unrecognized CONFIG_*` | 不致命;若最终缺包,先 `make menuconfig` 一遍再保存 |
| 刷入无 5G/2.4G | 看你之前用哪个 fork;本方案走上游 mt76,理论就绪;若仍无 Wi-Fi,先查 eeprom 是否生成 |
| 手机不识别 | 换数据线;`dmesg \| tail` 看 xHCI 是否枚举 |
| argon 主题没生效 | `uci show luci.main.mediaurlbase`,期望 `/luci-static/argon`;也可用 LuCI 服务 → Argon 配置 切换 |
| 想保留私人设置/插件 | 把文件放进 `files/etc/...`,镜像 build 时会自动带进去 |

---

## 参考

- [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6)
- [weekdaycare/immortalwrt-mt7981-cudy-tr3000](https://github.com/weekdaycare/immortalwrt-mt7981-cudy-tr3000)(参考)
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)(模板)
- [jerrykuku/luci-theme-argon](https://github.com/jerrykuku/luci-theme-argon)(主题)
- [Cudy TR3000 v1 DTS](https://github.com/immortalwrt/linux/blob/HEAD/target/linux/mediatek/files/arch/arm64/boot/dts/mediatek/filogic820/mt7981b-cudy-tr3000-v1.dts)
- [OpenWrt USB 网卡/RNDIS 文档](https://openwrt.org/docs/guide-user/network/wan/wwan/ltedongle)
