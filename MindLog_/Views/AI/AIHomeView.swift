//
//  AIHomeView.swift
//  MindLog_
//
//  Created by Siegfried on 2026/1/29.
//

import SwiftUI

/// AI 助手主页（ChatGPT 语音球风格 - 黑白配色）
struct AIHomeView: View {
    @State private var isListening = false
    @State private var audioLevel: CGFloat = 0.0
    @State private var pulseAnimation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Liquid Glass 背景
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // 中心语音球
                    VoiceOrbView(
                        isListening: $isListening,
                        audioLevel: $audioLevel,
                        pulseAnimation: $pulseAnimation
                    )
                    .padding(.vertical, 80)
                    
                    Spacer()
                    
                    // 底部语音输入按钮
                    VoiceInputButton(isListening: $isListening)
                        .onTapGesture {
                            toggleListening()
                        }
                        .padding(.bottom, 60)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func toggleListening() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isListening.toggle()
        }
        
        if isListening {
            startListening()
        } else {
            stopListening()
        }
    }
    
    private func startListening() {
        // TODO: 启动语音识别
        // 模拟音频波动
        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
    }
    
    private func stopListening() {
        // TODO: 停止语音识别
        pulseAnimation = false
        audioLevel = 0.0
    }
}

/// 语音球组件（黑白配色）
struct VoiceOrbView: View {
    @Binding var isListening: Bool
    @Binding var audioLevel: CGFloat
    @Binding var pulseAnimation: Bool
    
    var body: some View {
        ZStack {
            // 外层光晕（最大）
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            isListening ? Color.primary.opacity(0.12) : Color.primary.opacity(0.04),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseAnimation)
            
            // 中层光晕
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            isListening ? Color.primary.opacity(0.18) : Color.primary.opacity(0.06),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 40,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .scaleEffect(pulseAnimation ? 1.15 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
            
            // 主圆球（Liquid Glass）
            ZStack {
                // 毛玻璃背景
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 200, height: 200)
                
                // 黑白渐变层
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                isListening ? Color.primary.opacity(0.5) : Color.primary.opacity(0.15),
                                isListening ? Color.primary.opacity(0.3) : Color.primary.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: isListening ? 10 : 5)
                
                // 边框
                Circle()
                    .strokeBorder(
                        Color.primary.opacity(isListening ? 0.4 : 0.2),
                        lineWidth: 2
                    )
                    .frame(width: 200, height: 200)
                
                // 内部图标
                if !isListening {
                    Image(systemName: "waveform")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.primary.opacity(0.6))
                }
            }
            .scaleEffect(isListening ? 1.1 : 1.0)
            .shadow(color: .primary.opacity(isListening ? 0.15 : 0), radius: 20)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isListening)
        }
    }
}

/// 语音输入按钮（黑白配色）
struct VoiceInputButton: View {
    @Binding var isListening: Bool
    
    var body: some View {
        ZStack {
            // 主按钮
            Circle()
                .fill(Color.primary.opacity(isListening ? 0.9 : 0.8))
                .frame(width: 60, height: 60)
            
            // 图标
            Image(systemName: isListening ? "stop.fill" : "mic.fill")
                .font(.system(size: 28))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white.opacity(0.95), .white.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .shadow(
            color: .primary.opacity(isListening ? 0.25 : 0.15),
            radius: 15,
            y: 5
        )
        .scaleEffect(isListening ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isListening)
    }
}

#Preview("静止状态") {
    AIHomeView()
}

#Preview("聆听状态") {
    struct PreviewWrapper: View {
        @State private var isListening = true
        @State private var audioLevel: CGFloat = 0.5
        @State private var pulseAnimation = true
        
        var body: some View {
            AIHomeView()
        }
    }
    
    return PreviewWrapper()
}
