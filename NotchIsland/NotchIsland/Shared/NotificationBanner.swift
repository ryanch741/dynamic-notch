import SwiftUI
import Combine

/// 应用内通知横幅
struct NotificationBanner: View {
    let title: String
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 图标
            Image(systemName: "bell.fill")
                .font(.system(size: 24))
                .foregroundStyle(.white)
            
            // 内容
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.9))
            }
            
            Spacer()
            
            // 关闭按钮
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.9))
                .shadow(color: .black.opacity(0.3), radius: 20, y: 5)
        )
        .frame(width: 350)
    }
}

/// 通知管理器
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var currentNotification: NotificationItem?
    private var notificationWindow: NSWindow?
    
    private init() {}
    
    func show(title: String, message: String) {
        // 关闭旧窗口
        notificationWindow?.close()
        notificationWindow = nil
        
        // 创建通知窗口
        DispatchQueue.main.async {
            self.showNotificationWindow(title: title, message: message)
        }
    }
    
    private func showNotificationWindow(title: String, message: String) {
        guard let screen = NSScreen.main else { return }
        
        let windowWidth: CGFloat = 360
        let windowHeight: CGFloat = 120
        
        // 窗口位置：屏幕顶部中央
        let windowRect = NSRect(
            x: (screen.frame.width - windowWidth) / 2,
            y: screen.frame.maxY - windowHeight - 80,  // 距离顶部 80pt
            width: windowWidth,
            height: windowHeight
        )
        
        let window = NSWindow(
            contentRect: windowRect,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.level = .floating  // 浮在最上层
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        let contentView = NSHostingView(rootView: 
            NotificationBanner(
                title: title,
                message: message,
                onDismiss: { [weak window] in
                    window?.close()
                }
            )
        )
        
        window.contentView = contentView
        window.makeKeyAndOrderFront(nil)
        
        self.notificationWindow = window
    }
    
    func dismiss() {
        notificationWindow?.close()
        notificationWindow = nil
        currentNotification = nil
    }
}

struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

#Preview {
    NotificationBanner(
        title: "番茄钟完成！",
        message: "专注时间结束，该休息一下了 ☕️",
        onDismiss: {}
    )
}
