# TXT 阅读器 - 项目结构

本文档详细说明了项目的文件结构和组织方式。

## 📁 项目目录结构

```
TxtReader/
├── .github/
│   └── workflows/
│       └── build.yml                 # GitHub Actions 自动构建配置
├── TxtReader/
│   ├── TxtReaderApp.swift           # App 入口文件
│   ├── Info.plist                   # 应用配置文件
│   │
│   ├── Models/                      # 数据模型层
│   │   ├── Book.swift              # 书籍模型
│   │   ├── ReadingProgress.swift   # 阅读进度模型
│   │   ├── Bookmark.swift          # 书签和标注模型
│   │   ├── WebDAVAccount.swift     # WebDAV 账户模型
│   │   ├── Chapter.swift           # 章节模型
│   │   └── ReaderSettings.swift    # 阅读设置模型
│   │
│   ├── Services/                    # 业务逻辑层
│   │   ├── WebDAV/
│   │   │   ├── WebDAVClient.swift          # WebDAV 客户端
│   │   │   └── WebDAVCredentialManager.swift # 钥匙串凭证管理
│   │   ├── Encoding/
│   │   │   ├── EncodingDetector.swift      # 智能编码识别
│   │   │   └── TextDecoder.swift           # 文本解码器
│   │   ├── Reader/
│   │   │   ├── TextParser.swift            # 文本解析器
│   │   │   ├── ChapterDetector.swift       # 章节自动识别
│   │   │   ├── PaginationEngine.swift      # 分页引擎
│   │   │   └── StreamReader.swift          # 流式读取
│   │   └── Storage/
│   │       └── DataManager.swift           # 本地数据管理
│   │
│   ├── ViewModels/                  # 视图模型层
│   │   ├── WebDAVViewModel.swift    # WebDAV 视图模型
│   │   ├── ReaderViewModel.swift    # 阅读器视图模型
│   │   └── SettingsViewModel.swift  # 设置视图模型
│   │
│   ├── Views/                       # 用户界面层
│   │   ├── Main/
│   │   │   ├── ContentView.swift           # 主导航界面
│   │   │   ├── LibraryView.swift           # 本地书库界面
│   │   │   └── WebDAVBrowserView.swift     # WebDAV 浏览器界面
│   │   ├── Reader/
│   │   │   ├── ReaderView.swift            # 阅读器主界面
│   │   │   ├── PagedReaderView.swift       # 分页阅读模式
│   │   │   ├── ScrollReaderView.swift      # 滚动阅读模式
│   │   │   ├── TableOfContentsView.swift   # 目录视图
│   │   │   └── SearchView.swift            # 搜索视图
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift          # 设置界面
│   │   │   ├── EncodingPickerView.swift    # 编码选择器
│   │   │   └── ThemeSettingsView.swift     # 主题设置界面
│   │   └── Components/
│   │       ├── BookmarkListView.swift      # 书签列表视图
│   │       └── AnnotationView.swift        # 标注视图
│   │
│   └── Utilities/                   # 工具类
│       ├── KeyboardShortcuts.swift  # 键盘快捷键支持
│       └── AccessibilityHelpers.swift # 辅助功能助手
│
├── TxtReader.xcodeproj/
│   └── project.pbxproj              # Xcode 项目配置
│
├── README.md                        # 项目说明文档
├── LICENSE                          # MIT 许可证
├── .gitignore                       # Git 忽略文件配置
└── PROJECT_STRUCTURE.md             # 本文件（项目结构说明）
```

## 📊 文件统计

- **总文件数**: 约 35 个 Swift 源文件
- **代码行数**: 约 3000+ 行
- **主要语言**: Swift 5.0+
- **UI 框架**: SwiftUI
- **数据持久化**: SwiftData
- **最低支持版本**: iOS 17.0

## 🗂 模块说明

### 1. Models（数据模型）
定义应用的核心数据结构，使用 SwiftData 进行持久化。

- `Book`: 书籍信息（标题、作者、路径、编码等）
- `ReadingProgress`: 阅读进度（位置、章节、百分比等）
- `Bookmark`: 书签和标注（位置、摘录、笔记、颜色等）
- `WebDAVAccount`: WebDAV 账户信息
- `Chapter`: 章节信息
- `ReaderSettings`: 阅读器设置（字体、主题、间距等）

### 2. Services（业务逻辑）

#### WebDAV 服务
- `WebDAVClient`: 实现 WebDAV 协议，支持文件浏览和下载
- `WebDAVCredentialManager`: 使用 Keychain 安全存储账户密码

