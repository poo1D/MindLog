//
//  AgentService.swift
//  MindLog_
//
//  Created by Agent on 2026/02/28.
//

import Foundation
import SwiftData
import SwiftUI

/// Agent 协调服务，负责处理本地 RAG 和工具调度
@MainActor
final class AgentService {
    static let shared = AgentService()
    
    // 初始化私有化
    private init() {}
    
    /// 日记保存后的后处理总入口 (Agent Workflow)
    func processJournalEntry(_ entry: JournalEntry, in context: ModelContext) async {
        guard let content = entry.textContent, !content.isEmpty else { return }
        
        do {
            // Step 1: 调用 analyze_emotion (情绪分析工具)
            let analysisResult = try await GeminiService.shared.analyzeContent(text: content, base64Images: nil)
            
            // 更新基础分析结果
            entry.aiSentimentScore = analysisResult.sentimentScore
            entry.emotionTone = analysisResult.emotionTone
            entry.aiSummary = analysisResult.summary
            entry.aiTags = analysisResult.tags
            entry.isAIAnalyzed = true
            
            // Step 2: 调用 search_memory (记忆检索工具)
            let memoryContext = fetchMemoryContext(for: entry.createdAt, in: context)
            
            // Step 3: 调用 generateEchoStory (幻觉故事生成)
            let tone = analysisResult.emotionTone ?? "平静的一天"
            let generatedStory = try await generateEchoStory(for: content, emotionTone: tone, memory: memoryContext)
            
            entry.aiStory = generatedStory
            
            // 提交上下文保存
            try context.save()
            print("Agent Workflow 完成！生成了 Echo 的故事。")
            
        } catch {
            print("Agent Workflow 失败: \(error.localizedDescription)")
        }
    }
    
    /// 工具: fetchMemoryContext (本地 RAG)
    private func fetchMemoryContext(for currentDate: Date, in context: ModelContext) -> String {
        // 获取过去 7 天的时间
        guard let pastDate = Calendar.current.date(byAdding: .day, value: -7, to: currentDate) else {
            return "无历史记忆。"
        }
        
        // 此处 SwiftData 的谓词无法直接用 Date 的比较，改为过滤再处理，或直接获取全量排序后过滤
        let descriptor = FetchDescriptor<JournalEntry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        var memoryString = "【最近几天的记忆状态】：\n"
        
        do {
            let allEntries = try context.fetch(descriptor)
            // 过滤过去七天的（排除当前的），避免谓词报错
            let pastEntries = allEntries.filter { $0.id != currentDate.hashValue as? UUID && $0.createdAt > pastDate && $0.createdAt < currentDate }
            
            if pastEntries.isEmpty {
                memoryString += "最近没有其他日记。\n"
            } else {
                for (index, past) in pastEntries.prefix(3).enumerated() {
                    let dateStr = past.createdAt.formatted(date: .numeric, time: .omitted)
                    let tone = past.emotionTone ?? "无特殊情绪"
                    let summary = past.aiSummary ?? past.title
                    memoryString += "\(index + 1). [\(dateStr)] 情绪：\(tone)，摘要：\(summary)\n"
                }
            }
        } catch {
            memoryString += "无法读取记忆。\n"
        }
        
        return memoryString
    }
    
    /// 工具: generateEchoStory (基于 Gemini 的创意生成)
    private func generateEchoStory(for content: String, emotionTone: String, memory: String) async throws -> String {
        let systemPrompt = """
        你是一名富有同理心的童话作家，你的任务是为电子日记 App 里的守护小精灵 "Echo" 写一段短篇日记（150字左右）。
        Echo 存在于用户的手机里，它会感知主人每一天经历的事情，并且在它的奇幻世界里产生对应的冒险。
        
        规则：
        1. 必须以 Echo 的第一人称来写（"我"指代 Echo，"主人"指代日记的作者）。
        2. 如果主人今天累了，Echo 在它的世界里可能刚打败了一只梦魇怪；如果主人很开心，Echo 可能在阳光森林里收集了露水晶。
        3. 用生动、可爱、治愈的语气，结尾给主人一句简单的温暖祝福。
        """
        
        let userMessage = """
        【主人今日情绪基调】：\(emotionTone)
        【主人今日日记】：\(content)
        
        \(memory)
        
        请结合主人的真实情绪和记忆，发挥想象力，为 Echo 生成今日的心情小故事：
        """
        
        let chatHistory = ChatMessage(role: .assistant, content: systemPrompt)
        
        let response = try await GeminiService.shared.generateChatResponse(
            message: userMessage,
            conversationHistory: [chatHistory],
            personality: .optimistic
        )
        
        return response
    }
}
