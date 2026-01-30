# MindLog MVP 实施计划

> **MVP 目标**: 8-10 周完成核心日记功能 + AI 语音聊天 + 基础社区 UI  
> **开发者**: 登登  
> **开始时间**: 2026-01-29

---

## 📋 MVP 核心功能清单

### ✅ 核心功能（必做）

#### 1. 手帐编辑器
- [ ] 文字输入（支持富文本）
- [ ] 心情选择器（8 种情绪）
- [ ] 天气选择器
- [ ] 运动记录
- [ ] 待办事项
- [ ] 图片上传（PhotosUI + 相机）
- [ ] 音频录制

#### 2. 手帐列表和查看
- [ ] 时间线列表
- [ ] 日历视图
- [ ] 搜索功能
- [ ] 手帐详情

#### 3. AI 语音聊天（ChatGPT 风格）
- [ ] 中心圆球震动动画
- [ ] 语音输入（Speech + AVFoundation）
- [ ] 语音输出（Text-to-Speech）
- [ ] Gemini API 集成
- [ ] 上下文感知对话

#### 4. AI 基础分析
- [ ] 自动标签生成
- [ ] 周复盘文字总结
- [ ] 情绪趋势折线图（Charts 框架）

#### 5. 社区基础 UI（Mock 数据）
- [ ] 瀑布流界面
- [ ] Mock 帖子数据
- [ ] 帖子详情页
- [ ] 发布按钮（提示"开发中"）

### ❌ 暂不实现（后续版本）
- 月度复盘
- 智能排版生成
- 音频转文字（后续用 Speech 框架）
- 完整社区后端
- iCloud 同步
- Apple Intelligence

---

## 📅 10 周开发路线图

### Week 1: 项目搭建 ✨
**目标**: Xcode 项目 + SwiftData + Gemini API 配置

#### Day 1-2: 项目初始化
- [ ] 创建 Xcode 项目（iOS 17+）
- [ ] 配置 Git
- [ ] 添加 `.gitignore`

#### Day 3-4: 数据模型
- [ ] 创建 `JournalEntry` 模型
- [ ] 创建 `Attachment` 模型
- [ ] 创建 `MoodType`, `WeatherInfo`, `ExerciseRecord`

#### Day 5-7: 基础服务
- [ ] `DataService.swift` (SwiftData CRUD)
- [ ] `ImageStorageService.swift`
- [ ] `AudioStorageService.swift`
- [ ] 配置 Gemini API Key (`Constants.swift`)

**验收**:
- SwiftData 可以创建/读取/更新/删除日记
- 图片和音频可以保存到本地

---

### Week 2-3: 手帐编辑器 🎨
**目标**: 完整的手帐编辑体验

#### Week 2: 基础编辑器
- [ ] `JournalEditorView.swift`
- [ ] 文字输入 + 标题
- [ ] `MoodPickerView.swift`（8 种情绪选择）
- [ ] `WeatherPickerView.swift`
- [ ] `ExercisePickerView.swift`

#### Week 3: 多媒体
- [ ] `ImagePicker.swift` (PhotosUI)
- [ ] 相机拍照 (AVFoundation)
- [ ] `AudioRecorder.swift`
- [ ] 附件预览和删除
- [ ] 保存日记到 SwiftData

**验收**:
- 可以创建包含文字+图片+音频+心情的日记
- 数据正确保存到 SwiftData

---

### Week 4: 手帐列表和查看 📖
**目标**: 浏览和管理日记

#### Day 1-3: 列表视图
- [ ] `JournalListView.swift`（时间线）
- [ ] 日记卡片设计（Liquid Glass 风格）
- [ ] 下拉刷新

#### Day 4-5: 详情页
- [ ] `JournalDetailView.swift`
- [ ] 多模态内容渲染
- [ ] 编辑和删除功能

#### Day 6-7: 日历和搜索
- [ ] `CalendarView.swift`（简单月历）
- [ ] `SearchView.swift`（全文搜索）

**验收**:
- 可以浏览所有日记
- 点击日记查看详情
- 可以编辑和删除日记
- 搜索功能可用

---

### Week 5: UI 设计和组件 🎭
**目标**: Liquid Glass 风格统一

#### Day 1-3: 可复用组件
- [ ] `GlassCard.swift`（毛玻璃卡片）
- [ ] `LiquidBackground.swift`（动态背景）
- [ ] `TagChip.swift`（标签组件）

#### Day 4-5: TabView 结构
- [ ] 底部导航栏（手帐/AI/社区）
- [ ] 图标和配色

#### Day 6-7: 动画优化
- [ ] 页面转场动画
- [ ] 卡片悬浮效果

**验收**:
- UI 统一采用 Liquid Glass 风格
- 动画流畅（60fps）

---

### Week 6-7: AI 语音聊天 🤖
**目标**: ChatGPT 风格的语音聊天

#### Week 6: AI 服务基础
- [ ] `AIService.swift`（Gemini API 封装）
- [ ] API Key 配置
- [ ] 基础对话测试
- [ ] 流式响应（Streaming）
- [ ] 错误处理

#### Week 7: 语音聊天界面
- [ ] `VoiceChatView.swift`（中心圆球设计）
- [ ] 圆球震动动画（随音频波形）
- [ ] `AudioService.swift`（录音和播放）
- [ ] `SpeechService.swift`（语音识别）
- [ ] Text-to-Speech（AVSpeechSynthesizer）
- [ ] 长按录音交互

**验收**:
- 圆球可以随 AI 语音震动
- 可以语音输入问题
- AI 可以语音回答
- 对话有上下文记忆

---

### Week 8: AI 基础分析 📊
**目标**: 标签、周复盘、情绪趋势

