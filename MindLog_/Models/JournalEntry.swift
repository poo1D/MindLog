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
    
    // 关系：附件（图片、音频、视频）
    @Relationship(deleteRule: .cascade)
    var attachments: [Attachment]?
    
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
        attachments: [Attachment]? = nil
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
        self.attachments = attachments
    }
}
