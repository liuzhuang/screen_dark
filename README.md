# ScreenDark

ScreenDark 是一款 macOS 菜单栏工具。它通过 Gamma 调节让指定显示器变暗，不主动锁定当前会话；只要至少一块显示器处于 `0%` 状态，就会请求 macOS 阻止空闲系统睡眠。

适合在离开工位、继续运行长任务时隐藏屏幕内容，避免后台 AI 程序、Codex、Claude Code 或 Computer Use 因空闲系统睡眠而暂停。

- 分别控制内建屏幕和外接显示器
- 一块或多块显示器变暗时阻止空闲系统睡眠
- 保存每块显示器变暗前的亮度，点亮时恢复
- 支持为每块显示器设置独立的全局快捷键
- 提供固定的全部点亮快捷键和独立恢复助手

产品页面：[screen-dark-bay.vercel.app](https://screen-dark-bay.vercel.app)

## 能力边界

ScreenDark 的「变暗」是视觉状态，不是安全锁定：

- 不会锁定 macOS，也不会阻止键盘、鼠标或远程操作。
- 不会物理关闭显示器，而是将显示器的 Gamma 输出降为黑色。
- 只阻止空闲系统睡眠，不阻止主动睡眠、合盖、关机或系统锁定。
- 外接显示器需要支持 macOS Gamma 调节；部分显示器或连接方式可能不响应。
- ScreenDark 不锁定当前会话，因此后台 AI 程序和 Computer Use 可以继续运行；实际执行情况仍取决于相关程序、系统授权与屏幕捕获方式。

如需离开不可信环境，应同时使用 macOS 锁屏。

## 安装

### 从 GitHub Release 安装

1. 打开 [最新 Release](https://github.com/liuzhuang/screen_dark/releases/latest)。
2. 下载 `ScreenDark-macos-arm64.dmg` 和对应的 SHA-256 文件。
3. 运行 `shasum -a 256 -c ScreenDark-macos-arm64.dmg.sha256` 校验下载文件。
4. 打开 DMG，将 `ScreenDark.app` 拖入「应用程序」文件夹。
5. 启动 ScreenDark，菜单栏会显示应用入口。

当前发布包面向 Apple Silicon Mac，并使用 ad-hoc 签名，尚未完成 Apple Developer ID 签名和公证。macOS 首次启动时可能显示 Gatekeeper 提示，可在 Finder 中右键应用并选择「打开」。

### 从源码安装

源码构建需要 macOS 13 或更高版本，以及 Xcode Command Line Tools。

```bash
git clone https://github.com/liuzhuang/screen_dark.git
cd screen_dark
bash reinstall.sh
```

安装脚本会构建 Release 版本、安装到 `~/Applications/ScreenDark.app` 并启动应用。设置 `NO_LAUNCH=1` 可跳过自动启动。

## 使用

1. 点击菜单栏中的 ScreenDark 图标。
2. 在内建屏幕或外接显示器卡片中调整亮度。
3. 点击显示器卡片，可在「变暗」和「点亮」之间切换。
4. 一块或多块显示器变暗后，ScreenDark 会持续阻止空闲系统睡眠。
5. 退出应用或点亮全部显示器时，会恢复 Gamma 设置并结束系统活动声明。

## 快捷键

- `⌃⌥⌘B`：点亮全部显示器，并恢复各屏此前的亮度。
- 每块显示器可设置独立快捷键：点击显示器卡片中的「设置快捷键」，然后按下包含 `⌃`、`⌥` 或 `⌘` 的组合键。
- `Esc`：取消快捷键录入。
- `Delete`：清除正在设置的快捷键。

`⌃⌥⌘B` 保留给安全恢复，不能分配给单块显示器。

## 系统要求

- macOS 13 或更高版本
- Release 安装包：Apple Silicon Mac
- 源码构建：Swift 5.9 和 Xcode Command Line Tools
- 外接显示器：支持 macOS Gamma 调节

## 构建与测试

```bash
swift test
swift build -c release
```

如需验证完整应用包，可安装到临时目录并禁止自动启动：

```bash
INSTALL_DIR="$(mktemp -d)" NO_LAUNCH=1 ./reinstall.sh
```

## 发布

GitHub Actions 会在提交到 `main`、创建 Pull Request 或手动触发时运行测试并生成构建产物。推送 `v*` 标签后，会自动创建 GitHub Release，并附带 Apple Silicon DMG 与 SHA-256 校验文件。

```bash
git tag v0.2.0
git push origin v0.2.0
```

发布前应确认测试通过，并检查 DMG 中的应用名称、签名状态和 SHA-256 校验结果。
