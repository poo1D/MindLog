//
//  ProfileView.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import SwiftUI
import SwiftData

/// 个人中心视图（Tab 4）
struct ProfileView: View {
    @Query private var entries: [JournalEntry]
    
    var body: some View {
        NavigationStack {
            List {
                // 用户信息
                Section {
                    HStack(spacing: 16) {
                        // 头像
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("登登")
                                .font(.title2)
                                .bold()
                            
                            Text("记录美好生活")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // 统计数据
                Section("统计") {
                    HStack {
                        StatItemView(
                            icon: "book.fill",
                            title: "日记数",
                            value: "\(entries.count)"
                        )
                        
                        Divider()
                        
                        StatItemView(
                            icon: "calendar",
                            title: "连续天数",
                            value: "\(calculateStreak())"
                        )
                        
                        Divider()
                        
                        StatItemView(
                            icon: "heart.fill",
                            title: "心情指数",
                            value: "😊"
                        )
                    }
                    .frame(height: 80)
                }
                
                // 设置选项
                Section("设置") {
                    NavigationLink {
                        Text("账户设置")
                    } label: {
                        Label("账户设置", systemImage: "person.circle")
                    }
                    
                    NavigationLink {
                        Text("隐私设置")
                    } label: {
                        Label("隐私设置", systemImage: "lock.shield")
                    }
                    
                    NavigationLink {
                        Text("通知设置")
                    } label: {
                        Label("通知设置", systemImage: "bell")
                    }
                    
                    NavigationLink {
                        Text("关于 MindLog")
                    } label: {
                        Label("关于", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("我的")
        }
    }
    
    private func calculateStreak() -> Int {
        // TODO: 实现连续天数计算
        return entries.count > 0 ? 7 : 0
    }
}

/// 统计项视图
struct StatItemView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            
            Text(value)
                .font(.title3)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
