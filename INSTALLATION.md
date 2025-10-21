# 安装指南

本文档提供详细的安装步骤，帮助你在 iPad 上安装 TXT 阅读器。

## 📋 前置条件

- iPad 设备（建议 iPad 第 6 代或更新）
- iPadOS 17.0 或更高版本
- Apple ID（用于签名）

## 🎯 安装方法

### 方法 1: AltStore（推荐）

AltStore 是一个免费的应用商店替代品，可以让你安装未签名的应用。

#### 步骤：

1. **在电脑上安装 AltServer**
   - Windows: 从 [AltStore 官网](https://altstore.io/) 下载
   - macOS: 同样从官网下载 Mac 版本

2. **在 iPad 上安装 AltStore**
   - 通过 USB 连接 iPad 到电脑
   - 运行 AltServer
   - 点击系统托盘中的 AltServer 图标
   - 选择 "Install AltStore" → 选择你的 iPad
   - 输入 Apple ID 和密码（仅用于签名，不会上传）

3. **信任开发者证书**
   - 在 iPad 上打开 设置 → 通用 → VPN与设备管理
   - 找到你的 Apple ID
   - 点击"信任"

4. **安装 TXT 阅读器**
   - 从本项目的 [Releases](../../releases) 页面下载最新的 IPA 文件
   - 将 IPA 文件传输到 iPad（通过 AirDrop、iCloud 或其他方式）
   - 在 iPad 上打开 AltStore
   - 点击 "我的应用" → "+" 图标
   - 选择下载的 IPA 文件
   - 等待安装完成

5. **刷新应用（每 7 天）**
   - 免费 Apple ID 签名的应用每 7 天需要刷新一次
   - 确保 iPad 和电脑在同一 WiFi 网络
   - 打开 AltStore，应用会自动刷新
   - 或者手动打开 AltServer 刷新

### 方法 2: Sideloadly

Sideloadly 是一个更强大的侧载工具，支持 Windows 和 macOS。

#### 步骤：

1. **下载安装 Sideloadly**
   - 访问 [Sideloadly 官网](https://sideloadly.io/)
   - 下载对应系统版本
   - 安装到电脑

2. **准备 IPA 文件**
   - 从 [Releases](../../releases) 下载最新的 IPA 文件

3. **连接 iPad**
   - 使用 USB 线连接 iPad 到电脑
   - 如果是第一次连接，需要在 iPad 上点击"信任此电脑"

4. **签名并安装**
   - 打开 Sideloadly
   - 将 IPA 文件拖入 Sideloadly 窗口
   - 选择连接的 iPad 设备
   - 输入 Apple ID（用于签名）
   - 点击 "Start" 开始签名和安装
   - 等待过程完成

5. **信任开发者**
   - 在 iPad 上打开 设置 → 通用 → VPN与设备管理
   - 点击你的 Apple ID
   - 点击"信任"

6. **自动刷新（可选）**
   - Sideloadly 支持 WiFi 刷新
   - 保持电脑和 iPad 在同一网络
   - 启用"Enable WiFi Sideloading"

### 方法 3: TrollStore（适用于已越狱设备）

如果你的设备支持 TrollStore，这是最方便的方法，应用永久安装，无需刷新。

#### 步骤：

1. **安装 TrollStore**
   - 检查你的设备是否支持：[TrollStore 兼容性](https://github.com/opa334/TrollStore)
   - 按照官方指南安装 TrollStore

2. **安装 TXT 阅读器**
   - 下载 IPA 文件到 iPad
   - 使用 Safari 或文件 App 打开 IPA
   - 选择 "在 TrollStore 中打开"
   - 点击"安装"
   - 完成！应用永久安装，无需刷新

### 方法 4: 开发者账号（推荐用于长期使用）

如果你有付费的 Apple 开发者账号（$99/年），可以获得一年有效期的签名。

#### 步骤：

1. **使用 Xcode**
   - 需要 Mac 电脑和 Xcode
   - 克隆本项目源代码
   - 在 Xcode 中打开项目
   - 使用你的开发者账号签名
   - 连接 iPad 直接安装

2. **使用 iOS App Signer**
   - 下载 [iOS App Signer](https://dantheman827.github.io/ios-app-signer/)
   - 导入你的开发者证书
   - 选择 IPA 文件
   - 选择证书和描述文件
   - 签名并安装到设备

## ⚠️ 常见问题

### 1. "无法验证应用"错误

**解决方案**：
- 检查 iPad 日期时间是否正确
- 确保已在"VPN与设备管理"中信任证书
- 重启 iPad 后再试

### 2. "应用已过期"（7天后）

**解决方案**：
- 使用 AltStore 自动刷新
- 或重新通过 Sideloadly 安装
- 考虑使用付费开发者账号（一年有效）

### 3. 安装时提示"证书无效"

**解决方案**：
- 撤销旧的证书（在 [Apple ID 管理页面](https://appleid.apple.com/)）
- 等待 10 分钟后重试
- 使用不同的 Apple ID

### 4. AltStore 无法连接到 AltServer

**解决方案**：
- 确保电脑和 iPad 在同一 WiFi 网络
- 关闭防火墙或添加 AltServer 例外
- Windows：确保 iTunes 和 iCloud 已安装
- 重启 AltServer 和 AltStore

### 5. 应用闪退或无法打开

**解决方案**：
- 检查 iPadOS 版本是否满足要求（17.0+）
- 重新安装应用
- 检查是否有崩溃日志（设置 → 隐私 → 分析与改进）
- 提交 Issue 到 GitHub

## 🔒 安全说明

1. **Apple ID 安全**
   - AltStore 和 Sideloadly 仅在本地使用你的 Apple ID
   - 不会上传到任何服务器
   - 建议使用单独的 Apple ID 用于侧载

2. **应用权限**
   - 应用仅请求必要的权限
   - WebDAV 密码安全存储在系统钥匙串
   - 不会收集任何个人信息

3. **数据隐私**
   - 所有数据存储在本地
   - 不会上传到云端
   - 书签和笔记仅保存在设备上

## 📱 系统要求

- **设备**: iPad（第 6 代或更新）
- **系统**: iPadOS 17.0 或更高
- **存储空间**: 至少 50 MB
- **网络**: WiFi（用于 WebDAV 功能）

## 🆘 获取帮助

如果遇到问题：

1. 查看本文档的常见问题部分
2. 搜索 [GitHub Issues](../../issues)
3. 提交新的 Issue，包含：
   - 设备型号
   - iPadOS 版本
   - 详细的错误描述
   - 截图或日志

## 🎉 安装完成

安装成功后，你可以：

1. 添加 WebDAV 账户连接网盘
2. 导入本地 TXT 文件
3. 自定义阅读设置
4. 开始享受流畅的阅读体验！

---

**祝你阅读愉快！** 📚

