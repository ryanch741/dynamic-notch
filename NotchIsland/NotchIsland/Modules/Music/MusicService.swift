//
//  MusicService.swift
//  NotchIsland
//
//  音乐服务（获取当前播放音乐信息、控制播放）
//

import Foundation
import Combine
import AppKit
import MediaPlayer

/// 音乐服务
class MusicService: ObservableObject {
    static let shared = MusicService()
    
    @Published var currentMusic: MusicInfo?
    
    private var updateTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // 监听系统音乐播放信息变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(nowPlayingInfoDidChange),
            name: NSNotification.Name("com.apple.Music.playerInfo"),
            object: nil
        )
    }
    
    // MARK: - 监听控制
    
    @objc private func nowPlayingInfoDidChange() {
        updateMusicInfo()
    }
    
    /// 开始监听音乐信息
    func startMonitoring() {
        // 首次请求权限
        requestPermission()
        
        // 立即更新一次
        updateMusicInfo()
        
        // 每 1 秒轮询一次
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMusicInfo()
        }
    }
    
    /// 请求访问 Music.app 权限
    private func requestPermission() {
        let script = "tell application \"Music\" to get name"
        NSAppleScript(source: script)?.executeAndReturnError(nil)
    }
    
    /// 停止监听音乐信息
    func stopMonitoring() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    // MARK: - 音乐信息获取（预留接口）
    
    /// 更新音乐信息
    private func updateMusicInfo() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            // 1. 尝试 Apple Music
            if self?.isAppRunning(bundleId: "com.apple.Music") == true {
                if let info = self?.getMusicInfo(app: "Music", source: .appleMusic) {
                    DispatchQueue.main.async {
                        self?.currentMusic = info
                    }
                    return
                }
            }
            
            // 2. 尝试 Spotify
            if self?.isAppRunning(bundleId: "com.spotify.client") == true {
                if let info = self?.getMusicInfo(app: "Spotify", source: .spotify) {
                    DispatchQueue.main.async {
                        self?.currentMusic = info
                    }
                    return
                }
            }
            
            // 都没有播放
            DispatchQueue.main.async {
                self?.currentMusic = nil
            }
        }
    }
    
    /// 检查应用是否在运行
    private func isAppRunning(bundleId: String) -> Bool {
        let runningApps = NSWorkspace.shared.runningApplications
        return runningApps.contains { $0.bundleIdentifier == bundleId }
    }
    
    /// 通用获取音乐信息（适用于 Apple Music 和 Spotify）
    private func getMusicInfo(app: String, source: MusicSource) -> MusicInfo? {
        let script = """
        tell application "\(app)"
            if player state is not stopped then
                set trackName to name of current track
                set trackArtist to artist of current track
                set trackAlbum to album of current track
                set trackDuration to duration of current track
                set trackPosition to player position
                set playerSt to player state as string
                return trackName & "|" & trackArtist & "|" & trackAlbum & "|" & trackDuration & "|" & trackPosition & "|" & playerSt
            else
                return "stopped"
            end if
        end tell
        """
        
        var error: NSDictionary?
        guard let scriptObject = NSAppleScript(source: script) else {
            return nil
        }
        
        let output = scriptObject.executeAndReturnError(&error)
        
        if error != nil {
            return nil
        }
        
        guard let result = output.stringValue, result != "stopped" else {
            return nil
        }
        
        let components = result.components(separatedBy: "|")
        guard components.count >= 6 else {
            return nil
        }
        
        let title = components[0]
        let artist = components[1]
        let album = components[2].isEmpty ? nil : components[2]
        let duration = Double(components[3]) ?? 0
        let currentTime = Double(components[4]) ?? 0
        let stateString = components[5]
        
        let playbackState: PlaybackState = stateString.contains("playing") ? .playing : .paused
        
        return MusicInfo(
            title: title,
            artist: artist,
            album: album,
            artwork: nil,
            duration: duration,
            currentTime: currentTime,
            playbackState: playbackState,
            source: source
        )
    }
    
    // MARK: - 播放控制
    
    /// 获取当前播放器名称
    private var currentPlayerApp: String {
        guard let music = currentMusic else { return "Music" }
        switch music.source {
        case .appleMusic:
            return "Music"
        case .spotify:
            return "Spotify"
        case .qqMusic:
            return "QQMusic"
        case .netease:
            return "NeteaseMusic"
        case .unknown:
            return "Music"
        }
    }
    
    /// 播放/暂停
    func togglePlayPause() {
        let script = "tell application \"\(currentPlayerApp)\" to playpause"
        NSAppleScript(source: script)?.executeAndReturnError(nil)
    }
    
    /// 下一曲
    func nextTrack() {
        let script = "tell application \"\(currentPlayerApp)\" to next track"
        NSAppleScript(source: script)?.executeAndReturnError(nil)
    }
    
    /// 上一曲
    func previousTrack() {
        let script = "tell application \"\(currentPlayerApp)\" to previous track"
        NSAppleScript(source: script)?.executeAndReturnError(nil)
    }
    
    /// 快进
    func seekForward(_ seconds: TimeInterval = 10) {
        // TODO: 在 v2 阶段 6 实现
    }
    
    /// 快退
    func seekBackward(_ seconds: TimeInterval = 10) {
        // TODO: 在 v2 阶段 6 实现
    }
    
    deinit {
        stopMonitoring()
    }
}
