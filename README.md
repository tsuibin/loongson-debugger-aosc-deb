# loongson-debugger（LoongArch ABI 2.0）AOSC deb 打包

把一份 LoongArch ABI 2.0 版本的 loongson-debugger 上位机工具压缩包打成可在
**AOSC OS / loongarch64** 上安装的 `.deb`。包内上位机工具是 LoongArch 原生静态链接
二进制，ELF 标志 `0x43 DOUBLE-FLOAT, OBJ-v1`，与本机新世界 ABI 2.0 一致，
不依赖 LATX/box64。

## 为什么选 ABI 2.0 版本

上游同期提供过三类包：

- 多架构包：上位机工具是 x86-64，需要翻译层；
- LoongArch 旧世界包：架构是 LoongArch，但为 `OBJ-v0`（ABI 1.0）；
- **LoongArch ABI 2.0 包（OBJ-v1）**：与 AOSC 的 ABI 一致，本教程选它作为源。

## 打包

需要自行准备一份 LoongArch ABI 2.0 的源码压缩包，并显式传给脚本：

```sh
sh scripts/build-deb.sh /path/to/source-archive
```

产物：`output/loongson-debugger_1.0-1_loongarch64.deb`

脚本做四件事：解包 → 脱敏 → 按 deb 布局安装 → `dpkg-deb --build`。
**全程不需要 root**；`--root-owner-group` 让归档内文件属主统一为 root:root。

## 安装布局

| 路径 | 内容 |
|---|---|
| `/opt/loongson-debugger/` | 完整工具包（工具、脚本、板级配置、文档、MIPS 固件镜像） |
| `/usr/bin/la_dbg_tool_usb` | 指向 `/opt/loongson-debugger/la_dbg_tool_usb` 的相对符号链接 |
| `/usr/bin/la32_dbg_tool_usb` | 同上（LA32） |
| `/usr/bin/ejtag_debug_usb` | 同上（MIPS） |
| `/usr/share/doc/loongson-debugger/README.md` | 本说明 |

控制信息：`Depends: python-3, perl, binutils`（helper 脚本用到 Python/Perl 和 `readelf`）。
无 maintainer scripts。

## 安装与验证

```sh
sudo dpkg -i loongson-debugger_1.0-1_loongarch64.deb
la_dbg_tool_usb -h
ejtag_debug_usb -h
```

普通用户访问 USB 调试器需要 udev 规则（按硬件 USB ID 自行添加）；本仓库不内置规则文件。

## 与 emacs/projmenu 集成

菜单里的 `debuggerpath` 指向 `/opt/loongson-debugger/la_dbg_tool_usb` 即可，
`gdb ▸ run gdb` 会 source `/opt/loongson-debugger/scripts/linux.py`。

## 脱敏说明

构建前用 `scripts/sanitize.py` 替换源码包中残留的个人家目录与内网地址：

| 原内容类别 | 替换为 |
|---|---|
| 个人家目录下的工具链路径 | `/path/to/toolchain/bin/` |
| 个人家目录下的调试符号路径 | `/path/to/debug` |
| 内网 NFS 挂载地址 | `<NFS_HOST>:/path/to/ejtag` |

敏感原串以 base64 存放在 `scripts/sanitize.py` 中、运行时才解码，不在仓库中明文出现。
仓库不含预编译二进制、个人路径、内网 IP 或账号信息；`.deb` 由使用者本地构建。
