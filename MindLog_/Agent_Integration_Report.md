# MindLog Agent 工具调用与联动技术实现报告

## 1. 架构思路线（路线 A：链式 Workflow 架构）

为了在 Hackathon 中达到最稳定的展现效果、最快的响应速度，我们将采用**以 Swift 主导的链式工作流 (Workflow Pipeline)** 方式，将大模型能力的调用（Tool Use）抽象包装好，在用户点击『保存日记』后静默触发。这条链路的核心是让 Agent （代码逻辑层）自主调度各个 Tool。

**整体调用链路：**
1. **日记保存拦截**：当用户在 `JournalEditorView` 中点击保存，同步将文本落库（SwiftData）。
2. **触发 Agent Orchestrator**：在后台线程启动一条不可见的任务，传入刚刚保存的 `JournalEntry`。
3. **Step 1: 调用 `analyze_emotion` (情绪分析工具)**
   * 向大语言模型提取更深入的 `emotionTone` (情绪基调) 以及量化的 `sentimentScore`。
4. **Step 2: 调用 `search_memory` (记忆检索工具 / 本地 RAG)**
   * Swift 代码读取本地 SwiftData 数据库。
   * **时间线检索**：提取该用户过去 3~7 天内的日记摘要。
   * **状态检索**：提取今天的待办事项 (Todos) / 日程 (Schedules)。
   * 将这些结果糅合成一段具有强关联性的“当前世界状态(World State)”。
5. **Step 3: 调用 `update_pet` (幻觉故事生成与 Echo 更新)**
   * Agent 将 **Step 1 (今日情绪基调)** 与 **Step 2 (过往记忆和世界状态)** 进行结合。
   * 指挥大语言模型发挥“幻觉”，续写一段有关“小精灵 Echo 今天的奇幻冒险”的几百字故事。
6. **最终落库与 UI 联动**：把生成的故事保存在 `JournalEntry` 中，作为 Echo 今日的冒险日记展示。

## 2. 代码具体修改计划

### 修改点一：数据模型扩展 (`JournalEntry.swift`, `AIProtocol.swift`)
为了让新的数据落地，需要扩展实体模型。
*   **`AIProtocol.swift`**：在 `AIAnalysisResult` 中增加 `var emotionTone: String?` 字段。
*   **`JournalEntry.swift`**：
    *   增加 `var emotionTone: String?` (情绪基调，比如："疲惫但充实")。
    *   增加 `var aiStory: String?` (根据情绪和世界观生成的宠物冒险故事)。

### 修改点二：修改 AI 分析工具 (`GeminiService.swift`)
升级 `analyzeContent` 的 Prompt，使其不仅返回分数，而且强制输出 `"emotionTone"` 参数。
例如：`{"emotionTone": "今天经历了紧张的工作，但晚上做饭获得了治愈和满足。"}`

### 修改点三：实现核心调度引擎 (`AgentService.swift` - 全新)
在 `MindLog_/Services/AI` 下新建一个文件 `AgentService.swift`，包含如下逻辑：
1.  `func processJournalEntry(_ entry: JournalEntry, in context: ModelContext)`: 总入口，包裹整个 Workflow。
2.  **Tool: `analyzeEmotion()`**: 调用 Gemini 分析刚写的日记，拿到 `emotionTone`。
3.  **Tool: `searchMemory()`**: 根据当前的 `ModelContext`，通过 `FetchDescriptor` 查出过去 3 天的日记 `JournalEntry`，抓取其标题或摘要拼接出长字符串 `memoryContext`。
4.  **Tool: `generateWorldStateAndStory()`**: 把上面拿到的数据混合进 prompt，生成属于 Echo 的小故事，并写回 `entry.aiStory` 里，最终 `context.save()`。

### 修改点四：UI 触发点接入 (`JournalEditorView.swift`)
修改 `JournalEditorView.swift` 中的 `saveEntry()`。
使用 `Task { }` 派发异步任务去调用 `AgentService.shared.processJournalEntry(...)` 以保持前台界面立即关闭的丝滑体验。
