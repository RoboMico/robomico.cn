---
title: 在 Godot 4.5 中为 Android 平台启用 .NET NativeAOT
date: 2025-08-22 20:44:58 +0800
categories: [教程]
tags: [中文, godot, android, .net]
lang: zh-CN
---

Godot 4.5 加入了 `linux-bionic` RID 导出支持，这意味着使用 C# 语言脚本开发的游戏在安卓平台上运行时可以使用 NativeAOT 了[^1]。不过目前网上的相关信息较为有限，无论是微软还是 Godot 官方都没有给出明确的教程，我本人在经历无数次试错后，终于摸索出了为 Android 导出启用 NativeAOT 功能的方法，现记录为此文。

## NativeAOT 简介

<!--prettier-ignore-start-->
> 如果你已经知道相关知识或者不感兴趣的话，可以跳到下一节。
{: .prompt-info }
<!--prettier-ignore-end-->

自从 .NET 大一统并实现跨平台后，所有通过 .NET 平台开发的软件都依赖于 CoreCLR 作为运行时（类似于 `.jar` 和 Java Virtual Machine 的关系）。使用 .NET 平台语言（C#，F#，Visual Basic）编写的软件会先将源代码编译成 IL 中间语言，再打包成 Assembly，运行的时候由 CoreCLR 对 IL 进行 JIT（Just In Time，即时编译）运行。

