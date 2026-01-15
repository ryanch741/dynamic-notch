//
//  ShortcutItem.swift
//  NotchIsland
//
//  快捷方式数据模型
//

import Foundation
import AppKit

/// 快捷方式类型
enum ShortcutType: String, Codable {
    case application    // 应用程序
    case website        // 网址
    case folder         // 文件夹
}

/// 快捷方式数据模型
struct ShortcutItem: Identifiable, Codable {
    let id: UUID
    var type: ShortcutType
    var name: String
    var target: String          // 目标：应用路径、URL、文件夹路径
    var iconData: Data?         // 图标数据（用于缓存网站 favicon）
    var order: Int              // 排序位置
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        type: ShortcutType,
        name: String,
        target: String,
        iconData: Data? = nil,
        order: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.target = target
        self.iconData = iconData
        self.order = order
        self.createdAt = createdAt
    }
}

// MARK: - 扩展方法
extension ShortcutItem {
    /// 获取图标
    var icon: NSImage? {
        switch type {
        case .application:
            // 应用图标
            return NSWorkspace.shared.icon(forFile: target)
        case .website:
            // 网站图标（从缓存加载或使用默认图标）
            if let iconData = iconData, let image = NSImage(data: iconData) {
                return image
            }
            // 使用白色的 Safari 图标作为默认网站图标
            if let safariPath = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Safari")?.path {
                return NSWorkspace.shared.icon(forFile: safariPath)
            }
            return NSImage(systemSymbolName: "globe", accessibilityDescription: "Website")
        case .folder:
            // 文件夹图标
            return NSWorkspace.shared.icon(forFile: target)
        }
    }
    
    /// 打开快捷方式目标
    func open() {
        switch type {
        case .application:
            NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: target), configuration: NSWorkspace.OpenConfiguration())
        case .website:
            if let url = URL(string: target) {
                NSWorkspace.shared.open(url)
            }
        case .folder:
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: target)
        }
    }
}
