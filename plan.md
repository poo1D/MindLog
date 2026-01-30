# MindLog 智能手帐 App - 完整实现计划

## 项目概述

一个融合多模态手帐记录、AI 智能分析和社区分享的现代化日记应用，采用 Apple Liquid Glass 设计风格。

### 技术栈

-**最低版本**: iOS 17.0+ (iOS 17 占有率更高，Apple Intelligence 可选)

-**UI 框架**: SwiftUI

-**数据持久化**: SwiftData（本地存储）

-**认证**: LocalAuthentication (Face ID & Touch ID)

-**AI 能力**: Gemini API（MVP 阶段，后续可替换其他 AI）

-**设计风格**: Liquid Glass (毛玻璃效果、大圆角、半透明)

---

## 应用架构

### iOS 应用架构

### 底部导航结构 (TabView)

```swift

TabView {

    JournalTab()      // 手帐页

    AITab()           // AI 伴侣

    CommunityTab()    // 社区

    ProfileTab()      // 个人中心 (新增)

}

```

**详细层级**:

```

TabView

├── Tab 1: 手帐页 (Journal)

│   ├── NavigationStack

│   │   ├── 手帐列表 (Timeline)

│   │   ├── 日历视图 (Calendar)

│   │   └── 搜索视图 (Search)

│   └── Navigation Destinations

│       ├── 手帐详情 (JournalDetail)

│       └── 手帐编辑 (Editor)

│

├── Tab 2: AI 页 (AI Companion)

│   ├── NavigationStack

│   │   ├── AI 主页 (Dashboard)

│   │   ├── AI 聊天 (Chat)

│   │   ├── 周复盘 (Weekly Review)

│   │   └── 月复盘 (Monthly Review)

│   └── Navigation Destinations

│       ├── 情绪趋势 (Mood Trends)

│       └── 排版生成 (Layout Generator)

│

├── Tab 3: 社区页 (Community)

│   ├── NavigationStack

│   │   ├── 手帐广场 (Feed)

│   │   ├── 发现 (Discover)

│   │   └── 消息 (Messages)

│   └── Navigation Destinations

│       ├── 帖子详情 (Post Detail)

│       ├── 发布 (Create Post)

│       └── 用户主页 (User Profile)

│

└── Tab 4: 个人中心 (Profile)

    ├── NavigationStack

    │   ├── 个人信息

    │   ├── 设置

    │   └── 数据统计

    └── Navigation Destinations

        ├── 账户设置

        └── 隐私设置

```

### iOS 特有架构组件

**依赖注入**:

```swift

@main

struct MindLogApp: App {

var body: some Scene {

        WindowGroup {

            ContentView()

                .modelContainer(sharedModelContainer)

                .environment(\.aiService, AIService.shared)

        }

    }

    

    // SwiftData 容器（仅本地存储）

    var sharedModelContainer: ModelContainer = {

        let schema = Schema([

            JournalEntry.self,

            Attachment.self

        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        

        do {

            return try ModelContainer(for: schema, configurations: [modelConfiguration])

        } catch {

            fatalError("Could not create ModelContainer: \(error)")

        }

    }()

}

```

**状态管理**:

-`@Observable` (iOS 17+) 替代 ObservableObject

- Environment Objects 共享服务
- @StateObject/@ViewModel 管理页面状态

---

## 核心功能详解

## 1. 手帐页 - 多模态数据输入

### 1.1 数据模型 (SwiftData + iOS 最佳实践)

```swift

// Models/JournalEntry.swift

import SwiftData

import Foundation


@Model

finalclass JournalEntry {

var id: UUID

var createdAt: Date

var updatedAt: Date


// 多模态内容

var title: String

var textContent: String?

var mood: MoodType?

var weather: WeatherInfo?

var exercise: ExerciseRecord?

var todos: [TodoItem]?


// AI 生成的数据

var aiTags: [String]?

var aiSummary: String?

var aiLayout: String? // JSON 格式存储手帐排版


// iOS 17+ 关系（SwiftData 本地存储）

@Relationship(deleteRule: .cascade) var attachments: [Attachment]?


init(...) {

// 初始化

    }

}


// Models/Attachment.swift

@Model

finalclass Attachment {

var id: UUID

var type: AttachmentType

var fileURL: URL

var metadata: AttachmentMetadata?

var removedBackground: Bool? // 是否已抠图


enum AttachmentType: String, Codable {

caseimage

caseaudio

caseaudioTranscript// 音频转文字结果

casevideo

    }


// 本地文件管理（Documents 目录）

var fileURL: URL  // 统一文件路径

}


// Models/MoodType.swift

enum MoodType: String, Codable, CaseIterable {

caseamazing = "😄"

casehappy = "🙂"

caseneutral = "😐"

casesad = "😢"

caseangry = "😠"

caseanxious = "😰"

casegrateful = "🙏"

casetired = "😴"


var color: Color {

switchself {

case .amazing: return .yellow

case .happy: return .green

case .neutral: return .gray

case .sad: return .blue

case .angry: return .red

case .anxious: return .orange

case .grateful: return .pink

case .tired: return .purple

        }

    }

}


// Models/WeatherInfo.swift

struct WeatherInfo: Codable, Sendable {

var condition: WeatherCondition

var temperature: Double?

var icon: String?

var location: String?


enum WeatherCondition: String, Codable {

casesunny, cloudy, rainy, snowy, windy, foggy

    }

}


// Models/ExerciseRecord.swift

struct ExerciseRecord: Codable, Sendable {

var type: ExerciseType

var duration: TimeInterval // 分钟

var distance: Double? // 公里

var calories: Int? // 卡路里

var notes: String?


enum ExerciseType: String, Codable {

caserunning, walking, cycling, swimming, workout, yoga, other

    }

}


// Models/TodoItem.swift

struct TodoItem: Codable, Identifiable, Sendable {

var id: UUID

var title: String

var isCompleted: Bool

var priority: Priority


enum Priority: String, Codable {

caselow, medium, high

    }

}

```

**SwiftData 本地存储优化**:

- 使用 `@Relationship` 管理数据关系
- 实现 `Sendable` 协议支持并发
- 大文件（图片/音频/视频）存储在 App Documents 目录
- 数据模型仅存储文件路径 URL 引用
- 所有数据仅本地存储，无云同步（MVP 阶段）

### 1.2 手帐编辑器 (SwiftUI 最佳实践)

#### 核心视图结构

