# PixelOS 17 (Android 17 / API 37) — Sony Xperia XZ2 Compact (xz2c) 适配

PixelOS 17 在 xz2c 上的平台侧与 Pixel 组件适配源码。仓库**只包含被修改/新增的文件**，目录结构与 PixelOS 源码树一致，覆盖到源码树即可。

设备树本身在 [sony_xz2c_tree](https://github.com/xing29391/sony_xz2c_tree)。

## 改动清单

### 图形 / 相机
- `frameworks/native/libs/ui/GraphicBuffer.cpp`、`include/ui/GraphicBuffer.h`：A17 的 `GraphicBuffer` 结构体大小变化导致旧 vendor 相机 HAL 的 sizeof 不匹配（预览崩溃的根因之一），按旧布局修正。

### HAL 兼容
- `hardware/interfaces/compatibility_matrices/{Android.bp, compatibility_matrix.5.xml, compatibility_matrix.6.xml}`：补 FCM 5/6，使 4.9 内核上的旧 vendor HAL 可通过 VINTF 校验
- `hardware/interfaces/light/2.0/*`：A17 缺失的 light HAL 接口
- `hardware/lineage/interfaces/touch/1.0/*`：触摸 HAL 接口（高触控采样率/手势）
- `hardware/qcom-caf/bootctrl/gpt-utils/Android.bp`：编译修复

### 平台（4.9 内核兼容）
- `packages/modules/Connectivity/bpf/*`、`service/...`：`NetBpfLoad.cpp`、`netbpfload.rc`、`BpfHandler.cpp`、`NetdUpdatable.cpp`、`LocalNetEventHandler`/`LocalNetEventListener`（A17 mainline 组件对旧内核 BTF/permission 的放宽）
- `system/bpf/loader/Loader.cpp`
- `system/memory/libmeminfo/sysmeminfo.cpp`
- `system/core/libutils/binder/RefBase.cpp`：放宽 `pm-service` 触发的 RefBase 栈检查（否则 `pm` 反复 abort）

### init（重要）
- `system/core/init/{Android.bp, main.cpp, first_stage_main.cpp}`：`init_second_stage` 链接修复
- `system/core/init/property_service.cpp`：移除 `SetSafetyNetProps()` 对 `ro.build.type` / `ro.debuggable` 的强制覆盖

> **警告：本设备上任何重新编译/替换 `/system/bin/init` 的镜像都会在第一阶段停止（静态 Google logo、无 adb、约 10 分钟后回 fastboot，pstore 无输出）。**
> 实测的 init 改动（包括只改两个字符串常量的最小改动）均无法启动。因此发布的 `system.img` 必须使用该 PixelOS 源码树**原有**的 `init` 二进制；上述 init 源码改动仅用于让整树能够编译通过，**不要**把重新构建的 init 打进镜像。
> `adb root` 不需要改 init：开启「开发者选项 → 以 root 身份调试」即可（`/data/adbroot/enabled`）。

### Pixel 组件
- `vendor/pixel/gms/common/{Android.bp, common-vendor.mk}`：GMS 以特权预置 APK 形式打包（A17 的 GMS APEX payload 为 EROFS，4.9 内核无法挂载）
- `vendor/pixel/launcher/common/common-vendor.mk`
- `vendor/pixel/themepicker/{common/common-vendor.mk, products/themepicker.mk}`

> 闭源 APK（`PrebuiltGmsCoreVic.apk` 等，单个 >100 MB）不在本仓库中，请用 `vendor/pixel/extract-all.sh` 从 Pixel 官方固件提取。

## 编译

```bash
source build/envsetup.sh
lunch custom_xz2c-userdebug
m bacon
```

首次启动因 dexopt 可能耗时 30 分钟以上，之后冷启动约 50 秒。

## 已知问题

- `vendor.qti.hardware.alarm@1.0-service` 每次开机 abort 一次，仅影响关机闹钟。
- GMS 以 APK 形式预置，`ro.build.type` 仍会被 `SetSafetyNetProps()` 伪装为 `user`（该函数在分区 build.prop 加载前执行，`ro.*` 属性写一次即固定）；不影响使用与 adb root。
