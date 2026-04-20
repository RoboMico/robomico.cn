---
title: 在 Linux 上搭建华为海思 WS63 开发环境
description: 嗨丝帕可死丢丢？什么玩意儿，没听说过
date: 2026-04-20 14:22:00 +0800
categories: [教程]
tags: [中文, 嵌入式]
lang: zh-CN
---

## 为什么你应该在 Linux 系统里开发 WS63

- 海思官方没有给出 Linux 环境的任何配置说明，显得 Linux 下的开发者很具有叛逆精神；
- 享受比 Windows 环境下快最高 8 倍的编译速度；
- 纯粹只是受够了 HiSpark Studio 或者 Windows。

## 软件基础

确保系统安装了以下软件包：

```plaintext
git python cmake ninja make gcc musl kconfig
```

确保默认的 Python 环境安装了以下库：

```plaintext
kconfiglib pycparser setuptools
```

使用 Visual Studio Code 作为基础 IDE。必备的插件只有一个：C/C++。**不要安装 HiSpark Studio 插件**，这个插件只兼容 Windows。

## 基础代码库

直接克隆海思 GitCode 仓库：`git clone https://gitcode.com/HiSpark/fbb_ws63.git`

进入 `src` 子目录作为项目代码的主目录。

## 项目配置

使用命令在终端里打开 TUI 配置菜单：`python build.py ws63-liteos-app menuconfig`

方向键导航，空格键切换复选框或进入子菜单，S 键保存，Esc 返回上一级，Q 键退出。

## 编译

编译前配置好环境变量，让编译器可以利用到全部 CPU 核心并行编译。把以下配置粘贴到你的 Shell Profile 中（例如 `~/.bashrc`，具体取决于你使用的是哪款 Shell）：

```bash
THREADS_COUNT=$(cat /proc/cpuinfo | grep "processor" | sort -u | wc -l)
export CMAKE_BUILD_PARALLEL_LEVEL=${THREADS_COUNT}
export MAKEFLAGS="-j${THREADS_COUNT}"
```

清理后编译（在修改项目配置后需要进行清理后编译）：`python build.py -c ws63-liteos-app`

增量编译（项目配置没有变动的情况下直接增量编译，可以提高编译速度）：`python build.py ws63-liteos-app`

## 烧录

使用 GitHub 上的野生 Linux 移植版 WS63 烧录程序：`https://github.com/goodspeed34/ws63flash`

自己动手编译时有一点需要注意，配置时需要将 C 语言编译器修改为 `musl-gcc`：`CC="musl-gcc" ./configure`

对于使用 Arch 系发行版的用户，也有 AUR 包可用：`yay -S ws63flash-git`

烧录时需要记下开发板对应的 tty 设备文件 `/dev/ttyUSBx`：`find /dev | grep "ttyUSB"`，如果不确定哪个设备是开发板的话，可以分别在拔下/插上开发板时搜索一次，找出搜索结果中不同的那个即可。

完整烧录（包含 Bootloader 等）：`sudo ws63flash -b921600 --flash /dev/ttyUSBx ./output/ws63/fwpkg/ws63-liteos-app/ws63-liteos-app_all.fwpkg`

仅烧录应用负载（一般来说除了新开发板首次烧录以外，以后烧录都可以只用这个）：`sudo ws63flash -b921600 --flash /dev/ttyUSBx ./output/ws63/fwpkg/ws63-liteos-app/ws63-liteos-app_load_only.fwpkg`

## 串口调试

Linux 下有通用的串口调试工具 minicom。安装 minicom 软件包，保持开发板与主机连接，运行：`sudo minicom -D /dev/ttyUSBx`（这里的设备文件名与烧录步骤中的那个设备文件名一致）。

按下键盘上的按键可以向开发板发送单个 ASCII 字符。如果要发送一串字符串的消息，可以将消息保存为文件后，按 Ctrl+A 再按 S 打开发送文件菜单。编码选择 `ascii`，之后在 TUI 中导航到待发送文件，或者直接输入文件路径即可。

先按 Ctrl+A 再按 Z 可以打开命令说明菜单。最常用的两个功能键是：`Ctrl+A; C` 清屏，`Ctrl+A; X` 退出。

## 命令速查表

（记得将 `/dev/ttyUSBx` 换成真正的设备端口文件）

| 功能              | 命令                                                                                                               |
| ----------------- | ------------------------------------------------------------------------------------------------------------------ |
| 项目配置          | `python build.py ws63-liteos-app menuconfig`                                                                       |
| 重编译/清理后编译 | `python build.py ws63-liteos-app -c`                                                                               |
| 编译              | `python build.py ws63-liteos-app`                                                                                  |
| 全板烧录          | `sudo ws63flash -b921600 --flash /dev/ttyUSBx ./output/ws63/fwpkg/ws63-liteos-app/ws63-liteos-app_all.fwpkg`       |
| 烧录应用负载      | `sudo ws63flash -b921600 --flash /dev/ttyUSBx ./output/ws63/fwpkg/ws63-liteos-app/ws63-liteos-app_load_only.fwpkg` |
| 串口通信器        | `sudo minicom -D /dev/ttyUSBx`                                                                                     |
