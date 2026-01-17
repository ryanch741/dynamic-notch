//
//  PomodoroView.swift
//  NotchIsland
//
//  番茄钟视图（用于刘海条展开区域）
//

import SwiftUI

struct PomodoroView: View {
    @ObservedObject var service = PomodoroService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 标题
            HStack {
                Text(LocalizedStringKey("番茄钟"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
                
                Spacer()
                
                // 状态图标
                Image(systemName: service.session.phase.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .frame(height: 20)
            
            // 主内容
            HStack(spacing: 16) {
                // 左侧：计时器显示
                VStack(spacing: 2) {
                    // 剩余时间
                    Text(service.session.formattedRemainingTime)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                    
                    // 状态文字
                    Text(service.session.phase.displayName)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    
                    // 进度条
                    ProgressView(value: service.session.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white.opacity(0.7)))
                        .frame(width: 100, height: 4)
                        .padding(.top, 2)
                }
                .frame(minWidth: 120)
                
                Divider()
                    .frame(height: 50)
                    .background(Color.white.opacity(0.2))
                
                // 右侧：控制按钮
                HStack(spacing: 10) {
                    // 开始/暂停按钮
                    if service.session.phase == .idle {
                        // 空闲状态：显示开始按钮
                        VStack(spacing: 2) {
                            Button(action: {
                                service.startFocus()
                            }) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 52))
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.white.opacity(0.8))
                            .help(LocalizedStringKey("开始专注"))
                            
                            Text(LocalizedStringKey("开始"))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    } else if service.isPaused {
                        // 暂停状态：显示继续按钮
                        VStack(spacing: 2) {
                            Button(action: {
                                service.resume()
                            }) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 52))
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.white.opacity(0.8))
                            .help(LocalizedStringKey("继续"))
                            
                            Text(LocalizedStringKey("继续"))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    } else {
                        // 运行中：显示暂停按钮
                        VStack(spacing: 2) {
                            Button(action: {
                                service.pause()
                            }) {
                                Image(systemName: "pause.circle.fill")
                                    .font(.system(size: 52))
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.white.opacity(0.8))
                            .help(LocalizedStringKey("暂停"))
                            
                            Text(LocalizedStringKey("暂停"))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    
                    // 跳过按钮
                    if service.session.phase != .idle {
                        VStack(spacing: 2) {
                            Button(action: {
                                service.skip()
                            }) {
                                Image(systemName: "forward.end.circle.fill")
                                    .font(.system(size: 52))
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.white.opacity(0.6))
                            .help(LocalizedStringKey("跳过"))
                            
                            Text(LocalizedStringKey("跳过"))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    
                    // 停止按钮
                    if service.session.phase != .idle {
                        VStack(spacing: 2) {
                            Button(action: {
                                service.stop()
                            }) {
                                Image(systemName: "stop.circle.fill")
                                    .font(.system(size: 52))
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.white.opacity(0.6))
                            .help(LocalizedStringKey("停止"))
                            
                            Text(LocalizedStringKey("停止"))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            .frame(height: 80)
            
            // 统计信息
            HStack {
                Text(String(format: NSLocalizedString("已完成 %lld 个番茄钟", comment: ""), service.session.completedPomodoros))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 20)
        }
    }
}

#Preview {
    PomodoroView()
        .frame(width: 600, height: 120)
        .background(Color.black)
}
