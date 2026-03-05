//
//  VideoPlayerView.swift
//  MindLog_
//
//  Created by AI Assistant on 2026/3/5.
//

import SwiftUI
import AVKit

/// 视频播放器视图 - 用于 JournalDetailView 中展示视频附件
struct VideoPlayerView: View {
    let videoURL: URL
    let thumbnailURL: URL?

    @State private var showingFullScreen = false
    @State private var thumbnailImage: UIImage?
    @State private var duration: String = ""

    var body: some View {
        Button {
            showingFullScreen = true
        } label: {
            ZStack {
                // 缩略图
                if let thumb = thumbnailImage {
                    Image(uiImage: thumb)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                }

                // 半透明遮罩
                RoundedRectangle(cornerRadius: 16)
                    .fill(.black.opacity(0.2))
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)

                // 播放按钮
                VStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(radius: 8)

                    if !duration.isEmpty {
                        Text(duration)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.black.opacity(0.5), in: Capsule())
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            loadThumbnail()
            loadDuration()
        }
        .fullScreenCover(isPresented: $showingFullScreen) {
            VideoFullScreenPlayer(url: videoURL)
        }
    }

    private func loadThumbnail() {
        // 先尝试从缩略图 URL 加载
        if let thumbURL = thumbnailURL,
           let image = ImageStorageService.shared.loadImage(from: thumbURL) {
            thumbnailImage = image
            return
        }
        // 否则实时生成
        thumbnailImage = VideoStorageService.shared.generateThumbnail(from: videoURL)
    }

    private func loadDuration() {
        Task {
            if let dur = await VideoStorageService.shared.getVideoDuration(url: videoURL) {
                await MainActor.run {
                    duration = AudioStorageService.formatDuration(dur)
                }
            }
        }
    }
}

// MARK: - 全屏视频播放器

struct VideoFullScreenPlayer: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            }

            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button {
                        player?.pause()
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
            }
        }
        .onAppear {
            player = AVPlayer(url: url)
            player?.play()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}
