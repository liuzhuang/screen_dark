# ScreenDark 产品营销上下文

**Document version:** v10
**Last updated:** 2026-08-10
**Status:** 官网保持三屏，Hero 已更换为双显示器产品界面图，并改用中性黑白灰与本地中文字体栈；ScreenDark Skill、Agent 配置继续使用相同的核心定位和能力边界。公开下载仍受 GitHub 私有仓库阻塞，真实用户反馈、硬件兼容性和转化数据待补充。

## Product Overview

**品牌名称：** ScreenDark
**中文 UI 名称：** 暗屏助手
**中文渠道首次称呼：** ScreenDark（暗屏助手）
**One-liner：** ScreenDark 是一款免费的 Mac 多显示器菜单栏工具：离开工位或从手机继续 Codex 时，可以让留在桌上的内建屏幕和外接显示器一起视觉变黑；坐在工位前时，也可以单独调暗暂时不用或太刺眼的一块屏幕。
**What it does：** ScreenDark 通过 Gamma 调节分别控制内建屏幕和外接显示器。任一显示器处于 `0%` 时，它会请求 macOS 在系统层面保持所有显示器唤醒，并阻止空闲系统睡眠；返回后可用固定快捷键恢复系统 Gamma 并点亮全部显示器。ScreenDark 不主动触发锁屏，也不修改屏幕保护程序或自动锁定设置。
**Product category：** macOS 多显示器暗屏与视觉亮度控制工具。
**Product type：** 本地运行的 macOS 菜单栏工具。
**Distribution：** 目标渠道为 GitHub Release 安装包和源码安装。当前仓库为私有，公开官网上线前必须先解决访客下载权限；当前源码能力与已发布安装包仍需分别核对。
**Business model：** 免费提供，可使用「免费」「免费下载」「免费使用」。当前仓库未发现许可证文件，因此不得由「免费」推导出「开源」、特定商业授权或「永久免费」。
**Current platform：** macOS 13 或更高版本；当前预构建安装包面向 Apple Silicon；外接显示器需要支持 macOS Gamma 调节。

### Distribution state on 2026-08-09

- 本地最新标签为 `v0.2.0`；当前 `HEAD` 比该标签多 8 个提交。
- 登录时启动、亮度持久化、新亮度滑杆和后续界面调整位于 `v0.2.0` 之后，不能直接写成当前 `v0.2.0` DMG 已提供的能力。
- 当前 `main` 比本地 `origin/main` 多 2 个菜单栏图标提交。
- 「暗屏助手」标题和退出按钮仍是未提交的工作区改动，安装包和对外品牌仍为 `ScreenDark`。
- 已通过登录态 GitHub 元数据核验：最新 Release 为 `v0.2.0`，发布于 2026-08-04，包含 `ScreenDark-macos-arm64.dmg` 和对应 SHA-256 文件。
- GitHub 仓库当前为 `PRIVATE`。官网的 `/releases/latest` 下载按钮对未登录且无权限的访客不可用，不能把当前页面视为已具备公开发布条件。
- Release 元数据只能证明安装包存在及其架构命名，不能证明该 DMG 已包含 `v0.2.0` 之后的界面、持久化或快捷键语义。

## Positioning & Messaging Hierarchy

**Core positioning：** 给需要离开工位或从手机继续 Codex、同时让 Mac 留在桌上运行任务的人使用的多显示器暗屏工具。
**Primary promise：** 离开工位，让内建屏幕和外接显示器都暗下来。
**Outcome line：** 屏幕暗下去，任务继续跑。
**Remote scenario line：** ChatGPT Remote 让你从手机继续指导 Codex，ScreenDark 让留在工位的屏幕黑下去。
**Precise expansion：** 离开工位时，让内建屏幕和外接显示器一起视觉变黑；如果已配置 ChatGPT Remote，可以从手机继续查看、指导和审批本机上的 Codex 任务；坐在工位前时，只调暗暂时不用或太刺眼的一块屏幕。当任一显示器处于 `0%` 时，ScreenDark 会请求 macOS 在系统层面保持所有显示器唤醒，并阻止空闲系统睡眠，但不会主动触发锁屏，也不会修改屏幕保护程序或自动锁定设置。Remote 能力来自 ChatGPT，不是 ScreenDark 的功能；主机仍须保持唤醒、联网并运行 ChatGPT 桌面 App。
**Category statement：** ScreenDark 不是普通护眼工具，也不是锁屏或物理关屏工具。它把逐屏视觉调暗、`0%` 黑屏期间保持显示器唤醒并阻止空闲系统睡眠，以及安全恢复放进同一个菜单栏流程。

