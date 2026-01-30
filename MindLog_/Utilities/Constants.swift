//
//  Constants.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import Foundation
import SwiftUI

/// 应用常量
struct AppConstants {
    
    // MARK: - API 配置
    
    /// Gemini API Key（请替换为你自己的 API Key）
    static let geminiAPIKey = "YOUR_GEMINI_API_KEY_HERE"
    
    // MARK: - 设计规范
    
    /// 圆角半径
    struct CornerRadius {
        static let large: CGFloat = 32
        static let medium: CGFloat = 20
        static let small: CGFloat = 12
    }
    
    /// 间距
    struct Spacing {
        static let extraLarge: CGFloat = 32
        static let large: CGFloat = 24
        static let medium: CGFloat = 16
        static let small: CGFloat = 8
        static let extraSmall: CGFloat = 4
    }
    
    /// 主题颜色
    struct Theme {
        static let primary = Color.blue
        static let accent = Color.purple
        static let success = Color.green
        static let warning = Color.orange
        static let danger = Color.red
    }
    
    // MARK: - 文件存储
    
    /// Documents 目录路径
    static let documentsDirectory: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()
    
    /// 图片存储目录
    static let imagesDirectory: URL = {
        let url = documentsDirectory.appendingPathComponent("images", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()
    
    /// 音频存储目录
    static let audioDirectory: URL = {
        let url = documentsDirectory.appendingPathComponent("audio", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()
    
    /// 视频存储目录
    static let videoDirectory: URL = {
        let url = documentsDirectory.appendingPathComponent("video", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()
}
