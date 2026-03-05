//
//  AudioStorageService.swift
//  MindLog_
//
//  Created by AI Assistant on 2026/3/5.
//

import Foundation
import AVFoundation

/// 音频存储服务 - 处理音频录制、保存、播放和删除
@MainActor
final class AudioStorageService: NSObject, ObservableObject {

    static let shared = AudioStorageService()

    // MARK: - 录音状态

    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var audioLevel: Float = 0  // 音频电平 (0-1)

    // MARK: - 播放状态

    @Published var isPlaying = false
    @Published var playbackProgress: Double = 0
    @Published var playbackDuration: TimeInterval = 0

    // MARK: - 私有属性

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingURL: URL?
    private var recordingTimer: Timer?
    private var levelTimer: Timer?
    private var playbackTimer: Timer?

    private override init() {
        super.init()
        _ = AppConstants.audioDirectory
    }

    // MARK: - 权限管理

    /// 请求麦克风权限
    func requestPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    /// 检查是否有麦克风权限
    var hasPermission: Bool {
        AVAudioApplication.shared.recordPermission == .granted
    }

    // MARK: - 录音功能

    /// 开始录音
    func startRecording() throws {
        // 配置音频会话
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)

        // 生成文件名
        let fileName = "\(UUID().uuidString).m4a"
        let url = AppConstants.audioDirectory.appendingPathComponent(fileName)
        recordingURL = url

        // 录音设置
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        // 创建录音器
        audioRecorder = try AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.record()

        isRecording = true
        recordingDuration = 0

        // 更新计时器
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.recordingDuration = self.audioRecorder?.currentTime ?? 0
            }
        }

        // 音频电平检测
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, let recorder = self.audioRecorder else { return }
                recorder.updateMeters()
                let level = recorder.averagePower(forChannel: 0)
                // 将 dB 值 (-160 ~ 0) 映射到 0 ~ 1
                let normalizedLevel = max(0, (level + 50) / 50)
                self.audioLevel = normalizedLevel
            }
        }
    }

    /// 停止录音，返回文件 URL
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false

        recordingTimer?.invalidate()
        recordingTimer = nil
        levelTimer?.invalidate()
        levelTimer = nil

        audioLevel = 0

        // 重置音频会话
        try? AVAudioSession.sharedInstance().setActive(false)

        return recordingURL
    }

    /// 取消录音（删除临时文件）
    func cancelRecording() {
        let url = stopRecording()
        if let url = url {
            try? FileManager.default.removeItem(at: url)
        }
        recordingDuration = 0
    }

    // MARK: - 播放功能

    /// 播放音频
    func play(url: URL) throws {
        stopPlayback()

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)

        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.delegate = self
        audioPlayer?.play()

        isPlaying = true
        playbackDuration = audioPlayer?.duration ?? 0

        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, let player = self.audioPlayer else { return }
                self.playbackProgress = player.currentTime / max(player.duration, 1)
            }
        }
    }

    /// 暂停播放
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
    }

    /// 恢复播放
    func resumePlayback() {
        audioPlayer?.play()
        isPlaying = true
    }

    /// 停止播放
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        playbackProgress = 0

        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    /// 跳转到指定进度
    func seek(to progress: Double) {
        guard let player = audioPlayer else { return }
        player.currentTime = progress * player.duration
        playbackProgress = progress
    }

    // MARK: - 文件管理

    /// 获取音频时长
    func getAudioDuration(url: URL) -> TimeInterval? {
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        return player.duration
    }

    /// 获取文件大小
    func fileSize(at url: URL) -> Int64? {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attrs[.size] as? Int64 else { return nil }
        return size
    }

    /// 删除音频文件
    func deleteAudio(at url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        try FileManager.default.removeItem(at: url)
    }

    /// 格式化时长显示
    static func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioStorageService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
            self.playbackProgress = 0
            self.playbackTimer?.invalidate()
            self.playbackTimer = nil
        }
    }
}
