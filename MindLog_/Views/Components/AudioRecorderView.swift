//
//  AudioRecorderView.swift
//  MindLog_
//
//  Created by AI Assistant on 2026/3/5.
//

import SwiftUI

/// 音频录制视图 - Liquid Glass 风格
struct AudioRecorderView: View {
    @Binding var recordedAudioURL: URL?
    @StateObject private var audioService = AudioStorageService.shared
    @Environment(\.dismiss) private var dismiss

    @State private var permissionDenied = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // 录音波形动画
                ZStack {
                    // 外圈脉冲
                    if audioService.isRecording {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 200 + CGFloat(audioService.audioLevel) * 60,
                                   height: 200 + CGFloat(audioService.audioLevel) * 60)
                            .animation(.easeOut(duration: 0.1), value: audioService.audioLevel)
                    }

                    // 中圈
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 160, height: 160)
                        .shadow(color: .black.opacity(0.1), radius: 12, y: 4)

                    // 内圈 - 录音状态指示
                    Circle()
                        .fill(audioService.isRecording ?
                              Color.red.opacity(0.2) : Color.secondary.opacity(0.1))
                        .frame(width: 140, height: 140)

                    // 波形条
                    if audioService.isRecording {
                        HStack(spacing: 4) {
                            ForEach(0..<7, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.red)
                                    .frame(width: 4, height: barHeight(for: i))
                                    .animation(
                                        .easeInOut(duration: 0.15)
                                            .delay(Double(i) * 0.02),
                                        value: audioService.audioLevel
                                    )
                            }
                        }
                    } else {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                    }
                }

                // 录音时长
                Text(AudioStorageService.formatDuration(audioService.recordingDuration))
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundColor(audioService.isRecording ? .red : .primary)

                // 提示文字
                Text(audioService.isRecording ? "正在录音..." : "点击开始录音")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                // 控制按钮区域
                HStack(spacing: 40) {
                    if audioService.isRecording {
                        // 取消按钮
                        Button {
                            audioService.cancelRecording()
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(.secondary)
                                Text("取消")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        // 停止按钮
                        Button {
                            if let url = audioService.stopRecording() {
                                recordedAudioURL = url
                                dismiss()
                            }
                        } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 64, height: 64)

                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(.white)
                                        .frame(width: 24, height: 24)
                                }
                                Text("完成")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    } else {
                        // 开始录音按钮
                        Button {
                            startRecording()
                        } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 72, height: 72)

                                    Circle()
                                        .fill(.white)
                                        .frame(width: 28, height: 28)
                                }
                                Text("录音")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("录制音频")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        if audioService.isRecording {
                            audioService.cancelRecording()
                        }
                        dismiss()
                    }
                }
            }
            .alert("需要麦克风权限", isPresented: $permissionDenied) {
                Button("去设置") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("取消", role: .cancel) { dismiss() }
            } message: {
                Text("请在设置中允许 MindLog 使用麦克风来录制音频")
            }
            .alert("录音错误", isPresented: $showError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - 辅助方法

    private func startRecording() {
        Task {
            let granted = await audioService.requestPermission()
            if granted {
                do {
                    try audioService.startRecording()
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            } else {
                permissionDenied = true
            }
        }
    }

    /// 计算波形条高度
    private func barHeight(for index: Int) -> CGFloat {
        let base: CGFloat = 10
        let level = CGFloat(audioService.audioLevel)
        let variation = sin(Double(index) * 1.5) * 0.3 + 0.7
        return base + level * 50 * CGFloat(variation)
    }
}
