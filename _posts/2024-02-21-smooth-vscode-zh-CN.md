---
title: 如何把你的 VSCode 变得像德芙一样丝滑
date: 2024-02-21 21:21:30 +0800
categories: [教程]
tags: [中文, vscode]
lang: zh-CN
---

~~好耶是第一篇技术教程~~

四年前我第一次在电脑上安装 Microsoft Office 2016 的时候，直接被它的动画惊艳到了。你可以想象对于一位 Office 2006 和 WPS Office 用户来说，看到光标会在你到处乱点的时候跟着鼠标跑是多么震撼。

至于 VSCode，我从十岁开始就用了，但是它一直以来都没做什么动画效果——所有东西都只会唐突地消失、出现，没有任何淡入淡出（除了右下角的通知泡泡）。我就搞不懂了，都是微软家的产品，凭什么 VSCode 就不配有动画？是因为 VSCode 的开发者更没品味吗？

实则不然，VSCode 是有内置动画效果的，只是被默认关闭了而已。所以这篇文章会教会大家如何给 VSCode 多一点好看的丝滑动画，只需要改几个设置选项就行，或者再安装一两个插件来实现更美观的视觉效果。

## 原版 VSCode 的动画效果选项

按下 `Ctrl+,` ~~（macOS 用户怎么你了）~~ 打开设置页面，搜索“smooth”就能找到动画效果选项。如果你的 VSCode 版本和我一样是 `1.86.2` 的话，应该能看到 5 个选项（其实只有 4 个是有用的）。这里是我的个人配置：

![vscode-smooth-settings-zh.png](https://static.robomico.cn/posts/smooth-vscode/vscode-smooth-settings-zh.png)

以下是效果预览动图 ~~（懒得再录一边我就直接用英文版了）~~：

![vscode-smooth-settings-preview-en.gif](https://static.robomico.cn/posts/smooth-vscode/vscode-smooth-settings-preview-en.gif)

## 通过扩展实现更多动画效果

如果你觉得这还不够，还有一款叫“VSCode Animations”的插件可以满足你对动画效果的极致需求。只需要在扩展市场里搜索并安装即可（ID 是`BrandonKirbyson.vscode-animations`）。

但是这款插件第一次配置会有一点点麻烦。首先点击通知泡泡上的“Change Install Method”按钮，然后把安装方式修改成“Apc Customize UI++”，因为默认的“Custom CSS and JS”有些问题：

![vscode-animations-change-install-method.png](https://static.robomico.cn/posts/smooth-vscode/vscode-animations-change-install-method.png)
_点右边的按钮_

然后在下一个通知泡泡中点“Install Apc Customize UI++”。这一操作会安装一个额外的依赖插件，负责把动画效果的代码注入到 VSCode 的资源文件中：

![vscode-animations-install-apc.png](https://static.robomico.cn/posts/smooth-vscode/vscode-animations-install-apc.png)
_点左边的按钮_

之后窗口会重新加载一两次。如果你是 Windows 用户，恭喜你已经配置完成了！但是如果你是像我一样的 Linux 用户的话，可能会遇到下面这种文件权限问题：

![vscode-animations-error.png](https://static.robomico.cn/posts/smooth-vscode/vscode-animations-error.png)

修复非常简单：打开 VSCode 资源文件的读写权限（资源文件目录可能会因 Linux 发行版和 VSCode 安装方式而异）：

```bash
sudo chmod o+rw /opt/visual-studio-code/resources -R
```

<!-- prettier-ignore-start -->
> **`sudo` 有风险，授权需谨慎。** 有已知问题表明，在修改文件权限后更新 VSCode 可能会损坏应用程序。如果你遇到了类似问题，请卸载上述的两个插件、彻底卸载 VSCode 再重新安装（设置和用户数据会被保留）。
{: .prompt-danger }
<!-- prettier-ignore-end -->

然后点击通知泡泡上的“Install Now”或者在命令面板里运行 `>Animations: Install Animations`。待安装完成后别忘了把写入权限锁回去，避免安全隐患：

```bash
sudo chmod o-w /opt/visual-studio-code/resources -R
```

扩展的可配置性非常强，你可以把每个选项都试一遍，直到找到自己最喜欢的效果。以下是我的配置：

<!--prettier-ignore-start-->
```json
{
    "animations.Active": "Indent",
    "animations.Command-Palette": "Slide",
    "animations.Scrolling": "None",
    "animations.Tabs": "Slide",
    "animations.Focus-Dimming-Mode": "None",
    "animations.Smooth-Mode": true
}
```
{: file='Animation Settings'}
<!--prettier-ignore-end-->

**德芙 Code，启动！**

![vscode-animation-preview-en.gif](https://static.robomico.cn/posts/smooth-vscode/vscode-animation-preview-en.gif)
