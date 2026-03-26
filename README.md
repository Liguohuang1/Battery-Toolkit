<p align="center">
 <img alt="Battery Toolkit 标志" src="Resources/LogoCaption.png" width=500 align="center">
</p>

<p align="center">精细控制你的 Apple 芯片 Mac 的供电状态。</p>

<p align="center"><strong>Language / 语言：</strong> <a href="README.en.md">English</a> &bull; <strong>简体中文</strong></p>

<p align="center"><a href="#功能">功能</a> &bull; <a href="#安装">安装</a> &bull; <a href="#使用">使用</a> &bull; <a href="#卸载">卸载</a> &bull; <a href="#限制">限制</a> &bull; <a href="#技术细节">技术细节</a> &bull; <a href="#捐助">捐助</a></p>

-----

# 功能

## 将电池充电上限限制在指定数值

现代电池如果长期维持满电，老化速度通常会更快。因此，Apple 在包括 Mac 在内的便携设备上加入了“优化电池充电”功能。不过，系统默认的上限无法自定义，也不能手动强制暂停充电。Battery Toolkit 可以让你设置一个硬性上限，超过该值后会关闭电池充电。出于安全考虑，这个上限不能低于 50&nbsp;%。

## 允许电量下降到较低阈值后再恢复充电

即使电源适配器一直连接着，Mac 的电池电量也可能因为各种原因缓慢下降。过于频繁的短时补电同样会加速电池老化。因此，Battery Toolkit 也支持设置一个下限：只有当电量低于该值时，才重新开启充电。出于安全考虑，这个下限不能低于 20&nbsp;%。

**注意：** 冷启动或重启后，这个设置不会立即生效，因为 Apple 芯片 Mac 在这些情况下会重置平台状态。此时 Battery Toolkit 启动时，充电往往已经在进行中；为了避免跨重启产生更多短时补电，它会让充电先继续进行到上限。

## 允许你停用电源适配器

如果你想主动让电池放电，例如做一次校准，可以在不拔掉充电器的情况下直接停用电源适配器。你也可以选择在电源适配器被停用时，同时阻止 Mac 进入睡眠。

**注意：** 重新启用电源适配器后，你的 Mac 可能会立刻进入睡眠。这是 macOS 的软件问题，暂时不容易规避。

|<img alt="电源设置" src="Resources/PowerSettings.png" width=607>|
|:--:|
| **图 1**. *电源设置* |

## 提供手动控制能力

Battery Toolkit 的“命令”菜单以及菜单栏图标支持你直接发出多种与供电状态相关的命令，包括：
* 启用或停用电源适配器
* 请求充满电
* 请求充到设定的上限
* 立即停止充电
* 暂停所有后台活动

|<img alt="菜单栏图标" src="Resources/MenuBarExtra.png" width=283>|
|:----------|
| **图 2**. *菜单栏图标* |

# 安装