```swift

// Views/Journal/JournalEditorView.swift

struct JournalEditorView: View {

@Environment(\.modelContext) privatevar modelContext

@Stateprivatevar entry: JournalEntry

@Stateprivatevar selectedTab: EditorTab = .content


var body: some View {

        NavigationStack {

            Form {

// 标题输入

                TextField("标题", text: $entry.title)


// 内容 Tab 选择

                Picker("编辑模式", selection: $selectedTab) {

                    Text("文本").tag(EditorTab.text)

                    Text("多媒体").tag(EditorTab.multimedia)

                    Text("元数据").tag(EditorTab.metadata)

                }

                .pickerStyle(.segmented)


switch selectedTab {

case .text:

                    TextEditorSection()

case .multimedia:

                    MultimediaSection()

case .metadata:

                    MetadataSection()

                }

            }

            .navigationTitle("编辑手帐")

            .toolbar {

                ToolbarItem(placement: .cancellationAction) {

                    Button("取消") { dismiss() }

                }

                ToolbarItem(placement: .confirmationAction) {

                    Button("保存") { saveEntry() }

                }

            }

        }

    }

}

```

**功能模块实现**:

1.**文本编辑器** (`RichTextEditor.swift`)

```swift

import SwiftUI


struct RichTextEditor: View {

@Bindingvar text: String

@Stateprivatevar isBold = false

@Stateprivatevar isItalic = false


var body: some View {

        VStack {

// 格式化工具栏

            HStack {

                FormatButton(icon: "bold", isActive: $isBold)

                FormatButton(icon: "italic", isActive: $isItalic)

                Spacer()

            }


// 文本编辑器

            TextEditor(text: $text)

                .font(.body)

                .scrollContentBackground(.hidden)

        }

    }

}

```

2.**多媒体工具栏** (`MultimediaToolbar.swift`)

```swift

struct MultimediaToolbar: View {

@Stateprivatevar showingImagePicker = false

@Stateprivatevar showingCamera = false

@Stateprivatevar isRecording = false


var body: some View {

        HStack(spacing: 20) {

// 图片选择

            Button {

                showingImagePicker = true

            } label: {

                Image(systemName: "photo")

            }


// 相机

            Button {

                showingCamera = true

            } label: {

                Image(systemName: "camera")

            }


// 音频录制

            Button {

                isRecording.toggle()

            } label: {

                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle")

            }


            Spacer()

        }

        .sheet(isPresented: $showingImagePicker) {

            ImagePicker(selectedImage: $selectedImage)

        }

    }

}

```

3.**元数据选择器** (`MetadataPickerView.swift`)

```swift

struct MetadataPickerView: View {

@Bindingvar mood: MoodType?

@Bindingvar weather: WeatherInfo?

@Bindingvar exercise: ExerciseRecord?


var body: some View {

        Section("情绪") {

            MoodPicker(selectedMood: $mood)

        }


        Section("天气") {

            WeatherPicker(selectedWeather: $weather)

        }


        Section("运动") {

            ExercisePicker(exercise: $exercise)

        }

    }

}

```

#### iOS 原生功能集成

**1. PhotosUI 框架** (iOS 16+)

```swift

import PhotosUI


struct ImagePicker: UIViewControllerRepresentable {

@Bindingvar selectedImage: UIImage?

@Environment(\.dismiss) privatevar dismiss


func makeUIViewController(context: Context) -> PHPickerViewController {

var config = PHPickerConfiguration()

        config.filter = .images

        config.selectionLimit = 0// 多选


let picker = PHPickerViewController(configuration: config)

        picker.delegate = context.coordinator

return picker

    }

}

```

**2. AVFoundation 相机**

```swift

import AVFoundation


struct CameraView: View {

@StateObjectprivatevar camera = CameraManager()


var body: some View {

        CameraPreview(camera: camera)

            .onAppear {

                camera.checkPermission()

            }

    }

}

```

**3. AVFoundation 音频录制**

```swift

import AVFoundation


class AudioRecorder: NSObject, ObservableObject {

var audioRecorder: AVAudioRecorder?

var recordingURL: URL?


func startRecording() throws {

let url = FileManager.default.temporaryDirectory

            .appendingPathComponent(UUID().uuidString)

            .appendingPathExtension("m4a")


let settings = [

            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),

            AVSampleRateKey: 44100.0,

            AVNumberOfChannelsKey: 1

        ]


        audioRecorder = try AVAudioRecorder(url: url, settings: settings)

        audioRecorder?.record()

    }

}

```

#### 抠图功能 (Vision 框架)

**文件**: `Services/ImageBackgroundRemovalService.swift`

```swift

import Vision

import UIKit


@MainActor

class ImageBackgroundRemovalService: ObservableObject {

// iOS 17+ VNGeneratePersonSegmentationRequest

func removeBackground(from image: UIImage) asyncthrows -> UIImage {

guardlet cgImage = image.cgImage else {

throw RemovalError.invalidImage

        }


let request = VNGeneratePersonSegmentationRequest()

        request.qualityLevel = .balanced // .balanced, .fast, .accurate


let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

try handler.perform([request])


guardlet observation = request.results?.first else {

throw RemovalError.noObservation

        }


// 生成 mask

let mask = try observation.generateMask()

returntry applyMask(to: image, mask: mask)

    }


privatefunc applyMask(to image: UIImage, mask: VNPixelBufferObservation) throws -> UIImage {

// 实现背景移除逻辑

// 1. 创建 CGImage 从 mask

// 2. 应用 mask 到原图

// 3. 返回透明背景的 UIImage

    }

}


enum RemovalError: Error {

caseinvalidImage

casenoObservation

}

```

**集成点**:

```swift

struct AttachmentCell: View {

@Stateprivatevar isProcessing = false

@Stateprivatevar showingRemoveBackgroundPrompt = false


var body: some View {

        VStack {

if isProcessing {

                ProgressView("处理中...")

            } else {

                Image(uiImage: attachment.image)

            }

        }

        .confirmationDialog("是否移除背景？", isPresented: $showingRemoveBackgroundPrompt) {

            Button("移除背景") {

                Task {

await removeBackground()

                }

            }

        }

    }

}

```

### 1.3 日历视图

**文件**: `Views/Journal/CalendarView.swift`

**功能**:

- 月历/周历/日历切换
- 显示每日手帐数量（圆点指示器）
- 点击日期显示当天所有手帐
- 支持拖拽选择日期范围
- 显示情绪天气图（情绪色彩映射）

### 1.4 搜索功能

**文件**: `Views/Journal/SearchView.swift`

**搜索维度**:

