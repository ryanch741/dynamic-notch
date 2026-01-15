//
//  ShortcutService.swift
//  NotchIsland
//
//  快捷方式服务（管理快捷方式的增删改查、持久化、图标获取）
//

import Foundation
import Combine
import AppKit
import SwiftUI

/// 快捷方式服务
class ShortcutService: ObservableObject {
    static let shared = ShortcutService()
    
    @Published var shortcuts: [ShortcutItem] = []
    
    private let userDefaultsKey = "notch_island_shortcuts"
    
    private init() {
        print("[ShortcutService] 初始化开始")
        loadShortcuts()
        print("[ShortcutService] 加载后快捷方式数量: \(shortcuts.count)")
        
        // 如果没有快捷方式，添加一些默认的示例数据（仅用于展示）
        if shortcuts.isEmpty {
            print("[ShortcutService] 列表为空，添加默认快捷方式")
            addDefaultShortcuts()
            print("[ShortcutService] 添加后快捷方式数量: \(shortcuts.count)")
        }
    }
    
    /// 添加默认快捷方式（仅用于展示）
    private func addDefaultShortcuts() {
        print("[ShortcutService] 开始添加默认快捷方式")
        
        // 常用应用
        if let safariPath = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Safari")?.path {
            print("[ShortcutService] 添加 Safari: \(safariPath)")
            addShortcut(ShortcutItem(type: .application, name: "Safari", target: safariPath))
        } else {
            print("[ShortcutService] 未找到 Safari")
        }
        
        if let finderPath = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.finder")?.path {
            print("[ShortcutService] 添加 Finder: \(finderPath)")
            addShortcut(ShortcutItem(type: .application, name: "Finder", target: finderPath))
        } else {
            print("[ShortcutService] 未找到 Finder")
        }
        
        // 常用网站
        print("[ShortcutService] 添加 GitHub")
        addShortcut(ShortcutItem(type: .website, name: "GitHub", target: "https://github.com"))
        
        print("[ShortcutService] 添加 Google")
        addShortcut(ShortcutItem(type: .website, name: "Google", target: "https://www.google.com"))
        
        // 文件夹
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        print("[ShortcutService] 添加 Home: \(homeDir)")
        addShortcut(ShortcutItem(type: .folder, name: "Home", target: homeDir))
        
        print("[ShortcutService] 默认快捷方式添加完成，当前数量: \(shortcuts.count)")
    }
    
    // MARK: - CRUD 操作
    
    /// 添加快捷方式
    func addShortcut(_ shortcut: ShortcutItem) {
        var newShortcut = shortcut
        newShortcut.order = shortcuts.count
        shortcuts.append(newShortcut)
        saveShortcuts()
    }
    
    /// 更新快捷方式
    func updateShortcut(_ shortcut: ShortcutItem) {
        guard let index = shortcuts.firstIndex(where: { $0.id == shortcut.id }) else { return }
        shortcuts[index] = shortcut
        saveShortcuts()
    }
    
    /// 删除快捷方式
    func deleteShortcut(_ shortcut: ShortcutItem) {
        shortcuts.removeAll { $0.id == shortcut.id }
        // 重新排序
        for (index, var item) in shortcuts.enumerated() {
            item.order = index
            shortcuts[index] = item
        }
        saveShortcuts()
    }
    
    /// 通过 ID 删除快捷方式
    func removeShortcut(_ id: UUID) {
        shortcuts.removeAll { $0.id == id }
        // 重新排序
        for (index, var item) in shortcuts.enumerated() {
            item.order = index
            shortcuts[index] = item
        }
        saveShortcuts()
    }
    
    /// 删除指定位置的快捷方式
    func deleteShortcut(at index: Int) {
        guard index < shortcuts.count else { return }
        shortcuts.remove(at: index)
        // 重新排序
        for (idx, var item) in shortcuts.enumerated() {
            item.order = idx
            shortcuts[idx] = item
        }
        saveShortcuts()
    }
    
    /// 重新排序快捷方式
    func reorderShortcuts(from source: IndexSet, to destination: Int) {
        shortcuts.move(fromOffsets: source, toOffset: destination)
        // 更新 order
        for (index, var item) in shortcuts.enumerated() {
            item.order = index
            shortcuts[index] = item
        }
        saveShortcuts()
    }
    
    // MARK: - 持久化
    
    /// 加载快捷方式
    private func loadShortcuts() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        do {
            shortcuts = try JSONDecoder().decode([ShortcutItem].self, from: data)
            shortcuts.sort { $0.order < $1.order }
        } catch {
            print("加载快捷方式失败: \(error)")
        }
    }
    
    /// 保存快捷方式
    private func saveShortcuts() {
        do {
            let data = try JSONEncoder().encode(shortcuts)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("保存快捷方式失败: \(error)")
        }
    }
    
    // MARK: - 网站图标获取
    
    /// 获取网站图标（favicon）
    /// - Parameters:
    ///   - url: 网站 URL
    ///   - completion: 完成回调，返回图标数据
    func fetchWebsiteIcon(for urlString: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString), let host = url.host else {
            completion(nil)
            return
        }
        
        // 方案1：尝试从 Google Favicon API 获取
        let googleFaviconURL = "https://www.google.com/s2/favicons?sz=64&domain=\(host)"
        
        fetchIcon(from: googleFaviconURL) { data in
            if let data = data, !data.isEmpty {
                completion(data)
                return
            }
            
            // 方案2：尝试从网站根目录获取 favicon.ico
            let faviconURL = "\(url.scheme ?? "https")://\(host)/favicon.ico"
            self.fetchIcon(from: faviconURL) { data in
                completion(data)
            }
        }
    }
    
    /// 获取图标
    private func fetchIcon(from urlString: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("[ShortcutService] 获取图标失败: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data, !data.isEmpty else {
                completion(nil)
                return
            }
            
            // 验证是否为有效图片
            if NSImage(data: data) != nil {
                completion(data)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    /// 添加网站快捷方式（自动获取图标）
    func addWebsiteShortcut(name: String, url: String, completion: ((ShortcutItem) -> Void)? = nil) {
        // 先添加快捷方式
        let shortcut = ShortcutItem(type: .website, name: name, target: url)
        addShortcut(shortcut)
        
        // 异步获取图标
        fetchWebsiteIcon(for: url) { [weak self] iconData in
            guard let self = self, let iconData = iconData else {
                DispatchQueue.main.async {
                    completion?(shortcut)
                }
                return
            }
            
            // 更新图标
            DispatchQueue.main.async {
                var updatedShortcut = shortcut
                updatedShortcut.iconData = iconData
                self.updateShortcut(updatedShortcut)
                completion?(updatedShortcut)
            }
        }
    }
}