![dotnet-deployment-process-zh.jpg](https://static.robomico.cn/posts/godot-nativeaot-on-android/dotnet-deployment-process-zh.jpg)

但是从 .NET 7 开始，一种新的部署流程出现了——NativeAOT。在 NativeAOT 流程里，IL 中间语言被直接编译成目标平台上的机器码，得到一个不依赖于 CoreCLR 或 .NET Runtime 的原生二进制程序。这个二进制程序和用其他原生编译语言开发的程序（C，C++，Rust，Go）~~（还有手搓汇编）~~本质上是完全一样的。

![dotnet-nativeaot-deployment-process-zh.jpg](https://static.robomico.cn/posts/godot-nativeaot-on-android/dotnet-nativeaot-deployment-process-zh.jpg)

NativeAOT 的好处显而易见：去掉了对 CoreCLR 的依赖和 JIT 的性能损耗，构建的应用在运行时占用的内存更小，且启动速度更快。尤其是在硬件能力有限的移动设备上，这对程序的性能表现是大有裨益的。此外 NativeAOT 还可以用于开发原生库，以便通过 C/C++ 程序甚至是 JNI（Java Native Interface）调用。

但是 NativeAOT 也对程序功能做出了限制，比如不允许运行时代码生成（`System.Reflection.Emit`）和动态加载程序集（`Assembly.LoadFile`）。此外，开启 NativeAOT 后，项目也会强制要求开启代码裁剪（Trimming）并部署为单文件程序（Single File Deployment），这会影响部分库和框架的使用（WPF 和 WinForms 被踢出群聊[^2]），最经典的就是 `System.Text.Json`[^3]。

## 准备工作

首先，你需要使用 Godot 4.5 的最新预览版（或者如果你看到这篇文章的时候正式版已经发布了那就用正式版吧）的 `mono` 构建。按照[官方文档里的步骤](https://docs.godotengine.org/zh-cn/4.x/tutorials/export/exporting_for_android.html)配置好 Android 导出环境。

在导出配置选项中，打开“高级选项”，把滚动条拉到最底部，启用 `Android Use Linux Bionic`。推荐顺便开启 Gradle 构建~~（因为我一直开着，不知道内嵌 APK 能不能用）~~。这样 Godot 项目的导出配置就完成了。

![godot-config-zh.jpg](https://static.robomico.cn/posts/godot-nativeaot-on-android/godot-config-zh.jpg)

## 使用 Clang 交叉编译工具链

找到你的 Android NDK 安装目录，定位到这个文件夹：`<AndroidNDK安装位置>/toolchains/llvm/prebuilt/<操作系统-架构>/bin/`。例如，对于我的机器来说就是：`/opt/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/`。

把这个文件夹的位置设置为 `PATH` 环境变量的**第一条**。如果想检验是否设置正确，可以打开终端，运行 `clang --version`，确保输出的版本信息里有 `Android` 字样。

![clang-config-example.jpg](https://static.robomico.cn/posts/godot-nativeaot-on-android/clang-config-example.jpg)

## C# 项目配置

使用文本编辑器（比如记事本）打开你的游戏项目中的 `.csproj` 文件。文件内容看起来应该大概长这样：

```xml
<Project Sdk="Godot.NET.Sdk/4.5.0-beta.6">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <EnableDynamicLoading>true</EnableDynamicLoading>
  </PropertyGroup>
</Project>
```

首先，启用 NativeAOT 的相关选项。把下面的属性加入到 `<PropertyGroup>` 中：

```xml
<PublishAOT>true</PublishAOT>
<DisableUnsupportedError>true</DisableUnsupportedError>
<PublishAotUsingRuntimePack>true</PublishAotUsingRuntimePack>
```

然后，配置代码裁剪。添加一个 `<ItemGroup>`，把 GodotSharp 库和游戏本身的脚本库设置为根程序集：

```xml
<ItemGroup>
  <TrimmerRootAssembly Include="GodotSharp" />
  <TrimmerRootAssembly Include="$(TargetName)" />
</ItemGroup>
```

最后，由于 .NET 8 的一个 Bug，我们还需要给连接器添加一条额外参数才能成功导出[^4]。再添加一个 `<ItemGroup>`：

```xml
<ItemGroup Condition="$(RuntimeIdentifier.StartsWith('linux-bionic'))">
  <LinkerArg Include="-Wl,--undefined-version" />
</ItemGroup>
```

以上配置都写入完成后，项目文件应该差不多长这样：

```xml
<Project Sdk="Godot.NET.Sdk/4.5.0-beta.6">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <EnableDynamicLoading>true</EnableDynamicLoading>
    <PublishAOT>true</PublishAOT>
    <DisableUnsupportedError>true</DisableUnsupportedError>
    <PublishAotUsingRuntimePack>true</PublishAotUsingRuntimePack>
  </PropertyGroup>
  <ItemGroup>
    <TrimmerRootAssembly Include="GodotSharp" />
    <TrimmerRootAssembly Include="$(TargetName)" />
  </ItemGroup>
  <ItemGroup Condition="$(RuntimeIdentifier.StartsWith('linux-bionic'))">
    <LinkerArg Include="-Wl,--undefined-version" />
  </ItemGroup>
</Project>
```

## 导出测试

将项目导出为 APK，或者通过远程调试在 Android 设备上安装运行。我在 4.5 Beta 6 版本测试时，调试器会报一个错误：“`open_dynamic_library: Can't open dynamic library: libmonosgen-2.0.so. Error: dlopen failed: library "libmonosgen-2.0.so" not found.`”不过似乎并不影响游戏运行，应该是引擎的 Bug。

恭喜你的游戏成功在 Android 平台通过 NativeAOT 运行了 🎉！如果你现在没有心思写代码的话，可以拿出秒表掐一下游戏的启动时间快了多少毫秒。我个人建议你考虑优化一下你的屎山代码，毕竟费再多力气卡常数也救不了糟糕的算法。

## 参考文献

[^1]: <https://github.com/godotengine/godot/pull/97908>
[^2]: <https://learn.microsoft.com/en-us/dotnet/core/deploying/trimming/incompatibilities#wpf>
[^3]: <https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/source-generation>
[^4]: <https://github.com/dotnet/runtime/blob/674d359c926ca590a62d588a786bc7e4eb88c51f/src/coreclr/nativeaot/docs/android-bionic.md#known-issues>
