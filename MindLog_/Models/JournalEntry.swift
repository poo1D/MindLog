//
//  JournalEntry.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import Foundation
import SwiftData

/// 日记条目模型
@Model
final class JournalEntry {
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    
    // 基础内容
    var title: String
    var textContent: String?
    
    // 元数据
    var mood: MoodType?
    var weather: WeatherInfo?
    var exercise: ExerciseRecord?
    var todos: [TodoItem]?

    // AI 生成的数据
    var aiTags: [String]?
    var aiSummary: String?
    var aiLayout: String?  // JSON 格式存储手帐排版
    var aiSentimentScore: Double?  // 情感评分 (0-1)
    var isAIAnalyzed: Bool = false  // 是否已进行 AI 分析

    // AI 提取和生成的更深层情感资产 (Agent Workflow)
    var emotionTone: String? // 情绪基调，例如“疲惫但充实”
    var aiStory: String? // 为宠物 Echo 生成的历险故事

    // 关系：附件（图片、音频、视频）
    @Relationship(deleteRule: .cascade)
    var attachments: [Attachment]?

    // 关系：AI 提取的数据
    @Relationship(deleteRule: .cascade)
    var shoppingList: [ShoppingItem]?

    @Relationship(deleteRule: .cascade)
    var schedule: [ScheduleItem]?
    
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        title: String,
        textContent: String? = nil,
        mood: MoodType? = nil,
        weather: WeatherInfo? = nil,
        exercise: ExerciseRecord? = nil,
        todos: [TodoItem]? = nil,
        aiTags: [String]? = nil,
        aiSummary: String? = nil,
        aiLayout: String? = nil,
        aiSentimentScore: Double? = nil,
        emotionTone: String? = nil,
        aiStory: String? = nil,
        isAIAnalyzed: Bool = false,
        attachments: [Attachment]? = nil,
        shoppingList: [ShoppingItem]? = nil,
        schedule: [ScheduleItem]? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.title = title
        self.textContent = textContent
        self.mood = mood
        self.weather = weather
        self.exercise = exercise
        self.todos = todos
        self.aiTags = aiTags
        self.aiSummary = aiSummary
        self.aiLayout = aiLayout
        self.aiSentimentScore = aiSentimentScore
        self.emotionTone = emotionTone
        self.aiStory = aiStory
        self.isAIAnalyzed = isAIAnalyzed
        self.attachments = attachments
        self.shoppingList = shoppingList
        self.schedule = schedule
    }
}