### Message priority

| Priority | User-facing message | User outcome |
|----------|---------------------|--------------|
| 1 | 离开工位时让所有屏幕一起变黑 | 内建屏幕和外接显示器都不再显示画面，同时保持系统级显示唤醒并降低空闲系统睡眠中断任务的可能 |
| 2 | 用手机继续 Codex，留在工位的屏幕保持黑屏 | 在 ChatGPT Remote 中查看、指导和审批本机任务，不必让桌上的显示器持续显示画面 |
| 3 | 坐在工位前时只调暗其中一块 | 保留正在使用的屏幕，调暗暂时不用或太刺眼的那块屏幕 |
| 4 | 分别调整每块显示器的视觉亮度 | 根据工作状态独立控制内建屏幕和外接显示器 |
| 5 | 一键点亮全部 | 恢复所有显示器的系统 Gamma，并将界面亮度状态设为 `100%` |

### Positioning guardrails

- 「任务继续跑」是核心结果表达，不是对所有程序永不中断的保证。
- ScreenDark 只与已配置好的 ChatGPT Remote 配合使用，不提供手机远程控制，也不接管 Mac 或 Codex。
- ChatGPT Remote 的主机必须保持唤醒、联网并运行桌面 App；Mac 睡眠、断网或关闭 App 后，远程访问会停止。
- 只有任一显示器处于 `0%` 时，才会请求在系统层面保持所有显示器唤醒并阻止空闲系统睡眠；`1%`–`99%` 的调暗状态不会触发。
- 正文必须说明 ScreenDark 不处理主动睡眠、合盖、关机、主动锁屏或屏幕保护程序，也不修改自动锁定设置。
- 「黑屏」表示 Gamma 输出降为黑色，不表示关闭显示器电源或背光。
- 不将 ScreenDark 描述为隐私、安全锁定或节能工具。

## Target Audience

**Target companies：** 不适用。当前产品主要面向个人 Mac 用户。
**Decision-maker：** 安装和使用工具的 Mac 用户本人。
**Primary audience：** 使用 Mac 和外接显示器，正在运行 Codex、Claude Code、构建任务、下载任务或浏览器自动操作的开发者和自动化用户；其中优先覆盖已使用 ChatGPT Remote、会从手机继续 Codex 的极客用户。
**Secondary audience：** 坐在工位前，希望保留一块屏幕正常显示、同时调暗另一块屏幕的多显示器用户。
**Primary use case：** Mac 正在运行长任务，用户需要离开工位，希望内建屏幕和外接显示器一起变黑，但不希望 ScreenDark 主动锁定当前会话。
**Featured remote use case：** 用户完成 ChatGPT Remote 配对后离开工位，将 Mac 内建屏幕和外接显示器都调至 `0%` 视觉黑屏，再从手机继续查看、指导和审批本机上的 Codex 任务。
**Secondary use case：** 用户坐在工位前，只需要一块屏幕工作；另一块暂时不用、正在显示无需关注的任务，或者亮度太刺眼，因此需要单独调暗。

### Jobs to be done

