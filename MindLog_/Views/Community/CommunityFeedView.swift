//
//  CommunityFeedView.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import SwiftUI

/// 社区广场视图（Tab 3）
struct CommunityFeedView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // 图标
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // 标题
                    Text("手帐社区")
                        .font(.title)
                        .bold()
                    
                    // 描述
                    Text("即将推出社区分享功能\n与更多手帐爱好者交流")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("社区")
        }
    }
}

#Preview {
    CommunityFeedView()
}
