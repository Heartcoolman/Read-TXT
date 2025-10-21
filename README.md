# TXT 阅读器 - iPad 专业 TXT 在线阅读应用

一款专为 iPad 设计的功能强大的 TXT 阅读器，支持 WebDAV 在线阅读、智能编码识别、流畅的阅读体验。

## ✨ 主要特性

### 📚 WebDAV 在线阅读
- 连接 WebDAV 服务器（支持各种网盘）
- 账号密码安全保存在系统钥匙串
- 在线浏览目录，点击即可打开
- 流式读取，大文件也能快速加载

### 🔤 智能编码识别
- 自动识别多种编码：UTF-8、UTF-16、GB18030/GBK、Big5、Shift-JIS、ISO-8859-1、KOI8-R、EUC-KR 等
- 编码识别失败时可手动选择，实时预览效果
- 记住每本书的编码选择
- 自动处理 BOM 和统一换行符

### 📖 流畅阅读体验
- **双模式**：分页模式（省电）/ 滚动模式
- **自定义样式**：字体、字号、行距、页边距
- **主题**：明亮、暗黑、护眼色，可跟随系统
- **自动目录**：智能识别章节（支持"第X章/卷/节/回"等格式）
- **阅读进度**：自动保存，显示百分比和预计剩余时间
- **全文搜索**：快速查找关键词，显示所在章节
- **书签标注**：支持书签、高亮、笔记

### 🎯 iPad 特性优化
- 支持分屏多任务
- 外接键盘快捷键支持
- 横竖屏自适应
- Apple Pencil 批注（可选）

### ♿️ 辅助功能
- 系统 TTS 朗读
- VoiceOver 支持
- 动态字体
- 划词翻译（调用系统）

## 📦 安装方法

本应用通过 GitHub Actions 自动构建，生成未签名的 IPA 文件。

### 方法 1: AltStore
1. 在 iPad 上安装 [AltStore](https://altstore.io/)
2. 从 [Releases](../../releases) 下载最新的 IPA 文件
3. 通过 AltStore 安装应用

### 方法 2: Sideloadly
1. 在电脑上下载 [Sideloadly](https://sideloadly.io/)
2. 连接 iPad 到电脑
3. 使用你的 Apple ID 签名并安装 IPA

### 方法 3: TrollStore
如果你的设备已安装 TrollStore：
1. 下载 IPA 文件
2. 直接在 TrollStore 中安装

## 🛠 技术栈

- **框架**: SwiftUI
- **最低版本**: iOS 17+（针对 iOS 26 优化）
- **数据持久化**: SwiftData
- **安全存储**: Keychain Services
- **异步处理**: Swift Concurrency (async/await)

## 📱 系统要求

- iPadOS 17.0 或更高版本
- 建议在 iPad（第 6 代）或更新机型上使用

## 🚀 构建说明

本项目使用 GitHub Actions 自动构建，无需本地 Mac 环境！

### 自动构建

1. 推送代码到 `main` 或 `master` 分支
2. GitHub Actions 自动编译项目
3. 生成未签名的 IPA 文件
4. 自动创建 Release 并上传 IPA

### 手动触发构建

- 进入 Actions 标签页
- 选择 "Build iOS App" workflow
- 点击 "Run workflow"

### 下载 IPA

构建完成后，在以下位置下载：
- **Releases 页面**: https://github.com/Heartcoolman/Read-TXT/releases
- **Actions Artifacts**: 进入对应的 workflow run 下载

## 📖 使用说明

### 添加 WebDAV 账户
1. 打开应用，切换到 "WebDAV" 标签
2. 点击右上角 "+" 按钮
3. 输入账户信息：
   - 名称：自定义名称
   - 服务器地址：WebDAV 服务器 URL（如 `https://dav.jianguoyun.com/dav/`）
   - 用户名和密码
4. 点击"保存"

### 浏览和打开文件
1. 选择已添加的 WebDAV 账户
2. 浏览目录，找到 TXT 文件
3. 点击文件即可在线打开
4. 首次打开会自动检测编码，如有乱码可点击菜单中的"更改编码"

### 阅读设置
- 点击屏幕中央：显示/隐藏菜单
- 点击左侧：上一页（分页模式）
- 点击右侧：下一页（分页模式）
- 滑动：翻页（分页模式）
- 点击设置图标：调整字体、主题等

### 快捷键（外接键盘）
- 空格键：下一页
- Shift + 空格：上一页
- ⌘ + F：搜索
- ⌘ + T：目录
- ⌘ + B：书签

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## ⚠️ 免责声明

本应用为开源项目，仅供学习交流使用。使用未签名 IPA 需要自行承担风险。建议使用官方渠道分发应用。

## 📮 联系方式

如有问题或建议，请通过以下方式联系：
- 提交 [GitHub Issue](../../issues)
- 发起 [Discussion](../../discussions)

---

**享受流畅的阅读体验！** 📚✨

