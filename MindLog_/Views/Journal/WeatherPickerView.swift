//
//  WeatherPickerView.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import SwiftUI

/// 天气选择器
struct WeatherPickerView: View {
    @Binding var selectedWeather: WeatherInfo?
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCondition: WeatherInfo.WeatherCondition = .sunny
    @State private var temperature: Double = 20
    @State private var location: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                // 天气状况选择
                Section("天气状况") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        ForEach(WeatherInfo.WeatherCondition.allCases, id: \.self) { condition in
                            WeatherButton(
                                condition: condition,
                                isSelected: selectedCondition == condition
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedCondition = condition
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                
                // 温度
                Section("温度") {
                    VStack(spacing: 16) {
                        HStack {
                            Text("\(Int(temperature))°C")
                                .font(.largeTitle)
                                .bold()
                                .foregroundStyle(temperatureColor)
                            
                            Spacer()
                        }
                        
                        Slider(value: $temperature, in: -20...45, step: 1)
                            .tint(temperatureColor)
                    }
                    .padding(.vertical, 8)
                }
                
                // 位置（可选）
                Section("位置（可选）") {
                    TextField("例如：北京", text: $location)
                }
            }
            .navigationTitle("选择天气")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        selectedWeather = WeatherInfo(
                            condition: selectedCondition,
                            temperature: temperature,
                            location: location.isEmpty ? nil : location
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
                if let weather = selectedWeather {
                    selectedCondition = weather.condition
                    temperature = weather.temperature ?? 20
                    location = weather.location ?? ""
                }
            }
        }
    }
    
    private var temperatureColor: Color {
        switch temperature {
        case ..<0:
            return .blue
        case 0..<15:
            return .cyan
        case 15..<25:
            return .green
        case 25..<35:
            return .orange
        default:
            return .red
        }
    }
}

/// 天气按钮组件
struct WeatherButton: View {
    let condition: WeatherInfo.WeatherCondition
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(condition.rawValue)
                    .font(.system(size: 40))
                
                Text(condition.description)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var weather: WeatherInfo? = WeatherInfo(condition: .sunny, temperature: 25)
    
    WeatherPickerView(selectedWeather: $weather)
}
