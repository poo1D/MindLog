//
//  TodoItem.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import Foundation

/// 待办事项
struct TodoItem: Codable, Identifiable, Sendable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
    var priority: Priority = .medium
    
    enum Priority: String, Codable {
        case low = "低"
        case medium = "中"
        case high = "高"
    }
}