- 全文搜索（文字内容）
- 按心情筛选
- 按日期范围筛选
- 按标签筛选
- 按附件类型筛选（有图片、有音频等）
- 智能搜索（自然语言查询："上周开心的日子"）

---

## 2. AI 页 - 智能伴侣

### 2.1 AI 服务架构 (Gemini API + Apple Intelligence)

```swift

// Services/AIService.swift

import Foundation

@preconcurrencyimport GoogleGenerativeAI // Gemini API


@Observable

@MainActor

class AIService: NSObject {

privatelet geminiModel: GenerativeModel?

privatelet apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"]


// 单例模式

staticlet shared = AIService()


overrideprivateinit() {

// 初始化 Gemini

self.geminiModel = GenerativeModel(

            name: "gemini-pro",

            apiKey: apiKey ?? ""

        )

    }


// MARK: - 核心功能


/// 全量读取日记内容 (SwiftData 查询)

func loadAllEntries(from context: ModelContext) -> [JournalEntry] {

let descriptor = FetchDescriptor<JournalEntry>(

            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]

        )

return (try? context.fetch(descriptor)) ?? []

    }


/// 写日记提醒

func generateReminderPrompt() asyncthrows -> String {

let prompt = """

        基于用户的日记习惯，生成一个温馨的写日记提醒。

        要求：简短、亲切、不超过50字。

"""


let response = tryawait geminiModel?.generateContent(prompt)

return response?.text ?? "今天过得怎么样？记录一下吧！"

    }


/// 自动标签和分类

func generateTagsAndCategory(for entry: JournalEntry) asyncthrows -> (tags: [String], category: String) {

let prompt = """

        分析以下日记内容，生成3-5个标签和分类：


        标题：\(entry.title)

        内容：\(entry.textContent ?? "")


        返回 JSON 格式：{"tags": ["标签1", "标签2"], "category": "分类"}

"""


let response = tryawait geminiModel?.generateContent(prompt)

guardlet jsonText = response?.text else {

throw AIServiceError.invalidResponse

        }


let data = jsonText.data(using: .utf8)!

returntry JSONDecoder().decode(TagsResponse.self, from: data)

    }


/// 周复盘

func generateWeeklyReview(entries: [JournalEntry]) asyncthrows -> WeeklyReview {

let entriesText = entries.map { entry in

"""

            日期：\(entry.createdAt)

            情绪：\(entry.mood?.rawValue ?? "无")

            内容：\(entry.textContent ?? "")

"""

        }.joined(separator: "\n---\n")


let prompt = """

        分析以下一周的日记，生成周复盘报告：


        \(entriesText)


        包含：

        1. 情绪总结

        2. 关键事件

        3. 高光时刻

        4. 下周建议

"""


let response = tryawait geminiModel?.generateContent(prompt)

return WeeklyReview(

            content: response?.text ?? "",

            generatedAt: Date()

        )

    }


/// 月复盘

func generateMonthlyReview(entries: [JournalEntry]) asyncthrows -> MonthlyReview {

// 类似周复盘，但分析更长周期

let prompt = """

        分析以下一个月的日记，生成月度总结：


        \(entries.map { $0.textContent ?? "" }.joined(separator: "\n"))

"""


let response = tryawait geminiModel?.generateContent(prompt)

return MonthlyReview(

            content: response?.text ?? "",

            generatedAt: Date()

        )

    }


/// 生成手帐排版

func generateLayout(for entry: JournalEntry) asyncthrows -> JournalLayout {

let contentType = analyzeContentType(entry)


let prompt = """

        为以下内容生成排版建议：


        内容类型：\(contentType)

        图片数量：\(entry.attachments?.filter { $0.type == .image }.count ?? 0)

        音频数量：\(entry.attachments?.filter { $0.type == .audio }.count ?? 0)

        文字长度：\(entry.textContent?.count ?? 0)


        返回布局类型：

        - waterfall: 瀑布流

        - magazine: 杂志风格

        - timeline: 时间线

        - card: 卡片式

"""


let response = tryawait geminiModel?.generateContent(prompt)

let layoutType = parseLayoutType(response?.text ?? "card")


return JournalLayout(

            type: layoutType,

            suggestedByAI: true

        )

    }


/// 长期情绪趋势分析

func analyzeMoodTrend(entries: [JournalEntry]) asyncthrows -> MoodTrendAnalysis {

let moodData = entries.compactMap { entry -> (Date, MoodType)? in

guardlet mood = entry.mood else { returnnil }

return (entry.createdAt, mood)

        }


// 简单统计分析

let moodCounts = Dictionary(grouping: moodData, by: { $0.1 })

            .mapValues { $0.count }


let dominantMood = moodCounts.max { $0.value < $1.value }?.key


return MoodTrendAnalysis(

            dominantMood: dominantMood,

            moodDistribution: moodCounts,

            trend: "情绪整体\(dominantMood == .happy ? "积极" : "平稳")"

        )

    }


/// AI 陪伴对话

func chat(message: String, context: [JournalEntry]) asyncthrows -> String {

let contextText = context.prefix(5).map { entry in

"\(entry.createdAt): \(entry.textContent ?? "")"

        }.joined(separator: "\n")


let prompt = """

        你是一个温暖、善解人意的日记助手。根据用户的日记历史，回答他的问题。


        最近日记：

        \(contextText)


        用户问题：\(message)

"""


let response = tryawait geminiModel?.generateContent(prompt)

return response?.text ?? "我理解你的感受，能多说一点吗？"

    }


// MARK: - 辅助方法


privatefunc analyzeContentType(_ entry: JournalEntry) -> String {

var types: [String] = []

if entry.textContent != nil { types.append("文字") }

if entry.attachments?.contains(where: { $0.type == .image }) == true { types.append("图片") }

if entry.attachments?.contains(where: { $0.type == .audio }) == true { types.append("音频") }

return types.joined(separator: "+")

    }


privatefunc parseLayoutType(_ text: String) -> LayoutType {

let lowercased = text.lowercased()

if lowercased.contains("waterfall") { return .waterfall }

if lowercased.contains("magazine") { return .magazine }

if lowercased.contains("timeline") { return .timeline }

return .card

    }

}


// MARK: - 数据模型


struct TagsResponse: Codable {

let tags: [String]

let category: String

}


struct WeeklyReview: Codable {

let content: String

let generatedAt: Date

}


struct MonthlyReview: Codable {

let content: String

let generatedAt: Date

}


struct JournalLayout: Codable {

let type: LayoutType

let suggestedByAI: Bool

}


enum LayoutType: String, Codable {

casewaterfall, magazine, timeline, card

}


struct MoodTrendAnalysis {

let dominantMood: MoodType?

let moodDistribution: [MoodType: Int]

let trend: String

}


enum AIServiceError: Error {

caseinvalidResponse

casenoAPIKey

casenetworkError

}

```

