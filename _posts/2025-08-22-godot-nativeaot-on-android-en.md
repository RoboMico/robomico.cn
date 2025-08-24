---
title: How to Enable NativeAOT for Android Exports in Godot 4.5
date: 2025-08-22 20:44:58 +0800
categories: [Tutorials]
tags: [en, godot, android, .net]
lang: en
---

Godot 4.5 introduced support for `linux-bionic` RID export, which enabled NativeAOT as an option for games developed with C# running on Android platform[^1]. But currently the information on the Internet are quite limited and neither Microsoft nor Godot has released official tutorial on how to do this. Through trial and error, I have found the right way to enable NativeAOT for Android exports, which I have documented here.

## NativeAOT in Brief

<!--prettier-ignore-start-->
> If you are familiar with .NET buildsystem or are not interested in it, you can skip to the next section.
{: .prompt-info }
<!--prettier-ignore-end-->

Since the *Grand Unification* and the introduction of the cross-platform capability of the .NET, every program developed on the .NET platform has depended on CoreCLR as its runtime, in the same way that `.jar` depends on Java Virtual Machine. Source code in .NET platform languages (C#, F#, Visual Basic) is first compiled into MSIL (Microsoft Intermediate Language), then packaged into Assemblies, and executed by CoreCLR using JIT(Just-In-Time) compilation.

![dotnet-deployment-process-en.jpg](https://static.robomico.cn/posts/godot-nativeaot-on-android/dotnet-deployment-process-en.jpg)

However, a brand new deployment model was introduced in .NET 7: NativeAOT. When enabled, MSIL is compiled directly into a native binary executable on the target platform, without the dependency on CoreCLR or .NET Runtime, which has the same nature as other programs developed in native compilation languages(C, C++, Rust, Go, assembly, etc.).

![dotnet-nativeaot-deployment-process-en.jpg](https://static.robomico.cn/posts/godot-nativeaot-on-android/dotnet-nativeaot-deployment-process-en.jpg)

The benefits of NativeAOT are obvious: it eliminates both dependence on CoreCLR and JIT performance overhead, resulting in applications that consume less memory at runtime and start up faster. This is particularly beneficial for the performance of programs on mobile devices with limited hardware capabilities. In addition, NativeAOT can be used to develop native libraries that can be called by C/C++ programs or even JNI (Java Native Interface).

However, NativeAOT also imposes certain restrictions on program functionality, such as prohibiting runtime code generation (`System.Reflection.Emit`) and dynamic assembly loading (`Assembly.LoadFile`). Furthermore, enabling NativeAOT requires the project to enable code trimming and deploy as a single-file application, which affects the use of certain libraries and frameworks (yes, I'm speaking of WPF and WinForms[^2]), with the most notable example being `System.Text.Json`[^3].

## Preparation of the Godot Project

First, you need to use the `mono` build of the latest preview version of Godot 4.5(or the stable version if you come from the future). Set up your environment for Android exports by following [the official documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html).

Navigate to `Project > Export... > Your Android export preset`, turn on `Advanced Options`, scroll to the very bottom and check `Android Use Linux Bionic`. It is also suggested to enable Gradle build~~(because i always use it and have no idea whether embedded APK works)~~. Now the Godot project is well configured.

![godot-config-en.jpg](https://static.robomico.cn/posts/godot-nativeaot-on-android/godot-config-en.jpg)

## Use Clang Cross-compiling Toolchain

Find out where your Android NDK is installed and navigate to this folder: `<PathToAndroidNDK>/toolchains/llvm/prebuilt/<os-arch>/bin/`. On my machine, for example, it is: `/opt/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/`.

Set the path of this folder as the **first entry** of the `PATH` environment variable. You can validate your config by running `clang --version` in the terminal. Make sure you see `Android` in the output.

![clang-config-example.jpg](https://static.robomico.cn/posts/godot-nativeaot-on-android/clang-config-example.jpg)

## Configuration of the C# Project

Open the `.csproj` file in your game project folder with a text editor(such as Notepad). The content of the file should look like this:

```xml
<Project Sdk="Godot.NET.Sdk/4.5.0-beta.6">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <EnableDynamicLoading>true</EnableDynamicLoading>
  </PropertyGroup>
</Project>
```

First, enable the options for NativeAOT. Add these properties to the `<PropertyGroup>`:

```xml
<PublishAOT>true</PublishAOT>
<DisableUnsupportedError>true</DisableUnsupportedError>
<PublishAotUsingRuntimePack>true</PublishAotUsingRuntimePack>
```

Then, configure the code trimming. Add a new `<ItemGroup>` and set GodotSharp and your game's scripts library as the root assembly:

```xml
<ItemGroup>
  <TrimmerRootAssembly Include="GodotSharp" />
  <TrimmerRootAssembly Include="$(TargetName)" />
</ItemGroup>
```

Finally, due to a bug in .NET 8, we need to pass an extra argument to the linker to be able to succussfully export the game[^4]. Add another `<ItemGroup>`:

```xml
<ItemGroup Condition="$(RuntimeIdentifier.StartsWith('linux-bionic'))">
  <LinkerArg Include="-Wl,--undefined-version" />
</ItemGroup>
```

After all the configuration, the project file should now look like this:

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

## Export and Test

Export your game as APK or remote deploy it on an Android device. When I was testing on version 4.5 Beta 6, the debugger would throw an error: `open_dynamic_library: Can't open dynamic library: libmonosgen-2.0.so. Error: dlopen failed: library "libmonosgen-2.0.so" not found.` But it seemed that it doesn't affect the game itself, so I assume it's a bug of the engine.

Congratulations that your game is now running on Android with NativeAOT🎉! If you don't feel like coding right now, take out your stopwatch to calculate how many milliseconds your game saves at start up. I personally suggest that you should optimize your shit code, since a bad algorithm is incurable.

## References

[^1]: <https://github.com/godotengine/godot/pull/97908>
[^2]: <https://learn.microsoft.com/en-us/dotnet/core/deploying/trimming/incompatibilities#wpf>
[^3]: <https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/source-generation>
[^4]: <https://github.com/dotnet/runtime/blob/674d359c926ca590a62d588a786bc7e4eb88c51f/src/coreclr/nativeaot/docs/android-bionic.md#known-issues>
