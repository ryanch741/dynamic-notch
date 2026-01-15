//
//  TimeInfoView.swift
//  NotchIsland
//
//  显示当前时间和日期的简单组件，用于刘海信息条。
//

import SwiftUI
import Combine

struct TimeInfoView: View {
    @State private var currentDate: Date = Date()
    var compact: Bool = false  // 紧凑模式：只显示时间和日期

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        if compact {
            // 紧凑模式：时间 + 日期（垂直排列）
            VStack(alignment: .leading, spacing: 2) {
                Text(timeString)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                Text(dateString)
                    .font(.system(size: 9, weight: .regular))
                    .opacity(0.8)
            }
            .foregroundStyle(.white)
            .onReceive(timer) { date in
                currentDate = date
            }
        } else {
            // 展开模式：时间 + 日期（不显示周几）
            HStack(spacing: 8) {
                Text(timeString)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                Text(dateString)
                    .font(.system(size: 11, weight: .regular))
                    .opacity(0.8)
            }
            .foregroundStyle(.white)
            .onReceive(timer) { date in
                currentDate = date
            }
        }
    }

    private var timeString: String {
        Self.timeFormatter.string(from: currentDate)
    }

    private var dateString: String {
        Self.dateFormatter.string(from: currentDate)
    }
    
    private var fullDateString: String {
        Self.fullDateFormatter.string(from: currentDate)
    }
}

extension TimeInfoView {
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter
    }()
    
    private static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd EEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
}

#Preview {
    TimeInfoView()
        .padding()
        .previewLayout(.sizeThatFits)
}