### 2.2 AI 页面结构

#### 主界面

**文件**: `Views/AI/AIHomeView.swift`

**功能区**:

1.**快捷入口卡片**

- 今日写日记提醒
- 本周情绪概览
- 待完成的复盘

2.**AI 语音聊天区域**（ChatGPT 语音模式风格）

- 中间圆球随语音震动
- 支持语音输入和输出
- 上下文感知（基于日记内容）
- 极简交互界面

3.**智能分析入口**

- 周复盘报告
- 月度总结
- 情绪趋势图

#### 周复盘界面

**文件**: `Views/AI/WeeklyReviewView.swift`

**生成内容**:

- 本周情绪曲线图
- 关键事件总结
- 高光时刻
- 待办完成率
- AI 给出的建议
- 下周目标建议

#### 月度复盘界面

**文件**: `Views/AI/MonthlyReviewView.swift`

**生成内容**:

- 月度词云
- 情绪分布饼图
- 写作连续天数
- 最常使用的标签
- 月度主题提炼
- 月度成就回顾
- 月度反思

#### 情绪趋势分析

**文件**: `Views/AI/MoodTrendView.swift`

**可视化**:

- 长期情绪曲线图（使用 Charts 框架）
- 情绪日历热力图
- 情绪相关性分析（天气 vs 情绪、运动 vs 情绪）
- 情绪预测和建议

#### 智能排版生成

**文件**: `Views/AI/LayoutGeneratorView.swift`

**功能**:

- 用户选择"AI 排版"
- AI 分析内容类型（文字、图片、音频等）
- 生成多种布局方案
- 用户预览并选择
- 一键应用到当前手帐

**布局示例**:

- 瀑布流布局
- 杂志风格布局
- 时间线布局
- 卡片式布局

#### AI 语音聊天（ChatGPT 风格）

**文件**: `Views/AI/VoiceChatView.swift`

**设计**:

- **中心圆球**: 类似 ChatGPT 语音模式，圆球随 AI 语音输出震动
- **动画效果**: `.scaleEffect` + `.opacity` 随音频波形变化
- **极简 UI**: 无对话气泡，仅圆球 + 文字转录
- **交互方式**: 
  - 长按圆球开始语音输入
  - AI 响应时圆球震动
  - 显示实时转录文字（可选）

**技术实现**:

```swift

struct VoiceChatView: View {

    @State private var isListening = false

    @State private var isSpeaking = false

    @State private var audioLevel: CGFloat = 0.0

    

    var body: some View {

        ZStack {

            // 背景

            Color.black.ignoresSafeArea()

            

            VStack {

                Spacer()

                

                // 中心圆球（随语音震动）

                Circle()

                    .fill(

                        RadialGradient(

                            colors: [.blue, .purple],

                            center: .center,

                            startRadius: 50,

                            endRadius: 150

                        )

                    )

                    .frame(width: 200, height: 200)

                    .scaleEffect(1.0 + audioLevel * 0.3)  // 随音量震动

                    .opacity(0.8 + audioLevel * 0.2)

                    .blur(radius: audioLevel * 10)

                    .animation(.easeInOut(duration: 0.1), value: audioLevel)

                

                Spacer()

                

                // 状态文字

                Text(isSpeaking ? "AI 正在回答..." : "长按开始说话")

                    .foregroundColor(.white)

                    .padding(.bottom, 100)

            }

        }

        .onAppear {

            startAudioLevelMonitoring()

        }

    }

}

```

**核心功能**:

- 记忆功能（基于历史日记）
- 情感支持和写作引导
- 语音输入/输出
- 实时音频波形动画

---

## 3. 社区页 - 手帐分享

### 3.1 社区功能（MVP 阶段仅 UI）

> **注意**: MVP 阶段社区功能仅包含基础 UI 界面，无后端数据交互。
> 所有数据为本地 Mock 数据，仅用于演示效果。
> 实际后端集成将在后续版本实现。

### 3.2 社区数据模型（Mock 数据）

```swift

// Models/CommunityPost.swift

@Model

finalclass CommunityPost {

var id: UUID

var authorID: String

var authorName: String

var authorAvatar: URL?


var entryID: UUID // 关联的日记 ID（可选，允许匿名分享）

var title: String

var content: String // 精简后的展示内容

var images: [URL]

var layout: String? // 排版信息


var tags: [String]

var isPublic: Bool


var likes: Int

var comments: [Comment]

var createdAt: Date


var visibility: PostVisibility


enum PostVisibility {

casepublic

casefollowers

caseprivate

    }

}


// Models/Comment.swift

struct Comment: Identifiable, Codable {

var id: UUID

var authorID: String

var authorName: String

var content: String

var createdAt: Date

var likes: Int

}

```

### 3.3 社区页面结构（仅 UI）

#### 手帐广场

**文件**: `Views/Community/CommunityFeedView.swift`

**布局**:

- 瀑布流展示分享的手帐
- 支持双列/单列切换
- 顶部标签筛选（推荐、最新、关注）

**每个手帐卡片显示**:

- 作者头像和昵称
- 手帐封面图/缩略图
- 标题和部分内容预览
- 标签
- 点赞数和评论数
- 收藏按钮

#### 手帐详情

**文件**: `Views/Community/PostDetailView.swift`

**功能**:

- 完整手帐内容展示
- 应用 AI 生成的排版
- 图片轮播
- 点赞/评论/分享
- 关注作者
- 举报功能
- 相似推荐

#### 发布界面

**文件**: `Views/Community/CreatePostView.swift`

**流程**:

1. 选择要分享的日记
2. 预览分享内容
3. 选择可见性（公开/粉丝/私密）
4. 添加描述和标签
5. 选择是否匿名
6. 发布到社区

#### 个人中心

**文件**: `Views/Community/UserProfileView.swift`

**展示**:

- 用户头像和简介
- 关注/粉丝数
- 我的手帐（已分享）
- 我的手帐（私密）
- 收藏的内容
- 获得的点赞数

---

## iOS 文件结构 (Xcode 项目最佳实践)

