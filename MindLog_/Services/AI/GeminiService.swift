//
//  GeminiService.swift
//  MindLog_
//
//  Created by AI Assistant on 2026/1/31.
//

import Foundation

/// Gemini API 服务实现
final class GeminiService {
    @MainActor
    static let shared = GeminiService()

    // MARK: - Properties

    private let apiKey: String
    private let baseURL: String
    private let session: URLSession
    private let apiQueue = APIQueue()

    // MARK: - 默认配置

    private static let defaultAPIKey = "AIzaSyBoFLeSAatQlya0oS_Hq1ABLNrhcrslmUw"
    private static let defaultBaseURL = "https://generativelanguage.googleapis.com/v1beta"
    private static let defaultModel = "gemini-2.0-flash"

    // MARK: - Initialization

    init(apiKey: String? = nil) {
        self.apiKey = apiKey ?? Self.defaultAPIKey
        self.baseURL = "\(Self.defaultBaseURL)/models/\(Self.defaultModel):generateContent"

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }

    // MARK: - Content Analysis

    func analyzeContent(text: String, base64Images: [String]?) async throws -> AIAnalysisResult {
        // 等待 API 可用槽位
        await apiQueue.waitForSlot()

        let prompt = """
        你是 MindLog 日记应用的 AI 助手。请分析以下日记内容，提取关键信息。

        分析要求：
        1. **标签（tags）**：生成 3-5 个标签，用于分类和检索
        2. **总结（summary）**：用 1-2 句话概括日记核心内容
        3. **情感评分（sentimentScore）**：0-1 的分数，0=最消极，0.5=中性，1=最积极
        4. **情绪基调（emotionTone）**：用1-2句话深度解析当前的情绪状态（如："今天经历了紧张的工作，但晚上做饭获得了治愈和满足。"）
        5. **待办事项（todos）**：提取明确的待办事项，包含标题和优先级（低/中/高）
        6. **购物清单（shoppingList）**：提取需要购买的物品
        7. **日程安排（schedule）**：提取具体的日程信息

        日记内容：
        \(text)

        请严格返回以下 JSON 格式（不要添加任何其他文字）：
        {
            "tags": ["标签1", "标签2", "标签3"],
            "summary": "总结内容",
            "sentimentScore": 0.7,
            "emotionTone": "情绪基调字符串",
            "todos": [
                {"title": "待办标题", "priority": "高"}
            ],
            "shoppingList": [
                {"name": "商品名", "quantity": "数量", "category": "类别"}
            ],
            "schedule": [
                {"title": "日程标题", "location": "地点", "notes": "备注"}
            ]
        }
        """

        // 构建请求体
        var parts: [[String: Any]] = [["text": prompt]]

        // 添加图片（如果有）
        if let images = base64Images, !images.isEmpty {
            for imageBase64 in images.prefix(3) {
                parts.append([
                    "inlineData": [
                        "mimeType": "image/jpeg",
                        "data": imageBase64
                    ]
                ])
            }
        }

        let requestBody: [String: Any] = [
            "contents": [[
                "parts": parts
            ]],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 2048,
                "responseMimeType": "application/json"
            ]
        ]

        // 发送请求
        let response: GeminiResponse = try await performRequest(body: requestBody)

        // 解析结果
        guard let text = response.candidates.first?.content.parts.first?.text else {
            throw AIServiceError.invalidResponse
        }

        // 解析 JSON
        guard let data = text.data(using: .utf8),
              let result = try? JSONDecoder().decode(AIAnalysisResult.self, from: data) else {
            throw AIServiceError.decodingFailed
        }

