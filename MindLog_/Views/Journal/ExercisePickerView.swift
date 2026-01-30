//
//  ExercisePickerView.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import SwiftUI

/// 运动记录选择器
struct ExercisePickerView: View {
    @Binding var selectedExercise: ExerciseRecord?
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: ExerciseRecord.ExerciseType = .running
    @State private var duration: Double = 30 // 分钟
    @State private var distance: String = ""
    @State private var calories: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                // 运动类型选择
                Section("运动类型") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(ExerciseRecord.ExerciseType.allCases, id: \.self) { type in
                            ExerciseButton(
                                type: type,
                                isSelected: selectedType == type
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedType = type
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                
                // 时长
                Section("时长") {
                    VStack(spacing: 16) {
                        HStack {
                            Text("\(Int(duration))")
                                .font(.largeTitle)
                                .bold()
                                .foregroundStyle(.blue)
                            
                            Text("分钟")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        
                        Slider(value: $duration, in: 5...180, step: 5)
                            .tint(.blue)
                    }
                    .padding(.vertical, 8)
                }
                
                // 距离（可选）
                Section("距离（可选）") {
                    HStack {
                        TextField("例如：5", text: $distance)
                            .keyboardType(.decimalPad)
                        
                        Text("公里")
                            .foregroundColor(.secondary)
                    }
                }
                
                // 卡路里（可选）
                Section("消耗卡路里（可选）") {
                    HStack {
                        TextField("例如：200", text: $calories)
                            .keyboardType(.numberPad)
                        
                        Text("千卡")
                            .foregroundColor(.secondary)
                    }
                }
                
                // 备注（可选）
                Section("备注（可选）") {
                    TextField("添加备注...", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("记录运动")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        selectedExercise = ExerciseRecord(
                            type: selectedType,
                            duration: duration * 60, // 转换为秒
                            distance: Double(distance),
                            calories: Int(calories),
                            notes: notes.isEmpty ? nil : notes
                        )
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let exercise = selectedExercise {
                    selectedType = exercise.type
                    duration = exercise.duration / 60 // 转换为分钟
                    distance = exercise.distance.map { String($0) } ?? ""
                    calories = exercise.calories.map { String($0) } ?? ""
                    notes = exercise.notes ?? ""
                }
            }
        }
    }
}

/// 运动类型按钮
struct ExerciseButton: View {
    let type: ExerciseRecord.ExerciseType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(type.rawValue)
                    .font(.system(size: 28))
                
                Text(type.description)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var exercise: ExerciseRecord? = ExerciseRecord(type: .running, duration: 1800)
    
    ExercisePickerView(selectedExercise: $exercise)
}
