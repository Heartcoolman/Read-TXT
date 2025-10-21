# GitHub 上传指南

本指南将帮助您将 Read-TXT 项目上传到 GitHub。

## 📋 准备工作

确保您已经：
- [x] 安装了 Git
- [ ] 拥有 GitHub 账户
- [ ] 已登录 GitHub

## 🚀 步骤 1: 配置 Git 用户信息

在命令行中运行以下命令（替换为您的信息）：

```bash
git config --global user.name "您的GitHub用户名"
git config --global user.email "您的GitHub邮箱"
```

例如：
```bash
git config --global user.name "zhangsan"
git config --global user.email "zhangsan@example.com"
```

## 🌐 步骤 2: 在 GitHub 上创建仓库

### 方法 1: 通过网页创建（推荐）

1. 访问 https://github.com/new
2. 填写仓库信息：
   - **Repository name**: `Read-TXT`
   - **Description**: `iPad 专业 TXT 阅读器 - 支持 WebDAV、智能编码识别、流畅阅读体验`
   - **Visibility**: 
     - 选择 `Public`（公开）或 `Private`（私有）
   - **初始化选项**:
     - ❌ **不要**勾选 "Add a README file"
     - ❌ **不要**勾选 "Add .gitignore"
     - ❌ **不要**选择 License（我们已经有了）
3. 点击 "Create repository" 按钮

### 方法 2: 使用 GitHub CLI（如果已安装）

```bash
gh repo create Read-TXT --public --source=. --remote=origin --description "iPad 专业 TXT 阅读器 - 支持 WebDAV、智能编码识别、流畅阅读体验"
```

## 📤 步骤 3: 提交并推送代码

### 3.1 配置好 Git 用户后，重新提交

```bash
# 回到项目目录
cd D:\txt

# 添加所有文件
git add .

# 创建初始提交
git commit -m "Initial commit: iPad TXT Reader - 完整功能实现

- ✅ WebDAV 在线阅读支持
- ✅ 智能编码识别（10+ 种编码）
- ✅ 分页/滚动双阅读模式
- ✅ 自动章节识别和目录
- ✅ 全文搜索功能
- ✅ 书签和标注
- ✅ TTS 语音朗读
- ✅ iPad 键盘快捷键
- ✅ VoiceOver 无障碍支持
- ✅ GitHub Actions 自动构建"
```

### 3.2 关联远程仓库

**替换 `YOUR_USERNAME` 为您的 GitHub 用户名**：

```bash
git remote add origin https://github.com/YOUR_USERNAME/Read-TXT.git
```

### 3.3 推送到 GitHub

```bash
git push -u origin main
```

### 如果遇到认证问题

您可能需要：

1. **使用 Personal Access Token (推荐)**
   - 访问 https://github.com/settings/tokens
   - 点击 "Generate new token" → "Generate new token (classic)"
   - 勾选 `repo` 权限
   - 生成 token 并复制
   - 推送时输入 token 作为密码

2. **或使用 GitHub CLI**
   ```bash
   gh auth login
   ```

## ✅ 步骤 4: 验证上传

1. 访问 `https://github.com/YOUR_USERNAME/Read-TXT`
2. 确认所有文件已上传
3. 检查 README.md 是否正确显示

## 🤖 步骤 5: 触发 GitHub Actions 构建

推送成功后：

1. 访问仓库的 "Actions" 标签页
2. 查看 "Build iOS App" workflow
3. 等待构建完成（约 5-10 分钟）
4. 构建成功后，在 "Releases" 页面下载 IPA 文件

## 🔧 故障排除

### 问题 1: 推送被拒绝

```bash
# 如果提示已存在内容，强制推送（谨慎使用）
git push -u origin main --force
```

### 问题 2: 认证失败

- 确保使用 Personal Access Token 而非密码
- 或使用 SSH：
  ```bash
  git remote set-url origin git@github.com:YOUR_USERNAME/Read-TXT.git
  ```

### 问题 3: 文件太大

查看哪些文件过大：
```bash
git ls-files | xargs ls -lh | sort -k5 -h -r | head -20
```

## 📝 完整命令速查

```bash
# 1. 配置 Git 用户（首次使用）
git config --global user.name "您的用户名"
git config --global user.email "您的邮箱"

# 2. 初始化仓库（已完成）
git init
git branch -M main

# 3. 添加和提交
git add .
git commit -m "Initial commit: iPad TXT Reader"

# 4. 关联远程仓库
git remote add origin https://github.com/YOUR_USERNAME/Read-TXT.git

# 5. 推送
git push -u origin main

# 6. 后续推送（不需要 -u）
git push
```

## 🎯 下一步

上传成功后：

1. 编辑 README.md，替换所有 `YOUR_USERNAME` 为实际用户名
2. 添加仓库描述和标签（Topics）
3. 启用 GitHub Pages（如果需要）
4. 设置仓库权限和协作者
5. 等待 Actions 构建完成并下载 IPA

## 📞 需要帮助？

如果遇到问题：
1. 检查错误消息
2. 参考 [GitHub 文档](https://docs.github.com/)
3. 或在项目中提出 Issue

---

**祝您上传顺利！** 🚀

