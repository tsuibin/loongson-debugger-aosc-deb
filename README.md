# loongson-debugger for AOSC (loongarch64)

Loongson EJTAG / loongson-debugger 的上位机工具包，面向 **AOSC OS / loongarch64**。
内置工具为 LoongArch ABI 2.0（OBJ-v1、新世界）原生静态链接二进制，可直接在本机运行，
无需 x86 翻译层。

## 包含的工具

| 工具 | 用途 |
|---|---|
| `la_dbg_tool_usb` | LoongArch 处理器的 EJTAG 调试（USB 接口） |
| `la32_dbg_tool_usb` | LoongArch32 处理器调试 |
| `ejtag_debug_usb` | MIPS 架构处理器调试 |
| `scripts/` | 板级配置与辅助脚本 |

工具还支持 `pp` / `gpio` / `cgpio` 等接口形态，对应的可执行文件一并安装在 `/usr/bin/`。

## 安装

```sh
sudo dpkg -i loongson-debugger_1.0-1_loongarch64.deb
```

依赖：`python-3`、`perl`、`binutils`。

## 验证

```sh
la_dbg_tool_usb -h
ejtag_debug_usb -h
```

## 安装布局

| 路径 | 内容 |
|---|---|
| `/opt/loongson-debugger/` | 工具、脚本、板级配置、文档与目标固件镜像 |
| `/usr/bin/la_dbg_tool_usb` | 指向工具目录下同名程序的符号链接 |
| `/usr/share/doc/loongson-debugger/README.md` | 本说明 |

## 与 emacs/projmenu 集成

菜单中的 `debuggerpath` 指向 `/opt/loongson-debugger/la_dbg_tool_usb` 即可；
`gdb ▸ run gdb` 会 source `/opt/loongson-debugger/scripts/linux.py`。

## 权限

普通用户通过 USB 访问调试器需要对应的 udev 规则（按硬件 USB ID 添加），本包不内置规则文件。
