//
//  VideoPicker.swift
//  MindLog_
//
//  Created by AI Assistant on 2026/3/5.
//

import SwiftUI
import PhotosUI
import AVKit

/// 视频选择器 - 支持从相册选择或相机录制视频
struct VideoPicker: View {
    @Binding var selectedVideoURL: URL?
    @Environment(\.dismiss) private var dismiss

    @State private var selectedItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var isProcessing = false
    @State private var previewURL: URL?
    @State private var thumbnailImage: UIImage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 视频预览
                if let previewURL = previewURL {
                    ZStack {
                        // 缩略图
                        if let thumb = thumbnailImage {
                            Image(uiImage: thumb)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 240)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        // 播放按钮覆盖
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(radius: 8)
                    }
                    .padding(.horizontal, 20)
                    .onTapGesture {
                        // 播放预览可以在集成后实现
                    }

                    // 视频信息
                    HStack {
                        Image(systemName: "video.fill")
                            .foregroundColor(.blue)
                        Text("视频已选择")
                            .font(.subheadline)
                        Spacer()
                        Button("重新选择") {
                            self.previewURL = nil
                            self.thumbnailImage = nil
                        }
                        .font(.subheadline)
                    }
                    .padding(.horizontal, 20)

                    // 确认按钮
                    Button {
                        Task {
                            await processAndSave(previewURL)
                        }
                    } label: {
                        Text("确认添加")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue, in: RoundedRectangle(cornerRadius: 16))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .disabled(isProcessing)

                } else if isProcessing {
                    // 加载中
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("正在处理视频...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    Spacer()

                    // 选择方式
                    VStack(spacing: 16) {
                        // 从相册选择
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .videos,
                            photoLibrary: .shared()
                        ) {
                            Label("从相册选择视频", systemImage: "photo.on.rectangle")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .onChange(of: selectedItem) { _, newItem in
                            guard let newItem = newItem else { return }
                            Task {
                                isProcessing = true
                                if let url = try? await loadVideo(from: newItem) {
                                    await MainActor.run {
                                        previewURL = url
                                        thumbnailImage = VideoStorageService.shared.generateThumbnail(from: url)
                                        isProcessing = false
                                    }
                                } else {
                                    await MainActor.run {
                                        isProcessing = false
                                    }
                                }
                            }
                        }

                        // 相机录制
                        Button {
                            showingCamera = true
                        } label: {
                            Label("录制视频", systemImage: "video.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }

                        Text("最长 \(Int(VideoStorageService.shared.maxVideoDuration)) 秒")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .padding(.top, 20)
            .navigationTitle("添加视频")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                VideoRecorderView { url in
                    if let url = url {
                        previewURL = url
                        thumbnailImage = VideoStorageService.shared.generateThumbnail(from: url)
                    }
                }
                .ignoresSafeArea()
            }
        }
    }

    // MARK: - 辅助方法

    /// 从 PhotosPickerItem 加载视频
    private func loadVideo(from item: PhotosPickerItem) async throws -> URL? {
        // 尝试加载为 Movie 类型
        if let movieData = try await item.loadTransferable(type: VideoTransferable.self) {
            return movieData.url
        }
        return nil
    }

    /// 处理并保存视频
    private func processAndSave(_ url: URL) async {
        isProcessing = true
        do {
            let savedURL = try await VideoStorageService.shared.compressAndSave(from: url)
            await MainActor.run {
                selectedVideoURL = savedURL
                isProcessing = false
                dismiss()
            }
        } catch {
            await MainActor.run {
                // 如果压缩失败，尝试直接保存
                if let directURL = try? VideoStorageService.shared.saveVideo(from: url) {
                    selectedVideoURL = directURL
                }
                isProcessing = false
                dismiss()
            }
        }
    }
}

// MARK: - 视频传输类型

struct VideoTransferable: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mp4")
            try FileManager.default.copyItem(at: received.file, to: tempURL)
            return Self(url: tempURL)
        }
    }
}

// MARK: - 视频录制器（UIKit 桥接）

struct VideoRecorderView: UIViewControllerRepresentable {
    let onRecord: (URL?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.videoMaximumDuration = VideoStorageService.shared.maxVideoDuration
        picker.videoQuality = .typeMedium
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onRecord: onRecord)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onRecord: (URL?) -> Void

        init(onRecord: @escaping (URL?) -> Void) {
            self.onRecord = onRecord
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let url = info[.mediaURL] as? URL
            onRecord(url)
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onRecord(nil)
            picker.dismiss(animated: true)
        }
    }
}
