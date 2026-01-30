//
//  JournalDetailView.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import SwiftUI

/// 日记详情视图
struct JournalDetailView: View {
    let entry: JournalEntry
    
    @State private var showingEditor = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 标题
                Text(entry.title)
                    .font(.title)
                    .bold()
                
                // 日期和时间
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                    Text(entry.createdAt, format: Date.FormatStyle(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // 元数据区域
                if entry.mood != nil || entry.weather != nil || entry.exercise != nil {
                    VStack(alignment: .leading, spacing: 12) {
                        // 心情
                        if let mood = entry.mood {
                            HStack {
                                Text("心情")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(mood.rawValue)
                                    .font(.title)
                                
                                Text(mood.description)
                                    .foregroundColor(mood.color)
                            }
                        }
                        
                        // 天气
                        if let weather = entry.weather {
                            HStack {
                                Text("天气")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(weather.condition.rawValue)
                                    .font(.title2)
                                
                                Text(weather.condition.description)
                                
                                if let temp = weather.temperature {
                                    Text("\(Int(temp))°C")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        // 运动
                        if let exercise = entry.exercise {
                            HStack {
                                Text("运动")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(exercise.type.rawValue)
                                    .font(.title2)
                                
                                Text(exercise.type.description)
                                
                                Text("\(Int(exercise.duration))分钟")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                }
                
                // 正文内容
                if let content = entry.textContent {
                    Text(content)
                        .font(.body)
                        .lineSpacing(8)
                }
                
                // 待办事项
                if let todos = entry.todos, !todos.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("待办事项")
                            .font(.headline)
                        
                        ForEach(todos) { todo in
                            HStack {
                                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(todo.isCompleted ? .green : .secondary)
                                
                                Text(todo.title)
                                    .strikethrough(todo.isCompleted)
                                
                                Spacer()
                                
                                Text(todo.priority.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                }
                
                // AI 标签
                if let tags = entry.aiTags, !tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AI 标签")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                }
                
                // 附件
                if let attachments = entry.attachments, !attachments.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("附件 (\(attachments.count))")
                            .font(.headline)
                        
                        ForEach(attachments) { attachment in
                            HStack {
                                Image(systemName: attachment.type.icon)
                                Text(attachment.metadata?.fileName ?? "附件")
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                if let size = attachment.metadata?.fileSize {
                                    Text(formatFileSize(size))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEditor = true
                } label: {
                    Text("编辑")
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            JournalEditorView(entry: entry)
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

#Preview {
    NavigationStack {
        JournalDetailView(
            entry: JournalEntry(
                title: "美好的一天",
                textContent: "今天天气很好，心情也很棒！去公园散步了，看到了很多美丽的花朵。下午和朋友喝了咖啡，聊了很多有趣的话题。",
                mood: .happy,
                weather: WeatherInfo(condition: .sunny, temperature: 25, location: "北京"),
                exercise: ExerciseRecord(type: .running, duration: 30, distance: 5, calories: 200),
                aiTags: ["开心", "运动", "朋友"]
            )
        )
    }
}