#### Day 1-2: 自动标签
- [ ] Gemini 自动生成标签
- [ ] 标签保存到 `aiTags`

#### Day 3-4: 周复盘
- [ ] `WeeklyReviewView.swift`
- [ ] 读取近 7 天日记
- [ ] Gemini 生成周总结

#### Day 5-7: 情绪趋势
- [ ] `MoodTrendView.swift`
- [ ] Charts 框架集成
- [ ] 简单折线图

**验收**:
- 日记可以自动生成 3-5 个标签
- 每周可以生成文字总结
- 情绪趋势图可视化

---

### Week 9: 社区 Mock UI 🌐
**目标**: 基础社区界面（仅 UI）

#### Day 1-3: Mock 数据
- [ ] `MockCommunityService.swift`
- [ ] 本地 JSON 数据（10-20 条 Mock 帖子）

#### Day 4-5: 社区广场
- [ ] `CommunityFeedView.swift`
- [ ] 瀑布流布局
- [ ] 帖子卡片

#### Day 6-7: 帖子详情
- [ ] `PostDetailView.swift`
- [ ] 静态展示
- [ ] 点赞/评论按钮（仅 UI）
- [ ] "发布"按钮（提示开发中）

**验收**:
- 社区界面可以浏览 Mock 帖子
- 点击帖子查看详情
- 点赞/评论按钮有视觉反馈但无实际功能

---

### Week 10: 测试和优化 🚀
**目标**: MVP 发布准备

#### Day 1-3: 测试
- [ ] 基础单元测试（DataService）
- [ ] 关键流程 UI 测试
- [ ] Bug 修复

#### Day 4-5: 优化
- [ ] 性能优化（图片懒加载）
- [ ] 内存泄漏检测
- [ ] 动画优化

#### Day 6-7: 发布准备
- [ ] TestFlight 配置
- [ ] App Store 截图
- [ ] 隐私政策

**验收**:
- 应用启动时间 < 2 秒
- 无明显 Bug
- 可以打包上传 TestFlight

---

## 🛠️ 技术栈

### 核心框架
- **UI**: SwiftUI
- **数据**: SwiftData（本地存储）
- **AI**: Gemini API (`google-generative-ai-swift`)
- **图表**: Charts
- **图片**: PhotosUI, Vision (抠图)
- **音频**: AVFoundation
- **语音**: Speech (识别) + AVSpeechSynthesizer (合成)
- **认证**: LocalAuthentication (Face ID/Touch ID)

### 依赖管理
- Swift Package Manager (SPM)

---

## 📁 核心文件清单

### 优先级 1（Week 1）
1. `Models/JournalEntry.swift`
2. `Models/Attachment.swift`
3. `Services/DataService.swift`
4. `Services/ImageStorageService.swift`
5. `Utilities/Constants.swift` (Gemini API Key)

### 优先级 2（Week 2-4）
6. `Views/Journal/JournalEditorView.swift`
7. `Views/Journal/JournalListView.swift`
8. `Views/Journal/JournalDetailView.swift`
9. `Views/Journal/MoodPickerView.swift`
10. `Views/Components/ImagePicker.swift`
11. `Views/Components/AudioRecorder.swift`

### 优先级 3（Week 5）
12. `Views/Components/GlassCard.swift`
13. `Views/Components/LiquidBackground.swift`
14. `ContentView.swift` (TabView)

### 优先级 4（Week 6-8）
15. `Services/AIService.swift`
16. `Views/AI/VoiceChatView.swift`
17. `Views/AI/WeeklyReviewView.swift`
18. `Views/AI/MoodTrendView.swift`
19. `Services/AudioService.swift`
20. `Services/SpeechService.swift`

### 优先级 5（Week 9）
21. `Services/MockCommunityService.swift`
22. `Views/Community/CommunityFeedView.swift`
23. `Views/Community/PostDetailView.swift`

---

## ⚠️ 风险和注意事项

### 1. Gemini API 限流
- **风险**: 免费额度有限，可能被限流
- **方案**: 添加本地缓存，降级到离线提示

### 2. Speech 框架限制
- **风险**: 语音识别需要网络，有时长限制（1 分钟）
- **方案**: 提示用户分段录音

### 3. Vision 抠图效果
- **风险**: iOS 17 的 `VNGeneratePersonSegmentationRequest` 可能效果一般
- **方案**: 提供"抠图失败"的友好提示

### 4. 开发时间
- **风险**: 10 周时间紧张，可能延期
- **方案**: 优先完成核心功能，社区可以最后砍掉

---

## 🎯 MVP 验收标准

### 核心功能
- ✅ 可以创建包含文字+图片+心情的日记
- ✅ 可以编辑和删除日记
- ✅ 日历视图查看日记
- ✅ 搜索日记内容
- ✅ SwiftData 本地持久化

### AI 功能
- ✅ AI 语音聊天（ChatGPT 圆球风格）
- ✅ 自动生成标签
- ✅ 周复盘文字总结
- ✅ 情绪趋势折线图

### 社区功能（仅 UI）
- ✅ 社区广场展示 Mock 数据
- ✅ 帖子详情页
- ✅ 发布按钮（提示开发中）

### 设计和性能
- ✅ Liquid Glass 风格统一
- ✅ 动画流畅（60fps）
- ✅ 应用启动时间 < 2 秒
- ✅ 无明显 Bug

---

## 📞 下一步

1. **立即开始 Week 1**：创建 Xcode 项目
2. **配置 Gemini API Key**：创建 `Constants.swift`
3. **创建数据模型**：`JournalEntry` + `Attachment`

准备好了吗登登？我们可以立即开始第一周的开发！