```

MindLog/

├── MindLog/

│   ├── MindLogApp.swift                # App 入口 (@main)

│   │

│   ├── Models/                         # SwiftData 模型

│   │   ├── JournalEntry.swift

│   │   ├── Attachment.swift

│   │   ├── MoodType.swift

│   │   ├── WeatherInfo.swift

│   │   ├── ExerciseRecord.swift

│   │   ├── TodoItem.swift

│   │   ├── CommunityPost.swift

│   │   └── AppSettings.swift

│   │

│   ├── ViewModels/                     # @Observable 视图模型

│   │   ├── JournalViewModel.swift

│   │   ├── JournalEditorViewModel.swift

│   │   ├── CalendarViewModel.swift

│   │   ├── SearchViewModel.swift

│   │   ├── AIChatViewModel.swift

│   │   ├── ReviewViewModel.swift

│   │   ├── FeedViewModel.swift

│   │   └── ProfileViewModel.swift

│   │

│   ├── Views/                          # SwiftUI 视图

│   │   ├── Journal/                   # 手帐模块

│   │   │   ├── JournalListView.swift

│   │   │   ├── JournalDetailView.swift

│   │   │   ├── JournalEditorView.swift

│   │   │   ├── MoodPickerView.swift

│   │   │   ├── WeatherPickerView.swift

│   │   │   ├── ExercisePickerView.swift

│   │   │   ├── TodoListView.swift

│   │   │   ├── CalendarView.swift

│   │   │   └── SearchView.swift

│   │   │

│   │   ├── AI/                        # AI 模块

│   │   │   ├── AIHomeView.swift

│   │   │   ├── AIChatView.swift

│   │   │   ├── WeeklyReviewView.swift

│   │   │   ├── MonthlyReviewView.swift

│   │   │   ├── MoodTrendView.swift

│   │   │   └── LayoutGeneratorView.swift

│   │   │

│   │   ├── Community/                 # 社区模块

│   │   │   ├── CommunityFeedView.swift

│   │   │   ├── PostDetailView.swift

│   │   │   ├── CreatePostView.swift

│   │   │   ├── UserProfileView.swift

│   │   │   └── CommentsView.swift

│   │   │

│   │   ├── Profile/                   # 个人中心

│   │   │   ├── ProfileView.swift

│   │   │   ├── SettingsView.swift

│   │   │   └── StatisticsView.swift

│   │   │

│   │   ├── Components/                # 可复用组件

│   │   │   ├── GlassCard.swift

│   │   │   ├── LiquidBackground.swift

│   │   │   ├── RichTextEditor.swift

│   │   │   ├── ImagePicker.swift

│   │   │   ├── AudioRecorder.swift

│   │   │   ├── VideoRecorder.swift

│   │   │   ├── TagChip.swift

│   │   │   └── WaterfallGrid.swift

│   │   │

│   │   └── Auth/                      # 认证相关

│   │       ├── LockScreenView.swift

│   │       └── OnboardingView.swift

│   │

│   ├── Services/                       # 业务逻辑服务

│   │   ├── DataService.swift          # SwiftData CRUD

│   │   ├── BiometricAuthService.swift # Face ID / Touch ID

│   │   ├── ImageStorageService.swift  # 图片存储管理

│   │   ├── AudioStorageService.swift  # 音频存储管理

│   │   ├── BackgroundRemovalService.swift

│   │   ├── AudioTranscriptionService.swift

│   │   ├── AIService.swift           # Gemini API

│   │   ├── MockCommunityService.swift # Mock 社区数据（MVP）

│   │   └── NotificationService.swift # 推送通知

│   │

│   ├── Utilities/                      # 工具类

│   │   ├── Extensions/

│   │   │   ├── View+Extensions.swift

│   │   │   ├── Color+Extensions.swift

│   │   │   ├── Date+Extensions.swift

│   │   │   └── URLRequest+Extensions.swift

│   │   ├── Constants.swift

│   │   ├── Persistence.swift          # SwiftData Container

│   │   ├── NetworkManager.swift

│   │   └── NetworkError.swift

│   │

│   ├── Resources/                      # 资源文件

│   │   ├── Assets.xcassets/

│   │   ├── Localizable.strings        # 国际化

│   │   ├── Info.plist

│   │   └── Gemini-Info.plist          # Gemini API 配置

│   │

│   └── Preview Content/                # SwiftUI Preview

│       └── Preview Assets.xcassets

│

├── MindLogTests/                       # 单元测试

│   ├── ModelTests/

│   ├── ServiceTests/

│   └── UtilityTests/

│

├── MindLogUITests/                     # UI 测试

│   ├── JournalFlowUITests.swift

│   └── AIChatUITests.swift

│

└── MindLog.xcodeproj/                  # Xcode 项目配置

```

**Xcode Groups 组织建议**:

1. 按功能模块分组 (而非文件类型)
2. 使用 Scope 头文件 (`.h`) 导出公共接口
3. 为每个模块创建单独的 Target (可选，便于模块化)
4. 使用 Swift Package Manager 管理第三方依赖

---

## iOS 实施路线图 (按功能模块划分)

## MVP 开发路线图（8-10 周）

> **MVP 目标**: 本地日记编辑 + AI 智能分析 + 基础社区 UI
> **不包含**: CloudKit 同步、完整社区后端、Apple Intelligence

---

### Phase 1: 项目基础搭建 (第 1 周)

**目标**: 创建 Xcode 项目、配置依赖、搭建基础架构

#### Sprint 1.1: 项目初始化

- [ ] 创建新的 Xcode 项目 (iOS App, iOS 17+)
- [ ] 配置 SwiftData（仅本地存储）
- [ ] 集成 Gemini API SDK (SPM: `google-generative-ai-swift`)
- [ ] 配置 Git 版本控制
- [ ] 设置项目文件结构
- [ ] 配置 App Icons 和 Launch Screen
- [ ] 添加 Gemini API Key 到环境变量

**关键文件**:

```

MindLogApp.swift

Persistence.swift (SwiftData Container)

Constants.swift (存储 Gemini API Key)

```

#### Sprint 1.2: 核心数据模型

- [ ] 创建 SwiftData 模型（JournalEntry, Attachment 等）
- [ ] 实现 @Observable ViewModels
- [ ] 实现基础 CRUD 服务（DataService）
- [ ] 实现文件存储服务（ImageStorageService, AudioStorageService）
- [ ] 编写单元测试 (ModelTests)

**关键文件**:

```

Models/JournalEntry.swift

Models/Attachment.swift

Services/DataService.swift

Services/ImageStorageService.swift

Services/AudioStorageService.swift

```