> [!IMPORTANT]
> Battery Toolkit 目前仅支持 Apple Silicon Mac [#15](https://github.com/mhaeuser/Battery-Toolkit/issues/15)

### 手动安装
1. 打开 GitHub 的[发布页面](https://github.com/mhaeuser/Battery-Toolkit/releases/latest)
2. 下载最新的不带 dSYM 的发行包（例如 `Battery-Toolkit-X.Y.zip`）
3. 解压压缩包
4. 将 `Battery Toolkit.app` 拖到“应用程序”文件夹中

### 通过 Homebrew 安装 :beer:
1. 如果你还没有安装 [Homebrew](https://brew.sh)，请先安装
2. 打开终端并运行 `brew tap mhaeuser/mhaeuser`
3. 运行 `brew install battery-toolkit`

如果你想更方便地绕过 Gatekeeper，也可以在安装命令后加上 `--no-quarantine`，但请务必了解其中的安全风险。

否则，请继续按下面的步骤操作。

### 首次打开应用

> [!IMPORTANT]
> 这一步是必须的，因为该应用尚未经过 Apple 公证。原因并不是应用存在恶意行为，而是作者没有加入 Apple Developer Program 并支付相应费用。因此，系统提示“Apple could not verify 'Battery Toolkit.app' is free of malware”时，表达的是“未经过公证”，并不代表系统检测到了异常。可参考 Apple 关于[公证说明](https://support.apple.com/en-us/102445)的文档。

在 macOS 14 Sonoma 及更低版本上：
1. 右键点击 `Battery Toolkit.app`
2. 选择“打开”
3. 在弹窗中再次点击“打开”

在 macOS 15 Sequoia 及更高版本上：
1. 先尝试打开应用，系统会提示已被阻止
2. 前往 `系统设置 > 隐私与安全性`，滚动到页面底部
3. 点击“仍要打开”（Open Anyway）以允许 Battery Toolkit
4. 在下一步弹窗中再次选择“仍要打开”，并完成身份验证
5. 之后再从“应用程序”文件夹中打开 Battery Toolkit

# 使用

> [!CAUTION]
> 为了避免任何干扰，使用 Battery Toolkit 时，请务必关闭“优化电池充电”（Optimized Battery Charging）。<br>
> 路径：macOS `系统设置 > 电池 > 电池健康旁边的 (i) > 优化电池充电 > 关闭`

1. 从“应用程序”文件夹启动 Battery Toolkit
2. 菜单栏会切换为应用菜单，同时你应该能看到它的菜单栏图标
3. 可通过这两种入口之一来配置设置（见**图 2、图 3、图 4**）

|<img alt="主菜单" src="Resources/MenuBarMain.png" width=316>|<img alt="命令菜单" src="Resources/MenuBarCommands.png" width=248>|
|:----------|:----------|
| **图 3**. *主菜单* | **图 4**. *命令菜单* |

如果你愿意，也可以退出图形界面来隐藏菜单栏图标，Battery Toolkit 仍会继续在后台运行。
之后如果想修改设置，重新打开应用即可。

# 卸载

1. 切换到 Battery Toolkit
2. 打开菜单栏中的 Battery Toolkit 主菜单（见**图 3**）
3. 选择“停用后台活动”
4. 将应用移到废纸篓，并清空废纸篓

# 限制

Battery Toolkit 在充电过程中会阻止系统进入睡眠，因为它需要持续监测电量，并在达到最大值时主动停止充电。无论是达到上限、手动取消，还是拔掉电源，只要充电停止，睡眠功能就会重新启用。

当电脑处于关机状态时，应用（包括 Battery Toolkit）都无法控制充电行为。如果 Mac 关机时充电器仍然连接，电池会继续充到 100&nbsp;%。

另外，当电源适配器被停用时，通常也应一并阻止系统进入睡眠；否则合上上盖后，Clamshell（合盖外接显示器）模式会失效，机器很可能会立刻睡眠。相关开关可在设置面板中找到（见**图 1**）。

# 技术细节

* 基于 IOPowerManagement 事件实现，尽量降低资源占用，尤其是在未接通外部供电时
* 支持 macOS Ventura 引入的 daemon 与登录项机制，以获得更稳定的体验

## 本地打包

如果你是在自己的 Mac 上做 fork 开发，可以使用仓库里的本地打包脚本：

```bash
./scripts/local_release.sh
```

它会在一个临时副本里注入你本机的签名信息，再生成发布产物，因此不会把个人签名配置写回仓库。脚本退出时会自动清理临时目录，产物会输出到 `build/` 目录中。

## 安全性
* 所有特权操作都由守护进程完成鉴权
* 特权守护进程仅通过 XPC 暴露最小必要接口
* XPC 通信使用了较新的 macOS 代码签名校验能力

# 致谢
* 图标基于 [Streamline 的参考图标](https://seekicon.com/free-icon/rechargable-battery_1)
* README 由 [rogue](https://github.com/realrogue) 重新整理和润色

# 捐助

出于多方面考虑，我不接受个人捐助。
如果你愿意支持我在德国儿童保护协会 [Kinderschutzbund Kaiserslautern-Kusel](https://www.kinderschutzbund-kaiserslautern.de/) 的相关工作，欢迎通过[这个页面](https://www.kinderschutzbund-kaiserslautern.de/helfen-sie-mit/spenden/)进行捐助。
