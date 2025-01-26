---
title: How to make your VSCode as smooth as butter
date: 2024-02-21 21:21:30 +0800
categories: [Tutorials]
tags: [en, vscode]
lang: en
---

~~the first geek blog post yippee~~

4 years ago when I installed Microsoft Office 2016 on my computer for the first time, I was fascinated by their super cool and smooth animations. You know, as a Office 2006 & WPS Office user at that time, can you imagine that the text cursor will follow your mouse pointer as you click around?

As for VSCode, it has been animation-less since I met it when I was only 10 - Everything just pop up and disappear immediately, no fade in/out (well except the notification bubble). I mean, they are both the products from Microsoft, is it just that the developers of VSCode don't have a good taste?

Actually no, they _did_ make that feature in vanilla VSCode, but it is just disabled by default. So this post will give some guides on how to animation-ize your VSCode, by simply tweaking some options in settings page, and maybe also installing one or two extensions for even more impressive visual effects.

## Smooth Animation Settings in Vanilla VSCode

By the way, vanilla VSCode represents for bare-bone installation of VSCode without any extensions. I don't have a term in my vocabulary for that thing so I just adapt the word from Minecraft.

Press `Ctrl+,` ~~(I'm not mean to disrespect macOS users sorry)~~ to open Settings page, and search "smooth". If your VSCode version is `1.86.2`, which is the same as mine, you can get 6 options (actually only 4 of them are useful). Here is my setting for reference:

![vscode-smooth-settings-en.png](https://static.robomico.cn/posts/smooth-vscode/vscode-smooth-settings-en.png)

Here is the effects preview GIF:

![vscode-smooth-settings-preview-en.gif](https://static.robomico.cn/posts/smooth-vscode/vscode-smooth-settings-preview-en.gif)

## More Animations with Extensions

If you think this is not enough, there is an extension called "VSCode Animations" that provides even more smooth animations for almost all components in your editor. Simply search and install it in the marketplace (the ID is `BrandonKirbyson.vscode-animations`).

It is a little tricky to install at the first time, though. First you have to click the "Change Install Method" button when the notification bubble appears, and choose "Apc Customize UI++", because the default option "Custom CSS and JS" seems to be broken:

![vscode-animations-change-install-method.png](https://static.robomico.cn/posts/smooth-vscode/vscode-animations-change-install-method.png)
_Click the button on the right_

Then click "Install Apc Customize UI++" in the next bubble. This will install another dependent extension that injects the animation code into the VSCode resources file:

![vscode-animations-install-apc.png](https://static.robomico.cn/posts/smooth-vscode/vscode-animations-install-apc.png)
_Now click the button on the left_

Then the window will reload once or twice. If you are on Windows, the installation is done! However if you are Linux user like me, you may encounter the file permission issue:

![vscode-animations-error.png](https://static.robomico.cn/posts/smooth-vscode/vscode-animations-error.png)

Fixing is simple: turn on the read and write permission of VSCode resource folder for everyone (the folder path may vary depending on your Linux distro or the install method of VSCode):

```bash
sudo chmod o+rw /opt/visual-studio-code/resources -R
```

<!-- prettier-ignore-start -->
> **`sudo` at your own risk!** There are known issues that upgrading VSCode with modified file permissions may corrupt the installation. If you encounter this, please uninstall the two extensions, uninstall VSCode and install it back (your settings and user data will be kept).
{: .prompt-danger }
<!-- prettier-ignore-end -->

Then click "Install Now" on the notification bubble or run `>Animations: Install Animations` in the command palette to finish the install. After that, don't forget to lock back the write permission to prevent hidden security danger in the future:

```bash
sudo chmod o-w /opt/visual-studio-code/resources -R
```

The extension is fully configurable, so you can tinker around to find your favorite look and feel. Here is my settings:

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

Now enjoy your coding time with the brand new smooth VSCode!

![vscode-animation-preview-en.gif](https://static.robomico.cn/posts/smooth-vscode/vscode-animation-preview-en.gif)