- 当 Mac 正在运行长任务而我要离开工位时，让内建屏幕和外接显示器一起变黑，在系统层面保持显示器唤醒，并降低空闲系统睡眠中断任务的可能。
- 当我离开 Mac 但仍要从手机继续 Codex 时，让本机两块屏幕保持 `0%` 视觉黑屏，同时在 ChatGPT Remote 中查看结果、回答问题和审批命令。
- 当我坐在工位前只使用一块屏幕时，单独调暗暂时不用或太刺眼的另一块屏幕。
- 当每块屏幕需要不同亮度时，分别调整内建屏幕和外接显示器的视觉亮度。
- 当我让所有屏幕变黑时，不由 ScreenDark 主动触发锁屏；如果主动锁屏或屏幕保护程序会影响任务，需要单独处理系统设置。
- 当我返回时，通过固定快捷键恢复系统 Gamma 并点亮全部显示器。

### Use cases

1. 离开工位：内建屏幕和外接显示器全部黑屏，帮助后台任务继续；实际结果取决于系统和程序状态。
2. 手机续接 Codex：完成 ChatGPT Remote 配对后，Mac 两块屏幕保持 `0%` 视觉黑屏，用户从手机继续查看、指导和审批本机任务；主机仍须唤醒、联网并运行桌面 App。
3. 坐在工位前：保留一块屏幕正常显示，单独调暗暂时不用或太刺眼的另一块。
4. 工作期间：分别调整内建屏幕和外接显示器的视觉亮度。
5. 浏览器或桌面自动操作需要 ScreenDark 保持系统级显示唤醒且不主动触发锁屏；实际是否继续还取决于主动锁屏、屏幕保护程序、程序状态、授权和屏幕捕获方式。
6. 使用快捷键恢复全部显示器，避免无法看见界面时失去控制。

## Problems & Pain Points

**Core problem：** 同一个用户在不同场景需要两种显示状态：离开工位或从手机继续 Codex 时让所有屏幕一起变黑；坐在工位前时只调暗暂时不用或太刺眼的一块。现有操作往往把「屏幕是否发光」「系统是否睡眠」「当前会话是否锁定」混在一起。
**Why current approaches fall short：**

- macOS 锁屏或睡眠更适合安全离开，但可能改变浏览器自动操作或桌面交互所依赖的会话状态。
- ChatGPT Remote 可以从手机继续 Codex，但不负责让留在工位的内建屏幕和外接显示器视觉变黑。
- 关闭显示器电源或使用显示器实体按键需要额外硬件操作，部分连接方式还可能改变显示器连接状态或窗口布局。
- `caffeinate` 可以阻止睡眠，但不负责逐屏调暗，用户仍需另一套亮度操作。
- 普通亮度工具可以调光，但不一定覆盖暗屏时阻止空闲睡眠、全部恢复和最后亮屏保护。

**What it costs them：** 屏幕持续发光、重复操作多套工具、离开后担心长任务因空闲睡眠暂停，以及返回后恢复显示状态的麻烦。
**Emotional tension：** 用户既想让画面消失，又担心锁屏、睡眠或错误的黑屏操作影响正在运行的任务，或导致自己无法恢复画面。

## Competitive Landscape

| Alternative | What it solves | Where it falls short for this use case |
|-------------|----------------|-----------------------------------------|
| 普通显示器亮度工具 | 调节显示器亮度 | 不一定组合逐屏黑屏、阻止空闲睡眠和安全恢复 |
| macOS 锁屏或睡眠 | 安全离开、降低屏幕可见性 | 可能不适合需要可交互会话的自动化；ScreenDark 本身也不负责关闭系统自动锁定 |
| 显示器电源键或硬件控制 | 关闭背光或显示器电源 | 依赖硬件，操作分散，也不负责 Mac 的空闲睡眠状态 |
| `caffeinate` 加手动调暗 | 保持 Mac 唤醒并降低亮度 | 需要两套操作，缺少逐屏 UI、亮度记忆和统一恢复 |

在完成竞品调研前，不使用「唯一」「首个」「其他工具都做不到」等排他性表述。

## Differentiation

**Key differentiators：**

