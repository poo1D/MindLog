//
//  JournalListView.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import SwiftUI
import SwiftData

/// 手帐列表视图（Tab 1）
struct JournalListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]
    
    @State private var showingEditor = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if entries.isEmpty {
                    // 空状态
                    ContentUnavailableView(
                        "还没有日记",
                        systemImage: "book.closed",
                        description: Text("点击右上角 + 创建你的第一篇日记")
                    )
                } else {
                    // 日记列表
                    List {
                        ForEach(entries) { entry in
                            NavigationLink {
                                JournalDetailView(entry: entry)
                            } label: {
                                JournalRowView(entry: entry)
                            }
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("手帐")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingEditor = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                JournalEditorView(entry: nil)
            }
        }
    }
    
    private func deleteEntries(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(entries[index])
            }
        }
    }
}

#Preview {
    JournalListView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
