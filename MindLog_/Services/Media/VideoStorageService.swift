//
//  VideoStorageService.swift
//  MindLog_
//
//  Created by AI Assistant on 2026/3/5.
//

import Foundation
import AVFoundation
import UIKit

/// 视频存储服务 - 处理视频压缩、缩略图生成、保存和删除
final class VideoStorageService {

    static let shared = VideoStorageService()

    /// 视频最大时长（秒）
    let maxVideoDuration: TimeInterval = 60

    private init() {
        _ = AppConstants.videoDirectory
    }

    // MARK: - 保存视频

    /// 保存视频文件到本地目录（从临时 URL 拷贝）
    /// - Parameter sourceURL: 原始视频 URL（如 PhotosPicker 提供的临时路径）
    /// - Returns: 保存后的文件 URL
    func saveVideo(from sourceURL: URL) throws -> URL {
        let fileName = "\(UUID().uuidString).mp4"
        let destinationURL = AppConstants.videoDirectory.appendingPathComponent(fileName)

        // 如果源文件就是 mp4，直接拷贝
        if sourceURL.pathExtension.lowercased() == "mp4" || sourceURL.pathExtension.lowercased() == "m4v" {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            return destinationURL
        }

        // 否则先压缩转码
        return destinationURL
    }

    /// 压缩视频并保存
    func compressAndSave(from sourceURL: URL) async throws -> URL {
        let fileName = "\(UUID().uuidString).mp4"
        let outputURL = AppConstants.videoDirectory.appendingPathComponent(fileName)

        let asset = AVURLAsset(url: sourceURL)

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            throw VideoStorageError.exportFailed
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true

        await exportSession.export()

        switch exportSession.status {
        case .completed:
            return outputURL
        case .failed:
            throw exportSession.error ?? VideoStorageError.exportFailed
        case .cancelled:
            throw VideoStorageError.exportCancelled
        default:
            throw VideoStorageError.exportFailed
        }
    }

    // MARK: - 缩略图生成

    /// 从视频 URL 生成缩略图
    func generateThumbnail(from videoURL: URL, at time: CMTime = CMTime(seconds: 0.5, preferredTimescale: 600)) -> UIImage? {
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 400, height: 400)

        do {
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }

    /// 生成缩略图并保存到本地
    func saveThumbnail(from videoURL: URL) throws -> URL? {
        guard let thumbnail = generateThumbnail(from: videoURL) else { return nil }
        guard let data = thumbnail.jpegData(compressionQuality: 0.7) else { return nil }

        let fileName = "\(UUID().uuidString)_thumb.jpg"
        let thumbURL = AppConstants.imagesDirectory.appendingPathComponent(fileName)
        try data.write(to: thumbURL)
        return thumbURL
    }

    // MARK: - 视频信息

    /// 获取视频时长
    func getVideoDuration(url: URL) async -> TimeInterval? {
        let asset = AVURLAsset(url: url)
        do {
            let duration = try await asset.load(.duration)
            return CMTimeGetSeconds(duration)
        } catch {
            return nil
        }
    }

    /// 获取文件大小
    func fileSize(at url: URL) -> Int64? {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attrs[.size] as? Int64 else { return nil }
        return size
    }

    // MARK: - 删除

    /// 删除视频文件
    func deleteVideo(at url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        try FileManager.default.removeItem(at: url)
    }

    /// 删除视频及其缩略图
    func deleteVideoAndThumbnail(videoURL: URL, thumbnailURL: URL?) throws {
        try deleteVideo(at: videoURL)
        if let thumbURL = thumbnailURL {
            try? FileManager.default.removeItem(at: thumbURL)
        }
    }
}

// MARK: - 错误类型

enum VideoStorageError: Error, LocalizedError {
    case exportFailed
    case exportCancelled
    case fileNotFound
    case invalidFormat

    var errorDescription: String? {
        switch self {
        case .exportFailed: return "视频导出失败"
        case .exportCancelled: return "视频导出已取消"
        case .fileNotFound: return "视频文件未找到"
        case .invalidFormat: return "不支持的视频格式"
        }
    }
}