- 在同一菜单栏界面中分别控制内建屏幕和外接显示器。
- 通过 Gamma 将指定显示器的视觉亮度降至 `0%`。
- 任一显示器处于 `0%` 时，请求 macOS 在系统层面保持所有显示器唤醒，并阻止空闲系统睡眠。
- 不主动触发锁屏，但也不修改屏幕保护程序或自动锁定设置。
- 提供固定的全部点亮快捷键 `⌃⌥⌘B`、单屏快捷键和独立恢复助手；固定快捷键恢复全部系统 Gamma，并将界面亮度状态设为 `100%`。
- 最后一块亮屏变黑前要求恢复助手就绪，降低全部画面不可见后无法恢复的风险。

**How we do it differently：** ScreenDark 将「选择显示器」「视觉调暗」「保持显示器唤醒并阻止空闲系统睡眠」「恢复画面」放在同一条操作路径中。
**Why that is better：** 用户不需要在显示器实体按键、亮度工具和保持唤醒命令之间切换。
**Why users choose us：** 用户需要的不是单纯调亮度，而是让指定屏幕变黑，同时尽量保持当前任务运行所需的会话状态。
**Remote complement：** ChatGPT Remote 负责手机端的会话访问，ScreenDark 负责本机显示器的视觉暗屏；两者配合，但互不替代。

## Objections

| Objection | Response |
|-----------|----------|
| 这是真的关屏吗？ | 不是。ScreenDark 通过 Gamma 让画面视觉变黑，显示器背光或电源可能仍然开启。 |
| 离开后可以保护隐私吗？ | 不能。ScreenDark 本身不触发锁屏，也不修改屏幕保护程序或自动锁定设置，不能作为隐私保护工具。 |
| 任务一定不会中断吗？ | 不能保证。只有任一显示器为 `0%` 时，ScreenDark 才请求在系统层面保持所有显示器唤醒并阻止空闲系统睡眠；任务还取决于主动锁屏、屏幕保护程序、程序状态、系统授权和屏幕捕获方式。 |
| ScreenDark 能让我从手机控制 Codex 吗？ | 不能。手机端能力来自 ChatGPT Remote；ScreenDark 只负责本机显示器的视觉暗屏，并在任一显示器为 `0%` 时请求保持所有显示器唤醒并阻止空闲系统睡眠。 |
| 黑屏后一定能从手机继续吗？ | 不能保证。ChatGPT Remote 要求主机保持唤醒、联网并运行桌面 App；功能开放、账号、工作区和本机配置也会影响可用性。 |
| 合盖后还能继续运行吗？ | 不保证。合盖和主动睡眠不在 ScreenDark 的处理范围内。 |
| 所有外接显示器都支持吗？ | 不保证。兼容性取决于显示器、连接方式和 macOS Gamma 支持。 |
| 能明显省电吗？ | 尚无功耗测量证据，不将节能作为卖点。 |
| 黑屏后如何恢复？ | 使用固定快捷键 `⌃⌥⌘B` 恢复全部系统 Gamma，并将显示器点亮到 `100%`；应用还提供恢复助手和异常退出后的 Gamma 恢复路径。 |

**Anti-persona：**

- 需要安全锁屏或隐私保护的用户。
- 需要物理关闭显示器、背光或明确节能效果的用户。
- 需要保证合盖、主动睡眠或所有程序永不中断的用户。
- 使用 Windows、Linux 或低于 macOS 13 的用户。
- 外接显示器或连接方式不支持 macOS Gamma 调节的用户。

## Switching Dynamics

**Push：** 离开工位后内建屏幕和外接显示器仍然亮着；坐在工位前又可能只想调暗其中一块；锁屏或睡眠可能改变任务运行条件；现有操作需要多个工具。
**Pull：** 一处完成逐屏调暗、保持空闲唤醒和全部恢复；特别适合 Mac 长任务、浏览器自动操作，以及从手机继续 Codex 的离席场景。
**Habit：** 继续使用显示器电源键、macOS 锁屏、`caffeinate` 或现有亮度工具。
**Anxiety：** 黑屏后无法恢复、外接显示器不兼容、任务仍会暂停、产品不是物理关屏，以及未锁定会话带来的安全风险。

## Customer Language

### Verbatim founder language

