//
//  PomodoroState.swift
//  NotchIsland
//
//  番茄钟数据模型
//

import Foundation

/// 番茄钟状态
enum PomodoroPhase: String, Codable {
    case idle           // 未开始/空闲
    case focus          // 专注中
    case shortBreak     // 短休息
    case longBreak      // 长休息
}

/// 番茄钟配置
struct PomodoroConfig: Codable {
    var focusDuration: TimeInterval = 10               // 专注时长（10 秒，测试用）
    var shortBreakDuration: TimeInterval = 5           // 短休息时长（5 秒，测试用）
    var longBreakDuration: TimeInterval = 10           // 长休息时长（10 秒，测试用）
    var longBreakInterval: Int = 4                     // 长休息间隔（默认每 4 个番茄钟）
    var autoStartBreaks: Bool = false                  // 自动开始休息
    var autoStartPomodoros: Bool = false               // 自动开始下一个番茄钟
    
    init() {}
}

/// 番茄钟会话数据
struct PomodoroSession: Identifiable {
    let id: UUID
    var phase: PomodoroPhase
    var startTime: Date?
    var endTime: Date?
    var remainingTime: TimeInterval        // 剩余时间（秒）
    var totalTime: TimeInterval            // 总时间（秒）
    var completedPomodoros: Int            // 已完成的番茄钟数量
    
    init(
        id: UUID = UUID(),
        phase: PomodoroPhase = .idle,
        startTime: Date? = nil,
        endTime: Date? = nil,
        remainingTime: TimeInterval = 0,
        totalTime: TimeInterval = 0,
        completedPomodoros: Int = 0
    ) {
        self.id = id
        self.phase = phase
        self.startTime = startTime
        self.endTime = endTime
        self.remainingTime = remainingTime
        self.totalTime = totalTime
        self.completedPomodoros = completedPomodoros
    }
}

// MARK: - 扩展方法
extension PomodoroSession {
    /// 是否正在运行
    var isRunning: Bool {
        phase != .idle && startTime != nil && endTime == nil
    }
    
    /// 进度百分比（0-1）
    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return 1.0 - (remainingTime / totalTime)
    }
    
    /// 格式化剩余时间（MM:SS）
    var formattedRemainingTime: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension PomodoroPhase {
    /// 显示名称
    var displayName: String {
        switch self {
        case .idle:
            return "空闲"
        case .focus:
            return "专注中"
        case .shortBreak:
            return "短休息"
        case .longBreak:
            return "长休息"
        }
    }
    
    /// 图标
    var icon: String {
        switch self {
        case .idle:
            return "pause.circle"
        case .focus:
            return "brain.head.profile"
        case .shortBreak, .longBreak:
            return "cup.and.saucer"
        }
    }
}