#### 编码服务
- `EncodingDetector`: 自动识别文本编码（UTF-8/16、GBK、Big5 等）
- `TextDecoder`: 解码文本并规范化换行符

#### 阅读器服务
- `TextParser`: 解析文本，分割段落，统计字数
- `ChapterDetector`: 智能识别章节标题（支持中文、英文多种格式）
- `PaginationEngine`: 基于 CoreText 的分页引擎
- `StreamReader`: 流式读取大文件

#### 存储服务
- `DataManager`: 统一管理 SwiftData 数据操作

### 3. ViewModels（视图模型）
遵循 MVVM 架构，连接视图和业务逻辑。

- `WebDAVViewModel`: 管理 WebDAV 连接和文件浏览
- `ReaderViewModel`: 管理阅读状态、进度、搜索、TTS 等
- `SettingsViewModel`: 管理阅读设置

### 4. Views（用户界面）

#### 主界面
- `ContentView`: TabView 导航（书库、WebDAV、设置）
- `LibraryView`: 本地书库，显示已添加的书籍
- `WebDAVBrowserView`: WebDAV 文件浏览器

#### 阅读器界面
- `ReaderView`: 阅读器主界面，包含菜单栏
- `PagedReaderView`: 分页模式（支持滑动、点击翻页）
- `ScrollReaderView`: 滚动模式
- `TableOfContentsView`: 章节目录
- `SearchView`: 全文搜索

#### 设置界面
- `SettingsView`: 应用设置
- `EncodingPickerView`: 编码选择器（带实时预览）
- `ThemeSettingsView`: 阅读设置（字体、主题、间距等）

#### 组件
- `BookmarkListView`: 书签列表
- `AnnotationView`: 添加标注和笔记

### 5. Utilities（工具类）
- `KeyboardShortcuts`: iPad 外接键盘快捷键支持
- `AccessibilityHelpers`: VoiceOver、动态字体等辅助功能

## 🎨 设计模式

1. **MVVM 架构**: 视图、视图模型、模型分离
2. **依赖注入**: 使用 Environment 传递 ModelContext
3. **单例模式**: DataManager、WebDAVCredentialManager
4. **观察者模式**: ObservableObject + @Published
5. **异步并发**: async/await + Task

## 🔧 核心技术

- **SwiftUI**: 声明式 UI 框架
- **SwiftData**: 数据持久化
- **Keychain Services**: 安全存储密码
- **CoreText**: 文本排版和分页
- **AVFoundation**: TTS 语音合成
- **URLSession**: 网络请求
- **XMLParser**: 解析 WebDAV 响应

## 📦 构建流程

1. 代码推送到 GitHub
2. GitHub Actions 自动触发构建
3. 使用 `macos-latest` runner
4. 编译 iOS 应用（未签名）
5. 打包成 IPA 文件
6. 上传到 Artifacts
7. 创建 Release（如果是 main 分支）

## 🎯 特性清单

✅ WebDAV 在线阅读  
✅ 智能编码识别（10+ 种编码）  
✅ 分页/滚动双模式  
✅ 自动章节识别  
✅ 全文搜索  
✅ 书签和标注  
✅ 阅读进度自动保存  
✅ 多主题支持  
✅ 字体、字号、间距自定义  
✅ TTS 语音朗读  
✅ iPad 分屏支持  
✅ 键盘快捷键  
✅ VoiceOver 支持  
✅ 动态字体  
✅ 横竖屏适配  

## 📝 开发笔记

- 所有文本统一使用 UTF-8 内部处理
- 使用 CoreText 实现精确分页
- WebDAV 使用 HTTP Basic Auth
- 密码通过 Keychain 安全存储
- 支持大文件流式读取
- 自动检测 BOM 并处理
- 统一换行符为 `\n`
- 章节识别支持正则表达式匹配
- 分页引擎支持动态字体大小
- 搜索优先当前章节，然后全书

## 🚀 后续优化方向

- [ ] 支持 EPUB/MOBI 格式
- [ ] 云端同步阅读进度
- [ ] 笔记导出功能
- [ ] 更多主题和字体
- [ ] 统计功能（阅读时长、字数等）
- [ ] 夜间模式自动切换
- [ ] iCloud 备份
- [ ] iPad 多窗口支持
- [ ] Apple Pencil 深度集成
- [ ] 机器翻译集成

---

**项目完成时间**: 2025年  
**最后更新**: 2025年10月

