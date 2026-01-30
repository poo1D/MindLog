//
//  WeatherInfo.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import Foundation

/// 天气信息
struct WeatherInfo: Codable, Sendable {
    var condition: WeatherCondition
    var temperature: Double?
    var location: String?
    
    enum WeatherCondition: String, Codable, CaseIterable {
        case sunny = "☀️"
        case cloudy = "☁️"
        case rainy = "🌧️"
        case snowy = "❄️"
        case windy = "💨"
        case foggy = "🌫️"
        
        var description: String {
            switch self {
            case .sunny: return "晴天"
            case .cloudy: return "多云"
            case .rainy: return "下雨"
            case .snowy: return "下雪"
            case .windy: return "大风"
            case .foggy: return "雾天"
            }
        }
    }
}