- 「将外接显示器黑屏，让外接显示器继续跑任务。」
- 「调整外接显示器的亮度。」
- 「将外接显示器和主显示器都黑屏，但是后台可以继续跑任务和浏览器自动操作。」
- 「当用户离开工位的时候，希望的是将两块屏幕变暗而不是只有外接显示器；人坐在工位前才希望将其中一块显示器变暗，他在处理任务或者屏幕太刺眼了。」
- 「因为 Codex 支持手机远程，这时候需要将主机黑屏。这个场景很符合极客的使用场景，尤其在推特的用户群。」

这些原话反映真实需求，但公开文案需要修正两个对象：任务运行在 Mac 上，不运行在显示器上；「主显示器」在 macOS 中也不一定等于 MacBook 的内建屏幕。

### Canonical public wording

- 「离开工位时，让内建屏幕和外接显示器都暗下来。」
- 「坐在工位前，只调暗暂时不用或太刺眼的那块屏幕。」
- 「分别调整内建屏幕和外接显示器的视觉亮度。」
- 「让所有屏幕一起黑屏，帮助后台任务和浏览器自动操作继续执行。」
- 「ChatGPT Remote 让你从手机继续指导 Codex，ScreenDark 让留在工位的屏幕黑下去。」
- 「离开工位后，两块屏幕保持 `0%` 视觉黑屏；在手机上继续查看、指导和审批 Codex。」
- 「屏幕黑下去，任务继续跑。」

### Words to use

- ScreenDark（暗屏助手）
- 外接显示器、内建屏幕、多显示器
- 离开工位、坐在工位前、所有屏幕一起变黑、只调暗其中一块
- 单独黑屏、视觉变暗、调整亮度、点亮全部
- 免费、免费下载、免费使用
- 后台任务、长任务、浏览器自动操作
- ChatGPT Remote、手机继续 Codex、查看结果、指导任务、审批命令
- 保持所有显示器唤醒、阻止空闲系统睡眠、不主动锁屏
- Gamma 调节、恢复系统 Gamma、恢复助手

### Words to avoid

- 物理关屏、真正熄屏、关闭背光
- 安全锁屏、隐私屏、保护隐私
- 永不休眠、保证任务不中断、所有自动化都会继续
- 明显省电、节能、省多少电
- 支持所有显示器、完全兼容
- 开源、永久免费、商业授权〔许可证确认前〕
- ScreenDark 远程控制 Mac、ScreenDark 内置 ChatGPT Remote、手机接管 Mac
- 合盖或离线后仍可继续、Codex 永久在线
- 智能、高效、领先、一站式、革命性等没有事实支撑的形容词

### Glossary

| Term | Meaning |
|------|---------|
| 暗屏／黑屏 | 将显示器 Gamma 输出降为黑色的视觉状态，不是物理关屏或系统锁屏 |
| 内建屏幕 | MacBook 自带的显示屏 |
| 外接显示器 | 通过线缆、扩展坞等方式连接到 Mac 的显示器 |
| 主显示器 | macOS 当前承载主菜单栏的显示器，不等同于内建屏幕 |
| `0%` | ScreenDark 中的全黑 Gamma 状态；任一显示器达到该状态时会请求保持所有显示器唤醒并阻止空闲系统睡眠 |
| 空闲系统睡眠 | macOS 因用户长时间没有输入而进入的系统睡眠，不包含主动睡眠、合盖、关机或锁屏 |
| 点亮全部 | 恢复所有显示器的系统 Gamma，将界面亮度状态设为 `100%`，并结束显示器与系统的空闲睡眠活动声明 |
| 恢复助手 | 用于在全部画面不可见或异常情况下恢复 Gamma 的独立辅助进程 |
| ChatGPT Remote | ChatGPT 手机 App 中访问已连接主机的入口，可继续 Codex 会话、发出后续指令、审批操作并查看结果；不是 ScreenDark 的功能 |

## Brand Voice

**Tone：** 克制、直接、可信。
**Style：** 先说用户正在做什么，再说具体结果，最后解释 Gamma、睡眠和安全边界。使用真实界面术语，不用抽象营销词。
**Personality：** 实用、冷静、诚实、开发者友好、重视恢复能力。
**Website visual direction：** 使用中性黑白灰，不使用蓝色强调色。Hero 展示双显示器产品界面；中文标题使用本地系统字体并保留宽松行距，不依赖外部字体 CDN。

