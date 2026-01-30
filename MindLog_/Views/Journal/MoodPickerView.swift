//
//  MoodPickerView.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import SwiftUI

/// 心情选择器
struct MoodPickerView: View {
    @Binding var selectedMood: MoodType?
    @Environment(\.dismiss) private var dismiss
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(MoodType.allCases, id: \.self) { mood in
                        MoodButton(
                            mood: mood,
                            isSelected: selectedMood == mood
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedMood = mood
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("选择心情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("清除") {
                        withAnimation {
                            selectedMood = nil
                        }
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}

/// 心情按钮组件
struct MoodButton: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Emoji
                Text(mood.rawValue)
                    .font(.system(size: 50))
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                
                // 描述
                Text(mood.description)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? mood.color : .secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? mood.color.opacity(0.1) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? mood.color : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? mood.color.opacity(0.3) : Color.black.opacity(0.05), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var selectedMood: MoodType? = .happy
    
    MoodPickerView(selectedMood: $selectedMood)
}