#### Sprint 1.3: 导航框架

- [ ] 实现 TabView 结构
- [ ] 创建 NavigationStack
- [ ] 实现 GlassCard 组件
- [ ] LiquidBackground 动态效果
- [ ] 配置主题和颜色系统

**关键文件**:

```

ContentView.swift

Views/Components/GlassCard.swift

Views/Components/LiquidBackground.swift

Utilities/Constants.swift

```

---

### Phase 2: 手帐核心功能 (第 3-5 周)

**目标**: 实现完整的手帐编辑和查看体验

#### Sprint 2.1: 手帐编辑器 (2 周)

- [ ] 文本输入和富文本支持
- [ ] MoodPicker (心情选择器)
- [ ] WeatherPicker (天气选择器)
- [ ] ExercisePicker (运动记录)
- [ ] TodoListView (待办事项)
- [ ] 图片选择和预览 (PhotosUI)
- [ ] 相机拍照 (AVFoundation)
- [ ] 音频录制和播放 (AVFoundation)
- [ ] 视频录制
- [ ] 多附件管理

**关键文件**:

```

Views/Journal/JournalEditorView.swift

Views/Journal/MoodPickerView.swift

Views/Journal/WeatherPickerView.swift

Views/Components/ImagePicker.swift

Views/Components/AudioRecorder.swift

```

#### Sprint 2.2: 手帐列表和详情 (1 周)

- [ ] 时间线列表 (Timeline)
- [ ] 手帐详情展示
- [ ] 多模态内容渲染
- [ ] 编辑和删除功能
- [ ] 下拉刷新
- [ ] 分页加载

**关键文件**:

```

Views/Journal/JournalListView.swift

Views/Journal/JournalDetailView.swift

ViewModels/JournalViewModel.swift

```

---

### Phase 3: 高级手帐功能 (第 6-7 周)

**目标**: 完善手帐体验,增加日历和搜索

#### Sprint 3.1: 日历视图

- [ ] UICalendarView 集成 (SwiftUI)
- [ ] 月历/周历切换
- [ ] 日期标记 (手帐数量指示)
- [ ] 日期筛选
- [ ] 情绪热力图

**关键文件**:

```

Views/Journal/CalendarView.swift

ViewModels/CalendarViewModel.swift

```

#### Sprint 3.2: 搜索功能

- [ ] 全文搜索 (SwiftData @Predicate)
- [ ] 多维度筛选 (心情、日期、标签)
- [ ] 智能搜索 (自然语言查询)
- [ ] 搜索历史
- [ ] 搜索结果高亮

**关键文件**:

```

Views/Journal/SearchView.swift

ViewModels/SearchViewModel.swift

```

#### Sprint 3.3: 抠图功能

- [ ] Vision 框架集成 (VNGeneratePersonSegmentationRequest)
- [ ] 背景移除实现
- [ ] 批量抠图
- [ ] 抠图预览和保存
- [ ] 错误处理

**关键文件**:

```

Services/BackgroundRemovalService.swift

```

---

### Phase 4: AI 智能功能 (第 6-8 周)

**目标**: 集成 Gemini API,实现语音聊天和基础分析（MVP）

#### Sprint 4.1: AI 服务基础

- [ ] Gemini API 配置
- [ ] API Key 管理 (Environment Variables)
- [ ] 网络请求封装
- [ ] 错误处理和重试
- [ ] 测试 Mock 数据

**关键文件**:

```

Services/AIService.swift

Utilities/NetworkManager.swift

```

#### Sprint 4.2: AI 语音聊天（ChatGPT 风格，2 周）

- [ ] 语音聊天界面（中心圆球设计）
- [ ] 圆球震动动画（随音频波形）
- [ ] 语音输入（AVFoundation + Speech）
- [ ] 语音输出（AVFoundation Text-to-Speech）
- [ ] 上下文感知对话（基于历史日记）
- [ ] Gemini API 流式响应
- [ ] 极简 UI 交互

**关键文件**:

```

Views/AI/VoiceChatView.swift           # 语音聊天主界面

Views/AI/AIHomeView.swift

ViewModels/VoiceChatViewModel.swift    # 语音聊天逻辑

Services/AudioService.swift            # 音频录制和播放

Services/SpeechService.swift           # 语音识别和合成

Services/NotificationService.swift

```

#### Sprint 4.3: 智能分析（MVP 简化版，1 周）

- [ ] 自动标签生成（Gemini API）
- [ ] 周复盘生成（仅文字总结）
- [ ] Charts 框架集成
- [ ] 情绪趋势图（简单折线图）
- ❌ 月复盘（后续版本）
- ❌ 复杂数据可视化（后续版本）

**关键文件**:

```

Views/AI/WeeklyReviewView.swift

Views/AI/MonthlyReviewView.swift

Views/AI/MoodTrendView.swift

ViewModels/ReviewViewModel.swift

```

#### Sprint 4.4: ❌ 智能排版（后续版本）

暂不实现，留待后续版本开发。

**关键文件**:

```

Views/AI/LayoutGeneratorView.swift

ViewModels/LayoutGeneratorViewModel.swift

```

---

### Phase 5: ❌ 音频转文字（后续版本）

暂不实现，留待后续版本开发。

---

### Phase 5 (MVP): 社区基础 UI (第 9 周)

**目标**: 实现社区界面（仅 UI，无后端）

#### Sprint 5.1: 社区 Mock 界面

- [ ] 瀑布流布局组件
- [ ] Mock 社区数据（本地 JSON）
- [ ] 手帐广场界面（展示 Mock 数据）
- [ ] 帖子详情页（静态展示）
- [ ] 发布按钮（点击提示"功能开发中"）
- [ ] 点赞/评论按钮（仅 UI，无实际功能）

**关键文件**:

```

Views/Community/CommunityFeedView.swift

Views/Community/PostDetailView.swift

Services/MockCommunityService.swift     # Mock 数据服务

```

---

### Phase 6 (MVP): 测试和优化 (第 10 周)

**目标**: 性能优化、测试、MVP 发布准备

#### Sprint 6.1: 测试和优化

- [ ] 基础单元测试
- [ ] 关键流程 UI 测试
- [ ] 性能优化（图片懒加载）
- [ ] Bug 修复
- [ ] 代码重构

#### Sprint 6.2: MVP 发布准备

- [ ] TestFlight 内测
- [ ] 隐私政策
- [ ] App Store 截图和描述
- [ ] 最终调试

---

---

## MVP 后续功能规划