### Channel voice

- **官网：** 最多三屏。第一屏给核心结果与下载，第二屏展示手机续接和单屏调暗，第三屏集中说明能力边界、恢复快捷键与下载细节。
- **X／Twitter：** 使用个人开发者账号和第一人称口吻，从「Codex 已经能在手机继续，但留在工位的屏幕没必要一直亮着」切入；这是面向开发者和极客用户的重点场景，回复补充 Remote 前提、Gamma 与安全边界。
- **README：** 使用完整、精确的技术描述，保留系统要求、兼容性和失败边界。

## Proof Points

### Verified product facts

| Fact | Current evidence |
|------|------------------|
| 可分别控制内建屏幕和外接显示器 | `Sources/ThanosLight/ThanosLightApp.swift`、`README.md` |
| 任一显示器为 `0%` 时保持所有显示器唤醒并阻止空闲系统睡眠 | `DisplayStore.updateIdleSleepActivity()` |
| 不主动触发锁屏，也不修改屏幕保护程序或自动锁定设置 | 当前实现、`README.md`、`website/screendark/SKILL.md` |
| 持久化每块显示器的非零亮度目标，用于重新识别显示器或下次启动时恢复 | `DisplayState`、`BrightnessPersistence`、`reloadDisplayList()` |
| 固定快捷键恢复全部系统 Gamma 并将显示器设为 `100%` | `restoreSystemGammaAll()`、`DisplayShortcut.recovery` |
| 单屏快捷键从黑屏点亮时使用主屏 `100%`、非主屏 `80%` 的默认目标 | `BrightnessLevel.shortcutTarget()`、`DisplayShortcut` |
| 提供最后亮屏保护、恢复助手和异常退出恢复 | `BlackoutSafety`、`RecoveryHelperProcess`、Gamma 恢复标记 |
| 支持登录时启动 | `LaunchAtLogin` 和应用 UI |
| 当前自动测试通过 | 2026-08-09 本地运行 `swift test`，15 项测试通过 |

自动测试和构建结果属于实现证据，不等于真实硬件兼容、任务持续运行或营销转化证据。

当前 15 项测试主要覆盖 Gamma 数学、黑屏守卫、快捷键、持久化和显示器排列逻辑；未覆盖真实 Gamma 硬件、`idleDisplaySleepDisabled` 与 `idleSystemSleepDisabled` 的系统效果、恢复助手进程、屏幕保护程序、自动锁定或 AI／浏览器任务。

### Verified ecosystem facts

