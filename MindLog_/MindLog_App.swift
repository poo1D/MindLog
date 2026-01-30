//
//  MindLog_App.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import SwiftUI
import SwiftData

@main
struct MindLog_App: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    /// SwiftData 容器（仅本地存储）
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            JournalEntry.self,
            Attachment.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
