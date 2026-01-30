//
//  Attachment.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import Foundation
import SwiftData

/// 附件模型（图片、音频、视频）
@Model
final class Attachment {
    var id: UUID
    var type: AttachmentType
    var fileURL: URL  // 统一文件路径（存储在 Documents 目录）
    var createdAt: Date
    var metadata: AttachmentMetadata?
    
    init(id: UUID = UUID(), type: AttachmentType, fileURL: URL, createdAt: Date = Date(), metadata: AttachmentMetadata? = nil) {
        self.id = id
        self.type = type
        self.fileURL = fileURL
        self.createdAt = createdAt
        self.metadata = metadata
    }
}

/// 附件类型
enum AttachmentType: String, Codable {
    case image
    case audio
    case video
    
    var icon: String {
        switch self {
        case .image: return "photo"
        case .audio: return "mic.circle"
        case .video: return "video.circle"
        }
    }
}

/// 附件元数据
struct AttachmentMetadata: Codable {
    var fileName: String?
    var fileSize: Int64?  // 字节
    var duration: TimeInterval?  // 音频/视频时长
    var thumbnailURL: URL?  // 视频缩略图
}
