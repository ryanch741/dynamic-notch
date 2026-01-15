//
//  PomodoroService.swift
//  NotchIsland
//
//  番茄钟服务（管理计时、状态切换、通知）
//

import Foundation
import Combine
import UserNotifications

/// 番茄钟服务
class PomodoroService: ObservableObject {
    static let shared = PomodoroService()
    
    @Published var session: PomodoroSession
    @Published var config: PomodoroConfig
    @Published var isPaused: Bool = false  // 暂停状态标记
    
    private var timer: Timer?
    private let userDefaultsKey = "notch_island_pomodoro_config"
    
    private init() {
        self.session = PomodoroSession()
        self.config = PomodoroConfig()
        loadConfig()
    }
    
    // MARK: - 计时控制
    
    /// 开始专注
    func startFocus() {
        startPhase(.focus, duration: config.focusDuration)
    }
    
    /// 开始短休息
    func startShortBreak() {
        startPhase(.shortBreak, duration: config.shortBreakDuration)
    }
    
    /// 开始长休息
    func startLongBreak() {
        startPhase(.longBreak, duration: config.longBreakDuration)
    }
    
    /// 开始指定阶段
    private func startPhase(_ phase: PomodoroPhase, duration: TimeInterval) {
        stopTimer()
        
        session.phase = phase
        session.startTime = Date()
        session.endTime = nil
        session.remainingTime = duration
        session.totalTime = duration
        
        startTimer()
    }
    
    /// 暂停
    func pause() {
        isPaused = true
        stopTimer()
    }
    
    /// 恢复
    func resume() {
        guard isPaused, session.phase != .idle else { return }
        isPaused = false
        startTimer()
    }
    
    /// 停止
    func stop() {
        stopTimer()
        isPaused = false
        session = PomodoroSession()
    }
    
    /// 跳过当前阶段
    func skip() {
        stopTimer()
        handlePhaseComplete()
    }
    
    // MARK: - 定时器管理
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func tick() {
        guard session.remainingTime > 0 else {
            handlePhaseComplete()
            return
        }
        
        session.remainingTime -= 1
    }
    
    // MARK: - 阶段切换
    
    private func handlePhaseComplete() {
        stopTimer()
        
        let completedPhase = session.phase
        session.endTime = Date()
        
        // 发送通知
        sendNotification(for: completedPhase)
        
        // 根据配置自动切换到下一阶段
        switch completedPhase {
        case .focus:
            session.completedPomodoros += 1
            
            // 判断是短休息还是长休息
            let isLongBreak = session.completedPomodoros % config.longBreakInterval == 0
            
            if config.autoStartBreaks {
                if isLongBreak {
                    startLongBreak()
                } else {
                    startShortBreak()
                }
            } else {
                session.phase = .idle
            }
            
        case .shortBreak, .longBreak:
            if config.autoStartPomodoros {
                startFocus()
            } else {
                session.phase = .idle
            }
            
        case .idle:
            break
        }
    }
    
    // MARK: - 通知
    
    private func sendNotification(for phase: PomodoroPhase) {
        let title: String
        let message: String
        
        switch phase {
        case .focus:
            let minutes = Int(config.focusDuration / 60)
            title = "🎉 番茄钟完成！"
            message = "您已经连续工作 \(minutes) 分钟，\n让眼睛休息一下吧 👀"
        case .shortBreak:
            let minutes = Int(config.shortBreakDuration / 60)
            title = "⏰ 休息结束"
            message = "已休息 \(minutes) 分钟，\n准备好开始下一个番茄钟了吗？💪"
        case .longBreak:
            let minutes = Int(config.longBreakDuration / 60)
            title = "✨ 长休息结束"
            message = "已休息 \(minutes) 分钟，\n精力充沛，继续加油！🔥"
        case .idle:
            return
        }
        
        // 发送应用内通知（显示在刘海容器中）
        NotificationManager.shared.show(title: title, message: message)
    }
    
    // MARK: - 配置管理
    
    /// 更新配置
    func updateConfig(_ newConfig: PomodoroConfig) {
        config = newConfig
        saveConfig()
    }
    
    /// 加载配置
    private func loadConfig() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        do {
            config = try JSONDecoder().decode(PomodoroConfig.self, from: data)
        } catch {
            print("加载番茄钟配置失败: \(error)")
        }
    }
    
    /// 保存配置
    private func saveConfig() {
        do {
            let data = try JSONEncoder().encode(config)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("保存番茄钟配置失败: \(error)")
        }
    }
    
    // MARK: - 权限请求
    
    /// 请求通知权限
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("[Pomodoro] ❌ 请求通知权限失败: \(error)")
            }
            print("[Pomodoro] 通知权限: \(granted ? "✅ 已授权" : "❌ 未授权")")
            
            // 检查当前权限状态
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                print("[Pomodoro] 当前通知设置：\(settings.authorizationStatus.rawValue)")
            }
        }
    }
}
