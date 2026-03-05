//
//  JournalDetailView.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//  Updated: 2026/3/5 - 添加多媒体内容展示（图片画廊、音频播放器、视频播放器）
//

import SwiftUI

/// 日记详情视图
struct JournalDetailView: View {
    let entry: JournalEntry

    @State private var showingEditor = false
    @State private var selectedImageIndex: Int?

    // 按类型分类的附件
    private var imageAttachments: [Attachment] {
        entry.attachments?.filter { $0.type == .image } ?? []
    }

    private var audioAttachments: [Attachment] {
        entry.attachments?.filter { $0.type == .audio } ?? []
    }

    private var videoAttachments: [Attachment] {
        entry.attachments?.filter { $0.type == .video } ?? []
    }

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
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }

                // 正文内容
                if let content = entry.textContent {
                    Text(content)
                        .font(.body)
                        .lineSpacing(8)
                }

                // MARK: - 图片画廊
                if !imageAttachments.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("图片")
                            .font(.headline)

                        // 图片网格
                        LazyVGrid(
                            columns: gridColumns(for: imageAttachments.count),
                            spacing: 8
                        ) {
                            ForEach(Array(imageAttachments.enumerated()), id: \.element.id) { index, attachment in
                                if let image = ImageStorageService.shared.loadImage(from: attachment.fileURL) {
                                    Button {
                                        selectedImageIndex = index
                                    } label: {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(
                                                minWidth: 0, maxWidth: .infinity,
                                                minHeight: imageHeight(for: imageAttachments.count)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                    }
                }

                // MARK: - 音频播放
                if !audioAttachments.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("录音")
                            .font(.headline)

                        ForEach(audioAttachments) { attachment in
                            AudioPlayerView(
                                audioURL: attachment.fileURL,
                                fileName: attachment.metadata?.fileName
                            )
                        }
                    }
                }

                // MARK: - 视频播放
                if !videoAttachments.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("视频")
                            .font(.headline)

                        ForEach(videoAttachments) { attachment in
                            VideoPlayerView(
                                videoURL: attachment.fileURL,
                                thumbnailURL: attachment.metadata?.thumbnailURL
                            )
                        }
                    }
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
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }

                // AI 标签
                if let tags = entry.aiTags, !tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AI 标签")
                            .font(.headline)

                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .clipShape(.rect(cornerRadius: 16))
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
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
        // 图片全屏预览
        .fullScreenCover(item: $selectedImageIndex) { index in
            ImageFullScreenView(
                images: imageAttachments.compactMap {
                    ImageStorageService.shared.loadImage(from: $0.fileURL)
                },
                initialIndex: index
            )
        }
    }

    // MARK: - 辅助方法

    /// 根据图片数量确定网格列数
    private func gridColumns(for count: Int) -> [GridItem] {
        switch count {
        case 1:
            return [GridItem(.flexible())]
        case 2:
            return [GridItem(.flexible()), GridItem(.flexible())]
        default:
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        }
    }

    /// 根据图片数量确定高度
    private func imageHeight(for count: Int) -> CGFloat {
        switch count {
        case 1: return 240
        case 2: return 180
        default: return 120
        }
    }

    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - 让 Int 可用于 fullScreenCover 的 item 参数

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}

// MARK: - 图片全屏预览

struct ImageFullScreenView: View {
    let images: [UIImage]
    let initialIndex: Int

    @State private var currentIndex: Int = 0
    @State private var scale: CGFloat = 1.0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(images.indices, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .scaledToFit()
                        .tag(index)
                        .scaleEffect(scale)
                        .gesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    scale = value.magnification
                                }
                                .onEnded { _ in
                                    withAnimation {
                                        scale = 1.0
                                    }
                                }
                        )
                }
            }
            .tabViewStyle(.page(indexDisplayMode: images.count > 1 ? .always : .never))

            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.white.opacity(0.8))
                            .shadow(radius: 4)
                    }
                    .padding()
                }

                Spacer()

                // 页码指示
                if images.count > 1 {
                    Text("\(currentIndex + 1) / \(images.count)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            currentIndex = initialIndex
        }
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
