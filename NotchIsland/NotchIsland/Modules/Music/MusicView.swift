//
//  MusicView.swift
//  NotchIsland
//
//  音乐模块视图
//

import SwiftUI

struct MusicView: View {
    @ObservedObject var service = MusicService.shared
    
    var body: some View {
        if let music = service.currentMusic {
            // 有音乐播放时显示
            playingView(music)
        } else {
            // 无音乐播放时显示占位
            emptyView
        }
    }
    
    // MARK: - 播放中视图
    
    private func playingView(_ music: MusicInfo) -> some View {
        HStack(spacing: 32) {
            // 左侧：封面 + 下方信息
            VStack(spacing: 8) {
                // 专辑封面
                if let artwork = music.artwork {
                    Image(nsImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .cornerRadius(8)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: music.source.icon)
                            .font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                
                // 歌曲信息（封面下方）
                VStack(spacing: 3) {
                    Text(music.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    Text(music.artist)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                }
                .frame(width: 100)
            }
            .frame(maxHeight: .infinity)
            
            // 右侧：控制 + 进度（占满剩余空间）
            VStack(spacing: 20) {
                Spacer()
                
                // 控制按钮
                HStack(spacing: 36) {
                    Button(action: { service.previousTrack() }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { service.togglePlayPause() }) {
                        Image(systemName: music.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { service.nextTrack() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
                
                // 进度条
                VStack(spacing: 6) {
                    ProgressView(value: music.progress)
                        .tint(.white)
                        .frame(height: 4)
                    
                    HStack {
                        Text(music.formattedCurrentTime)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.5))
                        
                        Spacer()
                        
                        Text(music.formattedDuration)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - 空状态视图
    
    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.3))
            
            Text(LocalizedStringKey("未播放音乐"))
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MusicView()
        .frame(width: 600, height: 200)
        .background(Color.black)
}