### v1.1 (MVP 后 4-6 周)

- [ ] 音频转文字（Speech 框架）
- [ ] 智能排版生成
- [ ] 月度复盘
- [ ] 完整社区后端集成

### v1.2 (后续规划)

- [ ] iCloud 同步（可选）
- [ ] Apple Watch 伴侣应用
- [ ] 桌面小组件
- [ ] 主题商城

---

## iOS 开发最佳实践

### 1. SwiftUI + SwiftData 开发规范

**Model 设计**:

```swift

@Model

finalclass JournalEntry {

var id: UUID

var title: String


@Relationship(deleteRule: .cascade) var attachments: [Attachment]


init(...) { }

}

```

**ViewModel 模式**:

```swift

@Observable

@MainActor

class JournalViewModel {

privatelet dataService: DataService

var entries: [JournalEntry] = []


func loadEntries() {

        entries = dataService.fetchEntries()

    }

}

```

### 2. 并发和异步编程

```swift

// 使用 async/await

Task {

do {

let review = tryawait AIService.shared.generateWeeklyReview(entries: entries)

await MainActor.run {

self.review = review

        }

    } catch {

// 错误处理

    }

}

```

### 3. 错误处理

```swift

enum MindLogError: Error, LocalizedError {

casenetworkError

casedataCorruption

caseunauthorized


var errorDescription: String? {

switchself {

case .networkError: return"网络连接失败"

case .dataCorruption: return"数据损坏"

case .unauthorized: return"未授权"

        }

    }

}

```

### 4. 权限配置 (Info.plist)

```xml

<key>NSPhotoLibraryUsageDescription</key>

<string>需要访问相册以添加照片到手帐</string>


<key>NSCameraUsageDescription</key>

<string>需要使用相机拍摄照片</string>


<key>NSMicrophoneUsageDescription</key>

<string>需要录制语音日记</string>


<key>NSSpeechRecognitionUsageDescription</key>

<string>需要语音转文字功能</string>


<key>NSFaceIDUsageDescription</key>

<string>使用 Face ID 保护你的日记隐私</string>

```

### 5. 依赖管理 (SPM)

```swift

// Package.swift

dependencies: [

    .package(url: "https://github.com/google/generative-ai-swift", from: "1.0.0")

]

```

---

## iOS 技术要点和框架集成

### 1. SwiftData 多模态数据存储

**文件存储策略**:

```swift

// 大文件（图片、音频、视频）存储

// 1. 元数据存 SwiftData

// 2. 文件存 App Sandbox 或 iCloud

// 3. 使用 fileURL 引用


class ImageStorageService {

let fileManager = FileManager.default

let documentsDirectory: URL


init() {

self.documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

    }


func saveImage(_ image: UIImage) throws -> URL {

let fileName = UUID().uuidString + ".png"

let fileURL = documentsDirectory.appendingPathComponent("images/\(fileName)")


// 创建目录

try fileManager.createDirectory(at: fileURL.deletingLastPathComponent(),

                                       withIntermediateDirectories: true)


// 保存文件

try image.pngData()?.write(to: fileURL)

return fileURL

    }

}

```



### 2. Gemini API 集成 (主要 AI 方案)

```swift

import GoogleGenerativeAI


class AIService {

let model: GenerativeModel


init(apiKey: String) {

self.model = GenerativeModel(

            name: "gemini-pro",

            apiKey: apiKey

        )

    }


func generateResponse(prompt: String) asyncthrows -> String {

let response = tryawait model.generateContent(prompt)

return response.text ?? ""

    }


// 流式响应

func streamResponse(prompt: String) asyncthrows -> AsyncThrowingStream<String, Error> {

let contentStream = model.generateContentStream(prompt)

return contentStream.map { $0.text ?? "" }

    }

}

```

### 3. Vision 框架抠图

```swift

import Vision


class BackgroundRemovalService {

func removeBackground(from image: UIImage) asyncthrows -> UIImage {

guardlet cgImage = image.cgImage else {

throw RemovalError.invalidImage

        }


// iOS 17+ API

let request = VNGeneratePersonSegmentationRequest()

        request.qualityLevel = .balanced


let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

try handler.perform([request])


guardlet observation = request.results?.first else {

throw RemovalError.noObservation

        }


// 生成 mask

let mask = try observation.generateMask()

returntry applyMask(to: image, mask: mask)

    }

}

```

### 4. Speech 框架转写

```swift

import Speech


class AudioTranscriptionService: NSObject, ObservableObject {

privatevar recognizer: SFSpeechRecognizer?

privatevar recognitionTask: SFSpeechRecognitionTask?


func requestAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {

await withCheckedContinuation { continuation in

            SFSpeechRecognizer.requestAuthorization { status in

                continuation.resume(returning: status)

            }

        }

    }


func transcribe(url: URL) asyncthrows -> String {

let request = SFSpeechURLRecognitionRequest(url: url)

        request.shouldReportPartialResults = false


returntryawait withCheckedThrowingContinuation { continuation in

            recognizer?.recognitionTask(with: request) { result, error in

iflet error = error {

                    continuation.resume(throwing: error)

return

                }


iflet result = result, result.isFinal {

                    continuation.resume(returning: result.bestTranscription.formattedString)

                }

            }

        }

    }

}

```

### 5. Charts 框架数据可视化

```swift

import Charts


struct MoodTrendView: View {

let moodData: [(date: Date, moodScore: Int)]


var body: some View {

        Chart(moodData) { item in

            LineMark(

                x: .value("日期", item.date),

                y: .value("情绪", item.moodScore)

            )

            .interpolationMethod(.catmullRom)

            .foregroundStyle(.blue)


            AreaMark(

                x: .value("日期", item.date),

                y: .value("情绪", item.moodScore)

            )

            .foregroundStyle(.blue.opacity(0.1))

        }

        .frame(height: 200)

        .chartYAxis {

            AxisMarks(position: .leading)

        }

    }

}

```

### 6. LocalAuthentication 生物识别

```swift

import LocalAuthentication


class BiometricAuthService: NSObject {

let context = LAContext()


func authenticate() asyncthrows {

var error: NSError?

let reason = "使用 Face ID 或 Touch ID 解锁你的日记"


guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {

throw AuthError.biometricNotAvailable

        }


tryawait context.evaluatePolicy(

            .deviceOwnerAuthenticationWithBiometrics,

            localizedReason: reason

        )

    }

}

```

### 7. UserNotifications 推送通知

