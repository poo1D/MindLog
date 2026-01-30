//
//  JournalEditorView.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import SwiftUI
import SwiftData

/// 日记编辑器（Apple Journal 风格）
struct JournalEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 编辑模式
    let entry: JournalEntry?
    
    // 表单数据
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedMood: MoodType?
    @State private var selectedWeather: WeatherInfo?
    @State private var selectedExercise: ExerciseRecord?
    
    // Sheet 状态
    @State private var showingMoodPicker = false
    @State private var showingWeatherPicker = false
    @State private var showingExercisePicker = false
    
    @FocusState private var isContentFocused: Bool
    
    var isEditing: Bool {
        entry != nil
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Liquid Glass 背景
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 主编辑区域
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // 标题输入
                            TextField("标题", text: $title, axis: .vertical)
                                .font(.title2)
                                .fontWeight(.bold)
                                .lineLimit(2)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            
                            // 元数据标签区域（Liquid Glass 风格）
                            if selectedMood != nil || selectedWeather != nil || selectedExercise != nil {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        // 心情标签
                                        if let mood = selectedMood {
                                            LiquidGlassChip(
                                                icon: mood.rawValue,
                                                text: mood.description,
                                                color: mood.color
                                            ) {
                                                withAnimation(.spring(response: 0.3)) {
                                                    selectedMood = nil
                                                }
                                            }
                                        }
                                        
                                        // 天气标签
                                        if let weather = selectedWeather {
                                            LiquidGlassChip(
                                                icon: weather.condition.rawValue,
                                                text: weather.temperature.map { "\(Int($0))°C" } ?? weather.condition.description,
                                                color: .blue
                                            ) {
                                                withAnimation(.spring(response: 0.3)) {
                                                    selectedWeather = nil
                                                }
                                            }
                                        }
                                        
                                        // 运动标签
                                        if let exercise = selectedExercise {
                                            LiquidGlassChip(
                                                icon: exercise.type.rawValue,
                                                text: "\(Int(exercise.duration / 60))分钟",
                                                color: .orange
                                            ) {
                                                withAnimation(.spring(response: 0.3)) {
                                                    selectedExercise = nil
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            
                            // 内容输入区域（Liquid Glass 卡片）
                            ZStack(alignment: .topLeading) {
                                // 半透明背景
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    if content.isEmpty && !isContentFocused {
                                        Text("记录今天发生的事...")
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 16)
                                            .padding(.top, 16)
                                    }
                                    
                                    TextEditor(text: $content)
                                        .focused($isContentFocused)
                                        .font(.body)
                                        .scrollContentBackground(.hidden)
                                        .frame(minHeight: 300)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 12)
                                        .background(Color.clear)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                    
                    // 分隔线
                    Divider()
                    
                    // 底部工具栏（Liquid Glass）
                    HStack(spacing: 0) {
                        // 心情
                        ToolbarButton(
                            systemIcon: "face.smiling",
                            label: "心情",
                            isActive: selectedMood != nil,
                            activeColor: selectedMood?.color ?? .blue
                        ) {
                            showingMoodPicker = true
                        }
                        
                        Spacer()
                        
                        // 天气
                        ToolbarButton(
                            systemIcon: "cloud.sun",
                            label: "天气",
                            isActive: selectedWeather != nil,
                            activeColor: .blue
                        ) {
                            showingWeatherPicker = true
                        }
                        
                        Spacer()
                        
                        // 运动
                        ToolbarButton(
                            systemIcon: "figure.run",
                            label: "运动",
                            isActive: selectedExercise != nil,
                            activeColor: .orange
                        ) {
                            showingExercisePicker = true
                        }
                        
                        Spacer()
                        
                        // 图片（占位）
                        ToolbarButton(
                            systemIcon: "photo",
                            label: "图片",
                            isActive: false,
                            activeColor: .green
                        ) {
                            // TODO: 图片选择
                        }
                        
                        Spacer()
                        
                        // 音频（占位）
                        ToolbarButton(
                            systemIcon: "waveform",
                            label: "音频",
                            isActive: false,
                            activeColor: .purple
                        ) {
                            // TODO: 音频录制
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.regularMaterial)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        saveEntry()
                    }
                    .bold()
                    .disabled(title.isEmpty && content.isEmpty)
                }
            }
            .onAppear {
                loadEntry()
                // 自动聚焦到内容区域
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if title.isEmpty {
                        isContentFocused = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingMoodPicker) {
            MoodPickerView(selectedMood: $selectedMood)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showingWeatherPicker) {
            WeatherPickerView(selectedWeather: $selectedWeather)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerView(selectedExercise: $selectedExercise)
                .presentationDetents([.medium, .large])
        }
    }
    
    private func loadEntry() {
        if let entry = entry {
            title = entry.title
            content = entry.textContent ?? ""
            selectedMood = entry.mood
            selectedWeather = entry.weather
            selectedExercise = entry.exercise
        }
    }
    
    private func saveEntry() {
        // 确保至少有标题或内容
        let finalTitle = title.isEmpty ? "无标题" : title
        
        if let entry = entry {
            // 编辑现有日记
            entry.title = finalTitle
            entry.textContent = content.isEmpty ? nil : content
            entry.mood = selectedMood
            entry.weather = selectedWeather
            entry.exercise = selectedExercise
            entry.updatedAt = Date()
        } else {
            // 创建新日记
            let newEntry = JournalEntry(
                title: finalTitle,
                textContent: content.isEmpty ? nil : content,
                mood: selectedMood,
                weather: selectedWeather,
                exercise: selectedExercise
            )
            modelContext.insert(newEntry)
        }
        
        dismiss()
    }
}

/// 工具栏按钮组件（纯图标）
struct ToolbarButton: View {
    let systemIcon: String
    let label: String
    var isActive: Bool = false
    var activeColor: Color = .blue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isActive ? systemIcon + ".fill" : systemIcon)
                .font(.system(size: 26))
                .foregroundStyle(isActive ? activeColor : Color.secondary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }
}

/// Liquid Glass 风格标签组件
struct LiquidGlassChip: View {
    let icon: String
    let text: String
    let color: Color
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // Emoji 图标
            Text(icon)
                .font(.body)
            
            // 文字
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
            
            // 删除按钮
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            ZStack {
                // 毛玻璃背景
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                
                // 彩色边框
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(color.opacity(0.3), lineWidth: 1.5)
                
                // 内发光效果
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(0.1),
                                color.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .shadow(color: color.opacity(0.1), radius: 4, y: 2)
    }
}

/// 元数据标签组件（保留兼容）
struct MetadataChip: View {
    let icon: String
    let text: String
    let color: Color
    let onRemove: () -> Void
    
    var body: some View {
        LiquidGlassChip(icon: icon, text: text, color: color, onRemove: onRemove)
    }
}

#Preview("新建") {
    JournalEditorView(entry: nil)
        .modelContainer(for: JournalEntry.self, inMemory: true)
}

#Preview("编辑") {
    let entry = JournalEntry(
        title: "美好的一天",
        textContent: "今天天气很好，心情也很棒！",
        mood: .happy,
        weather: WeatherInfo(condition: .sunny, temperature: 25),
        exercise: ExerciseRecord(type: .running, duration: 1800)
    )
    
    return JournalEditorView(entry: entry)
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
