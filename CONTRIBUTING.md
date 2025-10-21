# 贡献指南

感谢你对 TXT 阅读器项目的关注！我们欢迎各种形式的贡献。

## 🤝 如何贡献

### 报告 Bug

如果你发现了 Bug，请：

1. 检查 [Issues](../../issues) 中是否已有相同问题
2. 如果没有，创建新 Issue
3. 使用清晰的标题
4. 提供详细的重现步骤
5. 包含设备信息、系统版本
6. 如可能，附上截图或日志

**Bug 报告模板**：

```markdown
### 问题描述
简要描述遇到的问题

### 重现步骤
1. 打开应用
2. 点击...
3. 发生...

### 预期行为
描述你期望发生什么

### 实际行为
描述实际发生了什么

### 环境信息
- 设备型号: iPad Pro 11 (2021)
- 系统版本: iPadOS 17.2
- 应用版本: 1.0.0

### 截图
如有可能，附上截图
```

### 建议新功能

如果你有好的想法：

1. 创建 Feature Request Issue
2. 详细描述功能和使用场景
3. 说明为什么这个功能有用
4. 可以包含设计草图或示例

**功能建议模板**：

```markdown
### 功能描述
简要描述建议的功能

### 使用场景
为什么需要这个功能？解决什么问题？

### 建议的实现方式
（可选）如何实现这个功能

### 替代方案
（可选）其他可能的解决方案
```

### 贡献代码

我们欢迎 Pull Requests！

#### 开发环境设置

1. **克隆仓库**
   ```bash
   git clone https://github.com/YOUR_USERNAME/TxtReader.git
   cd TxtReader
   ```

2. **环境要求**
   - macOS 13.0 或更高
   - Xcode 15.0 或更高
   - 了解 Swift 和 SwiftUI

3. **在 Xcode 中打开项目**
   ```bash
   open TxtReader.xcodeproj
   ```

4. **选择目标设备**
   - 选择 iPad 模拟器或连接真机
   - 最低支持 iOS 17.0

5. **运行项目**
   - 按 ⌘R 或点击运行按钮
   - 首次运行可能需要安装依赖

#### 代码规范

遵循以下规范：

1. **Swift 代码风格**
   - 使用 4 空格缩进
   - 遵循 [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
   - 使用清晰的变量和函数命名

2. **注释**
   - 复杂逻辑添加注释
   - 使用 `// MARK:` 分隔代码段
   - 公共 API 添加文档注释

3. **SwiftUI 最佳实践**
   - 保持视图简洁
   - 提取复杂视图为独立组件
   - 使用 @State、@Binding、@ObservedObject 等正确管理状态

4. **文件组织**
   - 新文件放在正确的目录
   - 遵循项目现有结构
   - 一个文件一个主要类型

#### 提交 Pull Request

1. **创建分支**
   ```bash
   git checkout -b feature/your-feature-name
   # 或
   git checkout -b fix/bug-description
   ```

2. **编写代码**
   - 保持提交小而专注
   - 频繁提交
   - 写清晰的提交信息

3. **提交信息规范**
   ```
   类型: 简短描述（不超过 50 字符）

   详细描述（可选）
   - 解释为什么做这个改动
   - 说明改动的影响
   ```

   类型可以是：
   - `feat`: 新功能
   - `fix`: Bug 修复
   - `docs`: 文档更新
   - `style`: 代码格式（不影响功能）
   - `refactor`: 重构
   - `perf`: 性能优化
   - `test`: 测试
   - `chore`: 构建/工具改动

4. **推送分支**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **创建 Pull Request**
   - 访问 GitHub 仓库
   - 点击 "New Pull Request"
   - 选择你的分支
   - 填写 PR 描述：
     - 改动内容
     - 相关 Issue
     - 测试情况
     - 截图（如果是 UI 改动）

6. **代码审查**
   - 等待维护者审查
   - 根据反馈修改代码
   - 保持讨论友好和建设性

7. **合并**
   - 审查通过后会被合并
   - 删除你的分支

## 📝 开发指南

### 项目架构

项目采用 MVVM 架构：

```
View (SwiftUI) → ViewModel (ObservableObject) → Model + Services
```

- **View**: 纯 UI，不包含业务逻辑
- **ViewModel**: 处理用户交互，调用 Services
- **Model**: 数据模型（SwiftData）
- **Services**: 业务逻辑（WebDAV、编码识别、分页等）

### 添加新功能

1. **规划**
   - 在 Issue 中讨论
   - 设计 API 和数据流
   - 考虑向后兼容

2. **实现**
   - Model: 定义数据结构
   - Service: 实现业务逻辑
   - ViewModel: 连接 View 和 Service
   - View: 创建 UI

3. **测试**
   - 在模拟器和真机上测试
   - 测试不同的 iPad 尺寸
   - 测试横竖屏
   - 测试深色/浅色模式
   - 测试辅助功能（VoiceOver）

4. **文档**
   - 更新 README.md
   - 添加代码注释
   - 更新相关文档

### 编码检查清单

提交前确保：

- [ ] 代码编译无错误无警告
- [ ] 遵循代码规范
- [ ] 添加必要的注释
- [ ] UI 在不同设备上正常显示
- [ ] 支持深色模式
- [ ] 支持动态字体
- [ ] 没有硬编码的字符串（考虑本地化）
- [ ] 处理了错误情况
- [ ] 没有内存泄漏

## 🌍 国际化

目前应用主要支持中文，欢迎贡献其他语言：

1. 提取所有字符串到 Localizable.strings
2. 添加新语言文件
3. 测试不同语言下的 UI 布局

## 📚 资源

- [Swift 官方文档](https://docs.swift.org/)
- [SwiftUI 教程](https://developer.apple.com/tutorials/swiftui)
- [SwiftData 文档](https://developer.apple.com/documentation/swiftdata)
- [人机界面指南](https://developer.apple.com/design/human-interface-guidelines)

## ❓ 问题和帮助

- **技术问题**: 创建 Issue
- **功能讨论**: 使用 GitHub Discussions
- **安全问题**: 请私下联系维护者

## 📜 行为准则

参与本项目即表示你同意遵守以下准则：

- **友好和尊重**: 对所有贡献者友好
- **建设性**: 提供有建设性的反馈
- **包容**: 欢迎不同背景和经验的人
- **专业**: 保持讨论专业和相关

## 🎯 优先级

我们特别欢迎以下方面的贡献：

### 高优先级
- Bug 修复
- 性能优化
- 编码识别准确性提升
- 辅助功能改进

### 中优先级
- 新功能（先讨论再实现）
- UI/UX 改进
- 文档完善
- 测试覆盖

### 低优先级
- 代码重构（需要充分理由）
- 依赖更新
- 工具改进

## 🏆 贡献者

感谢所有贡献者！你们的名字会出现在这里。

<!-- 贡献者列表会自动更新 -->

## 📄 许可证

贡献的代码将使用 MIT 许可证发布。

---

**再次感谢你的贡献！** 🙏

