//
//  JournalRowView.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import SwiftUI

/// 日记行视图组件
struct JournalRowView: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题和心情
            HStack {
                Text(entry.title)
                    .font(.headline)
                
                Spacer()
                
                if let mood = entry.mood {
                    Text(mood.rawValue)
                        .font(.title3)
                }
            }
            
            // 内容预览
            if let content = entry.textContent {
                Text(content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // 底部信息
            HStack(spacing: 12) {
                // 日期
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text(entry.createdAt, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                // 附件数量
                if let attachments = entry.attachments, !attachments.isEmpty {
                    Label("\(attachments.count)", systemImage: "paperclip")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // AI 标签
                if let tags = entry.aiTags, !tags.isEmpty {
                    Label("\(tags.count)", systemImage: "tag")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        JournalRowView(
            entry: JournalEntry(
                title: "美好的一天",
                textContent: "今天天气很好，心情也很棒！去公园散步了，看到了很多美丽的花朵。",
                mood: .happy
            )
        )
        
        JournalRowView(
            entry: JournalEntry(
                title: "工作总结",
                textContent: "今天完成了项目的重要里程碑，团队很给力！",
                mood: .amazing
            )
        )
    }
}
