//
//  ImageStorageService.swift
//  MindLog_
//
//  Created by AI Assistant on 2026/3/5.
//

import Foundation
import UIKit
import SwiftUI

/// 图片存储服务 - 处理图片压缩、保存、读取和删除
final class ImageStorageService {

    static let shared = ImageStorageService()

    /// 图片压缩质量
    private let compressionQuality: CGFloat = AppConstants.AI.imageCompressionQuality

    /// 最大图片边长
    private let maxDimension: CGFloat = AppConstants.AI.maxImageDimension

    private init() {
        // 确保目录存在
        _ = AppConstants.imagesDirectory
    }

    // MARK: - 保存图片

    /// 保存 UIImage 到本地，返回文件 URL
    /// - Parameters:
    ///   - image: 要保存的图片
    ///   - fileName: 可选文件名，默认自动生成
    /// - Returns: 保存后的文件 URL
    func saveImage(_ image: UIImage, fileName: String? = nil) throws -> URL {
        // 压缩和调整尺寸
        let processedImage = resizeImageIfNeeded(image)

        guard let data = processedImage.jpegData(compressionQuality: compressionQuality) else {
            throw ImageStorageError.compressionFailed
        }

        let name = fileName ?? "\(UUID().uuidString).jpg"
        let fileURL = AppConstants.imagesDirectory.appendingPathComponent(name)

        try data.write(to: fileURL)
        return fileURL
    }

    /// 保存 Data 到本地
    func saveImageData(_ data: Data, fileName: String? = nil) throws -> URL {
        let name = fileName ?? "\(UUID().uuidString).jpg"
        let fileURL = AppConstants.imagesDirectory.appendingPathComponent(name)
        try data.write(to: fileURL)
        return fileURL
    }

    // MARK: - 读取图片

    /// 从 URL 加载图片
    func loadImage(from url: URL) -> UIImage? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    /// 从 URL 加载缩略图
    func loadThumbnail(from url: URL, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        guard let image = loadImage(from: url) else { return nil }
        return resizeImage(image, targetSize: size)
    }

    // MARK: - 转换为 Base64（用于 AI 分析）

    /// 将图片转为 Base64 字符串
    func imageToBase64(_ image: UIImage, maxDimension: CGFloat? = nil) -> String? {
        let dim = maxDimension ?? self.maxDimension
        let resized = resizeImage(image, maxDimension: dim)
        return resized.jpegData(compressionQuality: compressionQuality)?.base64EncodedString()
    }

    /// 从文件 URL 读取图片并转为 Base64
    func urlToBase64(_ url: URL) -> String? {
        guard let image = loadImage(from: url) else { return nil }
        return imageToBase64(image)
    }

    // MARK: - 删除图片

    /// 删除指定 URL 的图片
    func deleteImage(at url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        try FileManager.default.removeItem(at: url)
    }

    // MARK: - 获取文件信息

    /// 获取文件大小（字节）
    func fileSize(at url: URL) -> Int64? {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attrs[.size] as? Int64 else { return nil }
        return size
    }

    // MARK: - 图片处理工具

    /// 如果图片超过最大尺寸，进行缩放
    private func resizeImageIfNeeded(_ image: UIImage) -> UIImage {
        let maxSide = max(image.size.width, image.size.height)
        if maxSide <= maxDimension { return image }
        return resizeImage(image, maxDimension: maxDimension)
    }

    /// 按最大边长缩放图片
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let maxSide = max(image.size.width, image.size.height)
        if maxSide <= maxDimension { return image }

        let scale = maxDimension / maxSide
        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        return resizeImage(image, targetSize: newSize)
    }

    /// 按目标尺寸缩放图片
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

// MARK: - 错误类型

enum ImageStorageError: Error, LocalizedError {
    case compressionFailed
    case saveFailed
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .compressionFailed: return "图片压缩失败"
        case .saveFailed: return "图片保存失败"
        case .fileNotFound: return "图片文件未找到"
        }
    }
}