```swift

import UserNotifications


class NotificationService {

func scheduleReminder() asyncthrows {

let content = UNMutableNotificationContent()

        content.title = "日记提醒"

        content.body = "今天过得怎么样？记录一下吧！"

        content.sound = .default


let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)

let request = UNNotificationRequest(identifier: UUID().uuidString,

                                           content: content,

                                           trigger: trigger)


tryawait UNUserNotificationCenter.current().add(request)

    }


func requestAuthorization() asyncthrows {

let center = UNUserNotificationCenter.current()

tryawait center.requestAuthorization(options: [.alert, .sound, .badge])

    }

}

```

### 8. PhotosUI 相册选择

```swift

import PhotosUI


struct ImagePicker: UIViewControllerRepresentable {

@Bindingvar selectedImage: UIImage?

@Environment(\.dismiss) privatevar dismiss


func makeUIViewController(context: Context) -> PHPickerViewController {

var config = PHPickerConfiguration(photoLibrary: .shared())

        config.filter = .images

        config.selectionLimit = 0// 多选


let picker = PHPickerViewController(configuration: config)

        picker.delegate = context.coordinator

return picker

    }


func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}


func makeCoordinator() -> Coordinator {

        Coordinator(self)

    }


class Coordinator: PHPickerViewControllerDelegate {

let parent: ImagePicker


init(_ parent: ImagePicker) {

self.parent = parent

        }


func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

            parent.dismiss()


guardlet provider = results.first?.itemProvider else { return }


if provider.canLoadObject(ofClass: UIImage.self) {

                provider.loadObject(ofClass: UIImage.self) { image, _ in

                    DispatchQueue.main.async {

self.parent.selectedImage = image as? UIImage

                    }

                }

            }

        }

    }

}

```

### 9. SwiftUI Navigation 导航

```swift

// iOS 16+ NavigationStack

struct ContentView: View {

@Stateprivatevar path: [Screen] = []


var body: some View {

        NavigationStack(path: $path) {

            List(entries) { entry in

                NavigationLink(value: entry) {

                    JournalRow(entry: entry)

                }

            }

            .navigationDestination(for: JournalEntry.self) { entry in

                JournalDetailView(entry: entry)

            }

        }

    }

}

```

### 10. SwiftUI Previews

```swift

#Preview {

    JournalEditorView(entry: JournalEntry(title: "测试日记"))

        .modelContainer(for: [JournalEntry.self], inMemory: true)

}


#Preview("Dark Mode") {

    JournalEditorView(entry: JournalEntry(title: "测试日记"))

        .preferredColorScheme(.dark)

}

```

---

## 设计规范

### Liquid Glass 风格

**材质效果**:

-`.ultraThinMaterial` - 主卡片

-`.thinMaterial` - 次要元素

-`.regularMaterial` - 背景

**圆角规范**:

- 大卡片: 24-32pt
- 中卡片: 16-20pt
- 小元素: 12pt

**颜色主题**:

```swift

struct AppTheme {

staticlet primary = Color.blue

staticlet accent = Color.purple

staticlet success = Color.green

staticlet warning = Color.orange

staticlet danger = Color.red

}

```

**动画**:

- 使用 `.spring(response: 0.3, dampingFraction: 0.7)`
- 页面转场: `.navigationTransition(.zoom)`
- 元素出现: `.scaleEffect().opacity()`

---

## 关键文件清单

### 需要创建的核心文件（按优先级）

#### 优先级 1（项目基础）

1.`Models/JournalEntry.swift`

2.`Models/Attachment.swift`

3.`Services/DataService.swift`

4.`MindLogApp.swift` (修改)

5.`Views/Components/GlassCard.swift`

#### 优先级 2（手帐功能）

6.`Views/Journal/JournalEditorView.swift`

7.`Views/Journal/JournalListView.swift`

8.`Views/Journal/JournalDetailView.swift`

9.`Views/Journal/MoodPickerView.swift`

10.`Views/Journal/WeatherPickerView.swift`

#### 优先级 3（高级功能）

11.`Views/Journal/CalendarView.swift`

12.`Views/Journal/SearchView.swift`

13.`Services/BackgroundRemovalService.swift`

#### 优先级 4（AI 功能）

14.`Services/AIService.swift`

15.`Views/AI/AIHomeView.swift`

16.`Views/AI/AIChatView.swift`

17.`Views/AI/WeeklyReviewView.swift`

18.`Views/AI/MoodTrendView.swift`

#### 优先级 5（社区功能）

19.`Services/CommunityService.swift`

20.`Views/Community/CommunityFeedView.swift`

21.`Views/Community/PostDetailView.swift`

---

## 验收标准

### MVP 阶段（Phase 1-3）

- [X] 创建包含多模态数据的日记
- [X] 编辑和删除日记
- [X] 日历视图查看日记
- [X] 搜索日记内容
- [X] 抠图功能可用
- [X] 数据持久化和 iCloud 同步
- [X] Face ID/Touch ID 锁定

### 完整版本（Phase 1-7）

- [X] 所有 MVP 功能
- [X] AI 聊天和提醒
- [X] 周月复盘生成
- [X] 情绪趋势分析
- [X] 智能排版生成
- [X] 音频转文字
- [X] 社区分享和互动
- [X] 完整的测试覆盖

---



---

## 开发资源

### Apple 框架文档

- [SwiftData](https://developer.apple.com/documentation/swiftdata)
- [Vision](https://developer.apple.com/documentation/vision)
- [Speech](https://developer.apple.com/documentation/speech)
- [Charts](https://developer.apple.com/documentation/charts)
- [AVFoundation](https://developer.apple.com/documentation/avfoundation)
- [Liquid Glass Design](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass)

### 设计参考

- Apple Journal App
- WWDC 2024: Capwords 演示
- Apple Human Interface Guidelines

---

## 注意事项

1.**数据隐私**

- 所有日记数据仅本地存储（SwiftData）
- MVP 阶段无云同步
- 社区分享为 Mock 数据，无真实上传

2.**性能优化**

- 大量图片时使用懒加载
- 音频/视频使用缩略图
- AI 分析在后台队列执行

3.**用户体验**

- 首次使用引导流程
- 功能渐进式展示
- 空状态友好提示

4.**错误处理**

- 网络错误友好提示
- Gemini API 调用失败时的降级方案（缓存或离线提示）
- 数据持久化错误处理

5.**Gemini API Key 管理**

- MVP 阶段使用固定 API Key（存储在 `Constants.swift`）
- 后续版本考虑后端代理或用户自定义 Key
