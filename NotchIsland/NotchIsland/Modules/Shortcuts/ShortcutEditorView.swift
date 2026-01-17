import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// 快捷方式编辑视图
struct ShortcutEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var service = ShortcutService.shared
    @EnvironmentObject var notchBarViewModel: NotchBarViewModel
    
    @State private var selectedType: ShortcutType = .website
    @State private var name: String = ""
    @State private var target: String = ""
    @State private var isPickingFile = false
    @State private var isFetchingTitle = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(LocalizedStringKey("添加快捷方式"))
                .font(.title2)
                .fontWeight(.semibold)
            
            // 类型选择
            Picker(LocalizedStringKey("类型"), selection: $selectedType) {
                Text(LocalizedStringKey("网站")).tag(ShortcutType.website)
                Text(LocalizedStringKey("应用程序")).tag(ShortcutType.application)
                Text(LocalizedStringKey("文件夹")).tag(ShortcutType.folder)
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedType) { _, _ in
                // 切换类型时清空输入
                name = ""
                target = ""
            }
            
            // 网址输入（第一个）
            if selectedType == .website {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(LocalizedStringKey("网址"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        if isFetchingTitle {
                            ProgressView()
                                .scaleEffect(0.6)
                                .frame(width: 16, height: 16)
                        }
                    }
                    
                    TextField("baidu.com", text: $target)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: target) { _, newValue in
                            // 输入网址时自动获取标题
                            if !newValue.isEmpty && name.isEmpty {
                                fetchWebsiteTitle(from: newValue)
                            }
                        }
                }
            }
            
            // 名称输入（第二个）
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizedStringKey("名称"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                TextField(LocalizedStringKey("名称"), text: $name)
                    .textFieldStyle(.roundedBorder)
            }
            
            // 应用/文件夹路径选择
            if selectedType != .website {
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey(targetLabel))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        TextField(LocalizedStringKey(targetLabel), text: $target)
                            .textFieldStyle(.roundedBorder)
                            .disabled(true)
                        
                        Button(LocalizedStringKey("浏览")) {
                            selectFile()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            
            Spacer()
            
            // 操作按钮
            HStack(spacing: 12) {
                Button(LocalizedStringKey("取消")) {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button(LocalizedStringKey("添加")) {
                    addShortcut()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isValid)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 400, height: 320)
    }
    
    private var targetLabel: String {
        switch selectedType {
        case .application:
            return "应用程序路径"
        case .website:
            return "网址"
        case .folder:
            return "文件夹路径"
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty && !target.isEmpty
    }
    
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = selectedType == .application
        panel.canChooseDirectories = selectedType == .folder
        panel.allowsMultipleSelection = false
        
        if selectedType == .application {
            panel.allowedContentTypes = [.application]
            panel.directoryURL = URL(fileURLWithPath: "/Applications")
        }
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.target = url.path
                
                // 如果名称为空，自动填充文件名
                if self.name.isEmpty {
                    self.name = url.deletingPathExtension().lastPathComponent
                }
            }
        }
    }
    
    private func addShortcut() {
        if selectedType == .website {
            // 网站类型：自动添加 https:// 前缀并获取图标
            let normalizedURL = normalizeURL(target)
            service.addWebsiteShortcut(name: name, url: normalizedURL)
        } else {
            // 应用和文件夹类型：直接添加
            let shortcut = ShortcutItem(
                type: selectedType,
                name: name,
                target: target
            )
            service.addShortcut(shortcut)
        }
        
        dismiss()
    }
    
    /// 规范化 URL（自动添加 https:// 前缀）
    private func normalizeURL(_ urlString: String) -> String {
        var normalized = urlString.trimmingCharacters(in: .whitespaces)
        
        // 如果没有协议，添加 https://
        if !normalized.lowercased().hasPrefix("http://") && !normalized.lowercased().hasPrefix("https://") {
            normalized = "https://" + normalized
        }
        
        return normalized
    }
    
    /// 获取网站标题
    private func fetchWebsiteTitle(from urlString: String) {
        let normalizedURL = normalizeURL(urlString)
        
        guard let url = URL(string: normalizedURL) else { return }
        
        isFetchingTitle = true
        
        let task = URLSession.shared.dataTask(with: url) { [self] data, response, error in
            DispatchQueue.main.async {
                self.isFetchingTitle = false
            }
            
            guard let data = data,
                  let html = String(data: data, encoding: .utf8) else {
                return
            }
            
            // 解析 HTML 提取 <title> 标签
            if let titleRange = html.range(of: "<title>(.*?)</title>", options: .regularExpression) {
                var title = String(html[titleRange])
                title = title.replacingOccurrences(of: "<title>", with: "")
                title = title.replacingOccurrences(of: "</title>", with: "")
                title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                
                DispatchQueue.main.async {
                    if self.name.isEmpty {
                        self.name = title
                    }
                }
            }
        }
        task.resume()
    }
}

#Preview {
    ShortcutEditorView()
}
