//
//  ExerciseRecord.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import Foundation

/// 运动记录
struct ExerciseRecord: Codable, Sendable {
    var type: ExerciseType
    var duration: TimeInterval  // 分钟
    var distance: Double?       // 公里
    var calories: Int?          // 卡路里
    var notes: String?
    
    enum ExerciseType: String, Codable, CaseIterable {
        case running = "🏃"
        case walking = "🚶"
        case cycling = "🚴"
        case swimming = "🏊"
        case workout = "💪"
        case yoga = "🧘"
        case other = "🏋️"
        
        var description: String {
            switch self {
            case .running: return "跑步"
            case .walking: return "步行"
            case .cycling: return "骑行"
            case .swimming: return "游泳"
            case .workout: return "健身"
            case .yoga: return "瑜伽"
            case .other: return "其他"
            }
        }
    }
}
