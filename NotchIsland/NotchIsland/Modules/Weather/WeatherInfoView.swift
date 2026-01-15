//
//  WeatherInfoView.swift
//  NotchIsland
//
//  天气信息的占位组件（当前使用 Mock 数据），用于刘海信息条。
//

import SwiftUI

struct WeatherInfoView: View {
    // TODO: 后续接入真实天气服务，这里先使用固定示例数据
    private let icon: String = "sun.max.fill"
    private let temperatureText: String = "26℃"
    private let descriptionText: String = "晴"
    var compact: Bool = false  // 紧凑模式

    var body: some View {
        if compact {
            // 紧凑模式：只显示图标 + 温度
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.yellow, .orange)
                Text(temperatureText)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
            }
        } else {
            // 展开模式：周几 + 天气
            HStack(spacing: 4) {
                Text(weekdayString)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(.white.opacity(0.8))
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.yellow, .orange)
                Text(temperatureText)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                Text(descriptionText)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
    
    private var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: Date())
    }
}

#Preview {
    WeatherInfoView()
        .padding()
        .previewLayout(.sizeThatFits)
}
