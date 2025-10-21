#!/bin/bash

echo "========================================"
echo "   Read-TXT 项目上传到 GitHub"
echo "========================================"
echo

echo "步骤 1/5: 配置 Git 用户信息"
echo "========================================"
echo
read -p "请输入您的 GitHub 用户名: " USERNAME
read -p "请输入您的 GitHub 邮箱: " EMAIL

echo
echo "正在配置 Git..."
git config --global user.name "$USERNAME"
git config --global user.email "$EMAIL"
echo "✓ Git 配置完成"
echo

echo "步骤 2/5: 添加文件到 Git"
echo "========================================"
git add .
echo "✓ 文件已添加"
echo

echo "步骤 3/5: 创建提交"
echo "========================================"
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
echo "✓ 提交已创建"
echo

echo "步骤 4/5: 关联 GitHub 仓库"
echo "========================================"
echo
echo "请先在 GitHub 上创建仓库:"
echo "1. 访问: https://github.com/new"
echo "2. 仓库名: Read-TXT"
echo "3. 不要勾选任何初始化选项"
echo "4. 点击 Create repository"
echo
read -p "创建完成后，按 Enter 继续..."

echo
echo "正在关联远程仓库..."
git remote add origin "https://github.com/$USERNAME/Read-TXT.git"
echo "✓ 远程仓库已关联"
echo

echo "步骤 5/5: 推送到 GitHub"
echo "========================================"
echo
echo "正在推送代码到 GitHub..."
echo "如果需要认证，请输入您的 GitHub Personal Access Token"
echo "(不是密码！请访问 https://github.com/settings/tokens 创建)"
echo
git push -u origin main

echo
echo "========================================"
echo "   上传完成！"
echo "========================================"
echo
echo "访问您的仓库: https://github.com/$USERNAME/Read-TXT"
echo
echo "接下来："
echo "1. 查看 Actions 标签页，等待自动构建"
echo "2. 构建完成后在 Releases 下载 IPA 文件"
echo

