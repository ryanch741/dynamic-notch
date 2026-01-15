//
//  MusicInfo.swift
//  NotchIsland
//
//  音乐信息数据模型
//

import Foundation
import AppKit

/// 播放状态
enum PlaybackState: String {
    case playing    // 播放中
    case paused     // 暂停
    case stopped    // 停止
}

/// 音乐信息模型
struct MusicInfo: Identifiable {
    let id: UUID
    var title: String                   // 歌曲名
    var artist: String                  // 艺术家
    var album: String?                  // 专辑名
    var artwork: NSImage?               // 专辑封面
    var duration: TimeInterval          // 总时长（秒）
    var currentTime: TimeInterval       // 当前播放时间（秒）
    var playbackState: PlaybackState    // 播放状态
    var source: MusicSource             // 音乐来源
    
    init(
        id: UUID = UUID(),
        title: String = "",
        artist: String = "",
        album: String? = nil,
        artwork: NSImage? = nil,
        duration: TimeInterval = 0,
        currentTime: TimeInterval = 0,
        playbackState: PlaybackState = .stopped,
        source: MusicSource = .unknown
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.artwork = artwork
        self.duration = duration
        self.currentTime = currentTime
        self.playbackState = playbackState
        self.source = source
    }
}

/// 音乐来源
enum MusicSource: String {
    case appleMusic     // Apple Music
    case spotify        // Spotify
    case qqMusic        // QQ 音乐
    case netease        // 网易云音乐
    case unknown        // 未知
}

// MARK: - 扩展方法
extension MusicInfo {
    /// 进度百分比（0-1）
    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    /// 格式化当前播放时间（MM:SS）
    var formattedCurrentTime: String {
        formatTime(currentTime)
    }
    
    /// 格式化总时长（MM:SS）
    var formattedDuration: String {
        formatTime(duration)
    }
    
    /// 格式化剩余时间（MM:SS）
    var formattedRemainingTime: String {
        formatTime(duration - currentTime)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// 是否正在播放
    var isPlaying: Bool {
        playbackState == .playing
    }
    
    /// 显示信息（歌名 - 艺术家）
    var displayInfo: String {
        if title.isEmpty && artist.isEmpty {
            return "未播放音乐"
        }
        if artist.isEmpty {
            return title
        }
        if title.isEmpty {
            return artist
        }
        return "\(title) - \(artist)"
    }
}

extension MusicSource {
    /// 显示名称
    var displayName: String {
        switch self {
        case .appleMusic:
            return "Apple Music"
        case .spotify:
            return "Spotify"
        case .qqMusic:
            return "QQ 音乐"
        case .netease:
            return "网易云音乐"
        case .unknown:
            return "未知"
        }
    }
    
    /// 图标
    var icon: String {
        switch self {
        case .appleMusic:
            return "music.note"
        case .spotify:
            return "music.quarternote.3"
        case .qqMusic:
            return "music.note.list"
        case .netease:
            return "music.mic"
        case .unknown:
            return "music.note.list"
        }
    }
}
