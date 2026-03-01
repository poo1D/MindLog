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
    @State private var showingAIAnalysis = false
    @State private var showingAIError = false

    // AI 分析状态
    @State private var isAnalyzing = false
    @State private var aiAnalysisResult: AIAnalysisResult?
    @State private var aiErrorMessage: String?

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
                                ScrollView(.horizontal) {
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
                                .scrollIndicators(.hidden)
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

                        // AI 分析
                        ToolbarButton(
                            systemIcon: "brain.head.profile",
                            label: "AI",
                            isActive: isAnalyzing,
                            activeColor: .purple
                        ) {
                            Task {
                                await analyzeWithAI()
                            }
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
        .sheet(isPresented: $showingAIAnalysis) {
            if let result = aiAnalysisResult {
                AIAnalysisResultView(result: result) { appliedResult in
                    applyAIResult(appliedResult)
                }
            }
        }
        .alert("AI 分析失败", isPresented: $showingAIError, presenting: aiErrorMessage) { _ in
            Button("确定", role: .cancel) { }
        } message: { error in
            Text(error)
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

        let savedEntry: JournalEntry

        if let entry = entry {
            // 编辑现有日记
            entry.title = finalTitle
            entry.textContent = content.isEmpty ? nil : content
            entry.mood = selectedMood
            entry.weather = selectedWeather
            entry.exercise = selectedExercise
            entry.updatedAt = Date()
            savedEntry = entry
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
            savedEntry = newEntry
        }
        
        try? modelContext.save()

        // 静默触发 Agent 工作流 (分析情绪 + RAG回忆 + 生成故事)
        Task {
            await AgentService.shared.processJournalEntry(savedEntry, in: modelContext)
        }

        dismiss()
    }

    // MARK: - AI Analysis

    /// 使用 AI 分析当前内容
    private func analyzeWithAI() async {
        guard !content.isEmpty else {
            return
        }

        isAnalyzing = true

        do {
            let service = KimiService()
            let result = try await service.analyzeContent(text: content, base64Images: nil)

            await MainActor.run {
                self.aiAnalysisResult = result
                self.isAnalyzing = false
                self.showingAIAnalysis = true
            }
        } catch {
            await MainActor.run {
                self.isAnalyzing = false
                self.aiErrorMessage = error.localizedDescription
                self.showingAIError = true
            }
        }
    }

    /// 应用 AI 分析结果到日记
    private func applyAIResult(_ result: AIAnalysisResult) {
        // 在保存时应用这些结果
        // 标签和总结会直接保存到日记
        // 待办、购物清单、日程会创建为关联对象

        // TODO: 在保存时应用 AI 结果
        print("Applied AI result: \(result.summary ?? "No summary")")
    }
}

/// 工具栏按钮组件 - Liquid Glass 风格
struct ToolbarButton: View {
    let systemIcon: String
    let label: String
    var isActive: Bool = false
    var activeColor: Color = .blue
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // 图标容器 - Liquid Glass 背景
                ZStack {
                    // Glass 背景
                    Circle()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // 激活状态的彩色边框
                    if isActive {
                        Circle()
                            .strokeBorder(activeColor.opacity(0.3), lineWidth: 2)
                    }
                    
                    // 激活状态的内发光
                    if isActive {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        activeColor.opacity(0.15),
                                        activeColor.opacity(0.05),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 20
                                )
                            )
                    }
                    
                    // 图标
                    Image(systemName: isActive ? systemIcon + ".fill" : systemIcon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(isActive ? activeColor : .secondary)
                }
                .frame(width: 50, height: 50)
            }
        }
        .buttonStyle(GlassButtonStyle(isPressed: $isPressed))
    }
}

/// Liquid Glass 按钮样式 - 弹性按压效果
struct GlassButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                isPressed = newValue
            }
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
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