        return result
    }

    // MARK: - Chat Response

    func generateChatResponse(
        message: String,
        conversationHistory: [ChatMessage],
        personality: ChatPersonality
    ) async throws -> String {
        await apiQueue.waitForSlot()

        // 构建对话历史
        var contents: [[String: Any]] = []

        // 添加系统提示
        contents.append([
            "role": "user",
            "parts": [["text": personality.systemPrompt]]
        ])

        // 添加历史对话
        for chatMessage in conversationHistory.suffix(10) { // 只保留最近10条
            let role = chatMessage.role == .user ? "user" : "model"
            contents.append([
                "role": role,
                "parts": [["text": chatMessage.content]]
            ])
        }

        // 添加当前消息
        contents.append([
            "role": "user",
            "parts": [["text": message]]
        ])

        let requestBody: [String: Any] = [
            "contents": contents,
            "generationConfig": [
                "temperature": 0.8,
                "maxOutputTokens": 1024
            ]
        ]

        let response: GeminiResponse = try await performRequest(body: requestBody)

        guard let text = response.candidates.first?.content.parts.first?.text else {
            throw AIServiceError.invalidResponse
        }

        return text
    }

    // MARK: - Review Report

    func generateReviewReport(
        entries: [JournalEntryForAnalysis],
        startDate: Date,
        endDate: Date,
        type: ReviewType
    ) async throws -> ReviewReportData {
        await apiQueue.waitForSlot()

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "zh_CN")

        // 构建日记摘要
        var entriesSummary = ""
        for (index, entry) in entries.enumerated() {
            let moodStr = entry.moodEmoji ?? "😐"
            entriesSummary += """
            \(index + 1). \(entry.title) (\(dateFormatter.string(from: entry.date)))
               心情：\(moodStr)
               内容：\(entry.content ?? "无内容")
               标签：\(entry.aiTags?.joined(separator: ", ") ?? "无")

            """
        }

        let prompt = """
        你是 MindLog 日记应用的复盘助手。请基于以下日记内容生成\(type.rawValue)。

        时间范围：\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))
        日记数量：\(entries.count)篇

        日记内容：
        \(entriesSummary)

        请分析并返回以下 JSON 格式：
        {
            "type": "\(type.rawValue)",
            "startDate": "\(ISO8601DateFormatter().string(from: startDate))",
            "endDate": "\(ISO8601DateFormatter().string(from: endDate))",
            "summary": "总体总结，描述这段时间的主要特点和变化",
            "emotionCurve": [
                {"date": "2026-01-31", "score": 0.7}
            ],
            "keyEvents": ["关键事件1", "关键事件2", "关键事件3"],
            "growthInsights": ["成长洞察1", "成长洞察2"],
            "todoCompletion": {
                "total": 10,
                "completed": 7,
                "completionRate": 0.7,
                "insights": ["待办完成情况分析"]
            },
            "nextPeriodSuggestions": ["建议1", "建议2", "建议3"]
        }

        注意：
        1. emotionCurve 应包含每天的情感评分（0-1）
        2. keyEvents 最多5个
        3. todoCompletion 需要估算
        """

        let requestBody: [String: Any] = [
            "contents": [[
                "parts": [["text": prompt]]
            ]],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 4096,
                "responseMimeType": "application/json"
            ]
        ]

        let response: GeminiResponse = try await performRequest(body: requestBody)

        guard let text = response.candidates.first?.content.parts.first?.text else {
            throw AIServiceError.invalidResponse
        }

        // Parse JSON manually since ReviewReportData doesn't conform to Codable
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AIServiceError.decodingFailed
        }

        // Parse the response and create ReviewReportData
        let isoFormatter = ISO8601DateFormatter()
        let summary = json["summary"] as? String ?? ""

        // Parse emotion curve
        var emotionPoints: [EmotionPoint] = []
        if let curveData = json["emotionCurve"] as? [[String: Any]] {
            for point in curveData {
                if let dateStr = point["date"] as? String,
                   let score = point["score"] as? Double,
                   let date = isoFormatter.date(from: dateStr) {
                    emotionPoints.append(EmotionPoint(id: UUID(), date: date, score: score))
                }
            }
        }

        let keyEvents = json["keyEvents"] as? [String] ?? []
        let growthInsights = json["growthInsights"] as? [String] ?? []
        let nextSuggestions = json["nextPeriodSuggestions"] as? [String] ?? []

        // Parse todo completion
        var todoAnalysis: TodoAnalysis?
        if let todoData = json["todoCompletion"] as? [String: Any] {
            let total = todoData["total"] as? Int ?? 0
            let completed = todoData["completed"] as? Int ?? 0
            let rate = todoData["completionRate"] as? Double ?? 0.0
            let insights = todoData["insights"] as? [String] ?? []
            todoAnalysis = TodoAnalysis(total: total, completed: completed, completionRate: rate, insights: insights)
        }

        return ReviewReportData(
            type: type,
            startDate: startDate,
            endDate: endDate,
            summary: summary,
            emotionCurve: emotionPoints,
            keyEvents: keyEvents,
            growthInsights: growthInsights,
            todoCompletion: todoAnalysis ?? TodoAnalysis(total: 0, completed: 0, completionRate: 0, insights: []),
            nextPeriodSuggestions: nextSuggestions
        )
    }

    // MARK: - Layout Generation

    func generateLayout(
        content: String,
        template: LayoutTemplate,
        imageCount: Int
    ) async throws -> String {
        await apiQueue.waitForSlot()

        let prompt: String
        if template == .auto {
            prompt = """
            你是 MindLog 的布局设计师。请根据以下日记内容，自动选择最合适的布局模板并生成布局配置。

            日记内容：\(content)
            图片数量：\(imageCount)

            可选模板：
            - minimal: 极简风格，适合短篇日记
            - classic: 经典手帐风格
            - story: 图文故事，适合有图片的日记
            - todo: 待办聚焦，适合有明确待办的日记
            - artistic: 艺术排版

            请返回布局配置 JSON：
            {
                "template": "选择的模板",
                "sections": [
                    {
                        "type": "title/content/image/tags",
                        "frame": {"x": 0.0, "y": 0.0, "width": 1.0, "height": 0.1},
                        "style": {"fontSize": 28, "fontWeight": "bold", "alignment": "center"}
                    }
                ]
            }

            frame 使用相对坐标（0-1），sections 数量 3-6 个。
            """
        } else {
            prompt = """
            你是 MindLog 的布局设计师。请为以下日记内容生成"\(template.rawValue)"风格的布局配置。

            日记内容：\(content)
            图片数量：\(imageCount)

            请返回布局配置 JSON：
            {
                "template": "\(template.rawValue)",
                "sections": [
                    {
                        "type": "title/content/image/tags",
                        "frame": {"x": 0.0, "y": 0.0, "width": 1.0, "height": 0.1},
                        "style": {"fontSize": 28, "fontWeight": "bold", "alignment": "center"}
                    }
                ]
            }
            """
        }

        let requestBody: [String: Any] = [
            "contents": [[
                "parts": [["text": prompt]]
            ]],
            "generationConfig": [
                "temperature": 0.6,
                "maxOutputTokens": 2048,
                "responseMimeType": "application/json"
            ]
        ]

        let response: GeminiResponse = try await performRequest(body: requestBody)

        guard let text = response.candidates.first?.content.parts.first?.text else {
            throw AIServiceError.invalidResponse
        }

        return text
    }

    // MARK: - Helper Methods

    private func performRequest(body: [String: Any]) async throws -> GeminiResponse {
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw AIServiceError.serviceUnavailable
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw AIServiceError.encodingFailed
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIServiceError.invalidResponse
            }

            if httpResponse.statusCode == 429 {
                throw AIServiceError.rateLimitExceeded
            }

            if httpResponse.statusCode != 200 {
                if let errorStr = String(data: data, encoding: .utf8) {
                    print("Gemini API Error: \(errorStr)")
                }
                throw AIServiceError.serviceUnavailable
            }

            let result = try JSONDecoder().decode(GeminiResponse.self, from: data)
            return result

        } catch let error as AIServiceError {
            throw error
        } catch {
            throw AIServiceError.networkError(error)
        }
    }
}

// MARK: - API Queue Actor

/// API 请求队列管理器（处理限流）
actor APIQueue {
    private var lastRequestTime: Date?
    private let minInterval: TimeInterval = 4.0  // 15次/分钟 = 4秒间隔

    func waitForSlot() async {
        if let lastTime = lastRequestTime {
            let elapsed = Date().timeIntervalSince(lastTime)
            if elapsed < minInterval {
                let delay = minInterval - elapsed
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        lastRequestTime = Date()
    }
}

// MARK: - Gemini Response Models

struct GeminiResponse: Codable {
    let candidates: [Candidate]
}

struct Candidate: Codable {
    let content: Content
    let finishReason: String?
}

struct Content: Codable {
    let parts: [Part]
}

struct Part: Codable {
    let text: String?
}
