//
//  MoodType.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import Foundation
import SwiftUI

/// 心情类型枚举
enum MoodType: String, Codable, CaseIterable, Sendable {
    case amazing = "😄"
    case happy = "🙂"
    case neutral = "😐"
    case sad = "😢"
    case angry = "😠"
    case anxious = "😰"
    case grateful = "🙏"
    case tired = "😴"
    
    /// 心情对应的颜色
    var color: Color {
        switch self {
        case .amazing:
            return .yellow
        case .happy:
            return .green
        case .neutral:
            return .gray
        case .sad:
            return .blue
        case .angry:
            return .red
        case .anxious:
            return .orange
        case .grateful:
            return .pink
        case .tired:
            return .purple
        }
    }
    
    /// 心情的文字描述
    var description: String {
        switch self {
        case .amazing:
            return "太棒了"
        case .happy:
            return "开心"
        case .neutral:
            return "平静"
        case .sad:
            return "难过"
        case .angry:
            return "愤怒"
        case .anxious:
            return "焦虑"
        case .grateful:
            return "感恩"
        case .tired:
            return "疲惫"
        }
    }
}
