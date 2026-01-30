//
//  ContentView.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: 手帐
            JournalListView()
                .tabItem {
                    Label("手帐", systemImage: selectedTab == 0 ? "book.fill" : "book")
                }
                .tag(0)
            
            // Tab 2: AI 助手
            AIHomeView()
                .tabItem {
                    Label("Chat", systemImage: selectedTab == 1 ? "brain.head.profile.fill" : "brain.head.profile")
                }
                .tag(1)
            
            // Tab 3: 社区
            CommunityFeedView()
                .tabItem {
                    Label("社区", systemImage: selectedTab == 2 ? "person.3.fill" : "person.3")
                }
                .tag(2)
            
            // Tab 4: 我的
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: selectedTab == 3 ? "person.fill" : "person")
                }
                .tag(3)
        }
        .tint(.blue)  // TabView 选中颜色
    }
}

#Preview {
    ContentView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