| Fact | Current evidence |
|------|------------------|
| ChatGPT 手机 App 的 Remote 可访问已连接主机上的 Codex 会话，并支持继续会话、发指令、审批操作和查看输出 | [OpenAI：Remote connections](https://learn.chatgpt.com/docs/remote-connections) |
| Remote 主机必须保持唤醒、联网、登录同一账号与工作区，并运行最新版 ChatGPT 桌面 App；功能可用性可能因 rollout 或管理员设置而异 | [OpenAI：Remote connections](https://learn.chatgpt.com/docs/remote-connections) |

### Evidence still needed

- 用真实 Mac、外接显示器和外部相机拍摄核心场景的演示。
- 覆盖不同显示器、连接方式、扩展坞和 macOS 版本的兼容性记录。
- 任一显示器处于 `0%` 时，`idleDisplaySleepDisabled` 与 `idleSystemSleepDisabled` 同时生效的系统运行证据。
- Codex、Claude Code 和浏览器自动操作在典型场景下继续运行的前后日志。
- 从手机通过 ChatGPT Remote 继续 Codex，同时本机内建屏幕和外接显示器均为 `0%` 的端到端相机演示与任务日志。
- 不同屏幕捕获路径在 Gamma 全黑时是否仍可供自动化使用的验证。
- 退出、崩溃、热插拔、睡眠与唤醒后的真实硬件恢复测试。
- 真实用户原话、使用频率、安装成功率、GitHub Release 下载量和官网转化数据。
- 功耗测量；完成前不得使用节能卖点。

## Channel Messaging Baseline

### Website

**Eyebrow：** 免费的 macOS 多显示器暗屏工具
**Hero brand：** ScreenDark（暗屏助手）
**Hero headline：** 将屏幕变暗
**Hero support：** 分别调节内建屏幕和外接显示器。任一屏幕为 `0%` 时，请求 macOS 保持所有显示器唤醒并阻止空闲系统睡眠。
**Primary CTA：** 免费下载 Mac 版
**Primary CTA URL：** `https://github.com/liuzhuang/screen_dark/releases/latest`
**Secondary CTA：** 无。Hero 只保留一个下载动作。

**Recommended page order：**

1. 核心结果：离开工位时让内建屏幕和外接显示器一起变黑；同时提供下载 CTA、macOS 版本、安装包架构和 Gamma 兼容条件。
2. 两种补充状态：外接屏幕太刺眼时单独调暗外接显示器、手机续接 Codex。
3. 必要边界与下载：Gamma 视觉黑屏、`0%` 触发条件、非锁屏、任务不保证持续运行、恢复快捷键、签名公证状态和 ScreenDark Skill。

真实相机演示仍未加入官网；完成可验证素材后，应替换第二屏的部分说明，不新增第四屏。

### X／Twitter

**Account：** 个人开发者账号。
**Recommended hook：** Codex 已经可以通过 ChatGPT Remote 在手机上继续了，但留在工位的 Mac 屏幕没必要一直亮着。离开前，我会用「暗屏助手」把内建屏幕和外接显示器都调到 `0%`；人在外面，从手机继续查看、指导和审批 Codex。
**Supporting line：** Remote 让你从手机继续指导，ScreenDark 让桌上的屏幕黑下去。
**Body order：** 手机续接 Codex、双屏保持黑屏 → 离开工位时双屏一起变黑 → 坐在工位前单独调暗一块 → 分别调整亮度 → 真实演示。
**Boundary reply：** ScreenDark 不提供远程控制，也不是物理关屏或锁屏；它通过 Gamma 让画面视觉变黑，并且只有任一显示器处于 `0%` 时才请求保持所有显示器唤醒并阻止空闲系统睡眠。Remote 来自 ChatGPT，Mac 仍须联网并运行桌面 App。
**CTA：** 观看真实演示或从 GitHub 最新 Release 免费下载 Mac 版。

## Goals

**Business goal：** 让真正需要「屏幕变黑、Mac 任务继续」的用户快速理解产品并安装试用，同时收集真实硬件和使用场景反馈。
**Primary conversion action：** 点击官网主 CTA，直接从 GitHub 最新 Release 免费下载与官网所述能力一致的 Mac 版。
**Secondary actions：** 观看真实演示、查看 GitHub、阅读 ScreenDark Skill、提交兼容性或恢复问题。
**Current metrics：** 尚未建立统一基线。

### Metrics to establish

- 官网「下载 Mac 版」点击率。
- GitHub Release 下载量和版本分布。
- 安装成功率与 Gatekeeper 阶段流失。
- X／Twitter 演示视频播放完成率、链接点击和有效回复。
- 不同显示器和连接方式的成功／失败记录。
- 用户是否在长任务期间重复使用 ScreenDark。

## Source of Truth

- 当前源码运行行为与恢复机制：`Sources/ThanosLight/ThanosLightApp.swift`
- Gamma 实现：`Sources/ThanosLight/GammaController.swift`
- 恢复助手：`Sources/ThanosLightRecovery/ThanosLightRecovery.swift`
- 系统要求、版本和可见包名：`Info.plist`
- 当前文档声明与安装说明：`README.md`
- 当前官网文案：`website/index.html`
- 自动测试：`Tests/ThanosLightTests/GammaMathTests.swift`
- ChatGPT Remote 的能力与运行前提：[OpenAI：Remote connections](https://learn.chatgpt.com/docs/remote-connections)

发生冲突时，以目标发布版本的代码和安装包实测为准；README、官网和本文件需要随后同步，不能反向覆盖真实行为。

### Known copy drift

- 官网和 Skill 已按当前源码描述固定恢复快捷键；README 仍写成恢复各屏此前亮度。实际 `⌃⌥⌘B` 会恢复全部系统 Gamma，并将界面亮度状态设为 `100%`。
- 官网和 Skill 已改为点击或左右拖动设备屏幕调节亮度；README 仍保留「点击显示器卡片切换」的旧交互描述。
- 当前安装包和对外品牌仍为 `ScreenDark`；弹窗标题和退出按钮使用中文 UI 名「暗屏助手」。中文官网首次称呼统一为「ScreenDark（暗屏助手）」，但不要把中文 UI 文案调整误写成已经完成安装包、Bundle ID 和内部标识的全面重命名。
- 官网 Hero 已改为内建屏幕与外接显示器均为视觉黑屏，原来的一亮一暗素材保留在坐在工位前的次要场景。
- 官网已加入 ChatGPT Remote 场景和主机运行前提，但仍缺少外部相机同时拍到黑屏 Mac、手机 Remote 界面和任务日志的端到端证据。
- 官网下载 CTA 已指向 GitHub 最新 Release，但仓库当前为私有；在解决公开下载权限前，这个 CTA 只适合有仓库访问权的账号。

## Open Questions

- 免费分发对应的许可证是否确定；确认前不得表述为开源或永久免费。
- X／Twitter 首发使用中文、英文还是双语。
- 公开下载采用公开 GitHub 仓库，还是独立托管 DMG 与校验文件。
- 下一次官网发布面向已发布 `v0.2.0`，还是等待包含当前源码能力的新版本。
- 哪些真实外接显示器、连接方式和浏览器自动操作流程已经完成硬件验证。
- 目标账号与工作区是否已开放 ChatGPT Remote，以及手机续接 Codex 的端到端演示能否稳定复现。
- 是否已有可公开的用户反馈、下载数据或任务运行案例。

## Changelog

*Newest first. One line per revision: what changed and why.*

- v10 (2026-08-10) — 同步任一显示器为 `0%` 时保持所有显示器唤醒并阻止空闲系统睡眠的新行为，同时保留屏幕保护程序和主动锁屏边界。
- v9 (2026-08-10) — 将「外接屏幕太刺眼」调整为第二屏的第一张场景卡片。
- v8 (2026-08-10) — 精简 Hero 标题；将单屏场景改为「外接屏幕太刺眼」；更新第三屏标题。
- v7 (2026-08-10) — Hero 更换为双显示器产品界面图，页面改为无蓝色的中性黑白灰，并优化中文标题断行、间距和本地字体回退。
- v6 (2026-08-10) — 按官网标注意见更新 Hero 和场景标题，删除单屏状态示意与三步流程，保留三屏结构和第三屏能力边界。
- v5 (2026-08-09) — 将官网压缩为三屏：Hero 承担离开工位主场景，第二屏合并补充场景与使用流程，第三屏合并边界、恢复和下载。
- v4 (2026-08-09) — 同步已实现的官网、Skill 与 Agent 文案；记录 `v0.2.0` Release 资产和仓库私有状态，明确公开下载仍是上线阻塞。
- v3 (2026-08-09) — 增加「暗屏离席，手机续接 Codex」场景并提升为 X／Twitter 重点传播角度；明确 ChatGPT Remote 负责远程会话，ScreenDark 只负责本机视觉暗屏与 `0%` 时阻止空闲系统睡眠。
- v2 (2026-08-09) — 将主场景从「外接显示器单独变暗」调整为「离开工位时两块屏幕一起变暗」；确认免费分发、中文首次名称、个人 X／Twitter 账号和最新 Release 直达 CTA。
- v1 (2026-08-09) — Initial context：基于当前代码、README、官网和创作者提出的三个核心场景，建立产品定位、受众、消息优先级、能力边界与证据缺口。
