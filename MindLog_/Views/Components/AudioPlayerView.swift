//
//  AudioPlayerView.swift
//  MindLog_
//
//  Created by AI Assistant on 2026/3/5.
//

import SwiftUI

/// 音频播放器视图 - Liquid Glass 风格
/// 用于 JournalDetailView 中展示和播放音频附件
struct AudioPlayerView: View {
    let audioURL: URL
    let fileName: String?

    @StateObject private var audioService = AudioStorageService.shared

    @State private var duration: TimeInterval = 0
    @State private var hasError = false

    var body: some View {
        HStack(spacing: 14) {
            // 播放/暂停按钮
            Button {
                togglePlayback()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: audioService.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.purple)
                }
            }

            // 波形 / 进度条
            VStack(alignment: .leading, spacing: 6) {
                // 文件名
                Text(fileName ?? "录音")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                // 进度条
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // 背景
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 4)

                        // 进度
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.purple)
                            .frame(width: geo.size.width * audioService.playbackProgress, height: 4)
                    }
                }
                .frame(height: 4)

                // 时长
                HStack {
                    Text(AudioStorageService.formatDuration(duration * audioService.playbackProgress))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .monospacedDigit()

                    Spacer()

                    Text(AudioStorageService.formatDuration(duration))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.purple.opacity(0.15), lineWidth: 1)
        )
        .onAppear {
            duration = audioService.getAudioDuration(url: audioURL) ?? 0
        }
        .onDisappear {
            audioService.stopPlayback()
        }
    }

    private func togglePlayback() {
        if audioService.isPlaying {
            audioService.pausePlayback()
        } else {
            do {
                try audioService.play(url: audioURL)
            } catch {
                hasError = true
            }
        }
    }
}
