//
//  AIProtocol.swift
//  MindLog_
//
//  Created by AI Assistant on 2026/1/31.
//

import Foundation
import SwiftUI

// Forward declare MoodType (defined in MoodType.swift)
// This file will compile after all models are created

/// AI 分析结果
struct AIAnalysisResult: Codable, Sendable {
    /// 标签
    var tags: [String]?
    /// 总结
    var summary: String?
    /// 情感评分 (0-1, 0=最消极, 1=最积极)
    var sentimentScore: Double?
    /// 深入的情绪基调分析
    var emotionTone: String?
    /// 提取的待办事项
    var todos: [ExtractedTodo]?
    /// 购物清单
    var shoppingList: [ExtractedShoppingItem]?
    /// 日程安排
    var schedule: [ExtractedScheduleItem]?
}

/// 提取的待办事项
struct ExtractedTodo: Codable, Identifiable, Sendable {
    var id: UUID = UUID()
    var title: String
    var priority: String
    var dueDate: Date?
}

/// 提取的购物清单项
struct ExtractedShoppingItem: Codable, Identifiable, Sendable {
    var id: UUID = UUID()
    var name: String
    var quantity: String?
    var category: String?
    var isPurchased: Bool = false
}

/// 提取的日程安排项
struct ExtractedScheduleItem: Codable, Identifiable, Sendable {
    var id: UUID = UUID()
    var title: String
    var startDate: Date?
    var endDate: Date?
    var location: String?
    var notes: String?
}

/// AI 服务错误
enum AIServiceError: Error, LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case rateLimitExceeded
    case encodingFailed
    case decodingFailed
    case serviceUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "API Key 无效或未配置"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .invalidResponse:
            return "服务器返回了无效的响应"
        case .rateLimitExceeded:
            return "API 请求次数超限，请稍后再试"
        case .encodingFailed:
            return "数据编码失败"
        case .decodingFailed:
            return "数据解析失败"
        case .serviceUnavailable:
            return "AI 服务暂时不可用"
        }
    }
}

/// AI 服务协议
protocol AIServiceProtocol: Sendable {
    /// 分析多模态内容（文本 + 图片）
    /// - Parameters:
    ///   - text: 文本内容
    ///   - base64Images: Base64 编码的图片数组（最多3张）
    /// - Returns: AI 分析结果
    func analyzeContent(text: String, base64Images: [String]?) async throws -> AIAnalysisResult

    /// 生成聊天回复
    /// - Parameters:
    ///   - message: 用户消息
    ///   - conversationHistory: 对话历史
    ///   - personality: AI 人格类型
    /// - Returns: AI 回复
    func generateChatResponse(
        message: String,
        conversationHistory: [ChatMessage],
        personality: ChatPersonality
    ) async throws -> String

    /// 生成复盘报告
    /// - Parameters:
    ///   - entries: 日记条目数组
    ///   - startDate: 开始日期
    ///   - endDate: 结束日期
    ///   - type: 报告类型（周报/月报）
    /// - Returns: 复盘报告
    func generateReviewReport(
        entries: [JournalEntryForAnalysis],
        startDate: Date,
        endDate: Date,
        type: ReviewType
    ) async throws -> ReviewReportData

    /// 生成手帐布局
    /// - Parameters:
    ///   - content: 日记内容
    ///   - template: 模板类型
    ///   - imageCount: 图片数量
    /// - Returns: 布局配置 JSON
    func generateLayout(
        content: String,
        template: LayoutTemplate,
        imageCount: Int
    ) async throws -> String
}

/// 聊天人格类型
enum ChatPersonality: String, CaseIterable, Sendable {
    case warm = "温暖共情"
    case professional = "专业顾问"
    case optimistic = "乐观伙伴"
    case philosophical = "哲学思考"
    case concise = "简洁明了"

    var systemPrompt: String {
        switch self {
        case .warm:
            return """
            你是一个温暖、共情的倾听者。你善于理解用户的情绪，给予安慰和支持。
            你的回应充满关怀，语气柔和，从不评判。你总是站在用户的角度思考问题。
            """
        case .professional:
            return """
            你是一个专业的心理咨询师。你运用专业知识帮助用户分析和解决问题。
            你的回应客观、理性，善于引导用户深入思考，提供可行的建议。
            """
        case .optimistic:
            return """
            你是一个乐观积极的朋友。你总是能看到事情积极的一面，鼓励用户保持希望。
            你的回应充满正能量，善于发现用户生活中的亮点和成长。
            """
        case .philosophical:
            return """
            你是一个哲学思考者。你善于从日常生活中提炼深刻的哲理和智慧。
            你的回应富有洞察力，引导用户思考人生的本质和意义。
            """
        case .concise:
            return """
            你的回应简洁明了，直击要点。你善于总结关键信息，用最少的文字传达最核心的洞察。
            你避免冗长的解释，直接给出有价值的反馈。
            """
        }
    }

    var icon: String {
        switch self {
        case .warm: return "heart.fill"
        case .professional: return "brain.head.profile"
        case .optimistic: return "sun.max.fill"
        case .philosophical: return "moon.stars.fill"
        case .concise: return "bolt.fill"
        }
    }

    var color: String {
        switch self {
        case .warm: return "pink"
        case .professional: return "blue"
        case .optimistic: return "yellow"
        case .philosophical: return "purple"
        case .concise: return "orange"
        }
    }
}

/// 聊天消息
struct ChatMessage: Codable, Identifiable, Sendable {
    var id: UUID = UUID()
    var role: MessageRole
    var content: String
    var timestamp: Date = Date()

    enum MessageRole: String, Codable {
        case user
        case assistant
    }
}

/// 复盘类型
enum ReviewType: String, Sendable {
    case weekly = "周报"
    case monthly = "月报"
}

/// 日记条目（用于分析）
struct JournalEntryForAnalysis: Sendable {
    let id: UUID
    let date: Date
    let title: String
    let content: String?
    let moodEmoji: String?  // Store mood emoji directly (e.g., "😄", "🙂")
    let aiTags: [String]?
    let aiSummary: String?
}

/// 复盘报告数据
struct ReviewReportData: Sendable {
    let type: ReviewType
    let startDate: Date
    let endDate: Date
    let summary: String
    let emotionCurve: [EmotionPoint]
    let keyEvents: [String]
    let growthInsights: [String]
    let todoCompletion: TodoAnalysis
    let nextPeriodSuggestions: [String]
}

/// 情感数据点
struct EmotionPoint: Identifiable, Sendable {
    let id: UUID
    let date: Date
    let score: Double  // 0-1

    init(id: UUID, date: Date, score: Double) {
        self.id = id
        self.date = date
        self.score = score
    }
}

/// 待办完成情况分析
struct TodoAnalysis: Codable, Sendable {
    let total: Int
    let completed: Int
    let completionRate: Double
    let insights: [String]
}

/// 布局模板类型
enum LayoutTemplate: String, CaseIterable, Sendable {
    case minimal = "极简"
    case classic = "经典"
    case story = "图文故事"
    case todo = "待办聚焦"
    case artistic = "艺术"
    case auto = "自动"

    var description: String {
        switch self {
        case .minimal: return "简洁优雅，适合短篇日记"
        case .classic: return "经典手帐风格，内容为主"
        case .story: return "图片为主，文字为辅"
        case .todo: return "突出待办事项"
        case .artistic: return "艺术排版，打破常规"
        case .auto: return "AI 根据内容自动选择"
        }
    }
}
