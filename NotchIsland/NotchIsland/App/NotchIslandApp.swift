//
//  NotchIslandApp.swift
//  NotchIsland
//
//  Created by Ryan on 2026/1/11.
//

import SwiftUI
import AppKit
import Combine
import UserNotifications

@main
struct NotchIslandApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    private var statusBarController: StatusBarController?
    private var settingsWindowController: SettingsWindowController?
    let todoStore = TodoStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置通知代理
        UNUserNotificationCenter.current().delegate = self
        
        // 请求番茄钟通知权限
        PomodoroService.shared.requestNotificationPermission()
        
        // 不再在应用启动时开始监听音乐，由视图控制
        // MusicService.shared.startMonitoring()
        
        statusBarController = StatusBarController(todoStore: todoStore)
        NotificationCenter.default.addObserver(self, selector: #selector(showSettingsWindow), name: .openSettings, object: nil)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// 应用在前台时也显示通知
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    /// 点击通知后的处理
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 激活应用
        NSApp.activate(ignoringOtherApps: true)
        completionHandler()
    }

    @objc private func showSettingsWindow() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }
        settingsWindowController?.show()
    }
}

final class StatusBarController {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private var notchBarControllers: [NotchBarWindowController] = []  // 多屏支持
    private let todoStore: TodoStore

    init(todoStore: TodoStore) {
        self.todoStore = todoStore
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        popover = NSPopover()

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "sparkles", accessibilityDescription: "NotchIsland")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        popover.behavior = .transient
        popover.contentSize = NSSize(width: 360, height: 360)
        popover.contentViewController = NSHostingController(rootView: MainMenuView(todoStore: todoStore))

        // 为每个屏幕创建 NotchBar
        setupNotchBarsForAllScreens()
        
        // 监听屏幕变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
        
        // 监听 UserDefaults 变化（设置页修改）
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotchBarsForAllScreens() {
        // 清理旧窗口
        notchBarControllers.forEach { $0.close() }
        notchBarControllers.removeAll()
        
        // 读取设置：是否在副屏显示
        let showSecondaryScreenNotch = UserDefaults.standard.bool(forKey: "showSecondaryScreenNotch")
        // 默认值为 true，如果未设置则显示
        let shouldShowSecondary = UserDefaults.standard.object(forKey: "showSecondaryScreenNotch") == nil ? true : showSecondaryScreenNotch
        
        // 为每个屏幕创建 NotchBar
        for (index, screen) in NSScreen.screens.enumerated() {
            let isMainScreen = (screen == NSScreen.main)
            
            // 副屏且设置为不显示，则跳过
            if !isMainScreen && !shouldShowSecondary {
                continue
            }
            
            let controller = NotchBarWindowController(screen: screen)
            controller.show()
            notchBarControllers.append(controller)
        }
        
        print("[多屏幕] 已为 \(notchBarControllers.count) 个屏幕创建 NotchBar（总共 \(NSScreen.screens.count) 个屏幕）")
    }
    
    @objc private func screensDidChange() {
        print("[多屏幕] 屏幕配置发生变化，重新创建 NotchBar")
        setupNotchBarsForAllScreens()
    }
    
    @objc private func settingsDidChange() {
        // 设置变化时重新创建 NotchBar
        print("[多屏幕] 设置发生变化，重新创建 NotchBar")
        setupNotchBarsForAllScreens()
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}

final class NotchBarWindowController: NSWindowController, NSWindowDelegate {
    private var trackingArea: NSTrackingArea?
    private var viewModel: NotchBarViewModel!
    private let windowSize = NSSize(width: 700, height: 250)
    private let collapsedWidth: CGFloat = 200
    private let expandedWidth: CGFloat = 700
    private let expandedHeight: CGFloat = 250
    private var globalMouseMonitor: Any?
    private var localMouseMonitor: Any?  // 本地鼠标监听
    private var notchBarContainerView: NotchBarContainerView!
    private let targetScreen: NSScreen  // 目标屏幕
    
    init(screen: NSScreen) {
        self.targetScreen = screen
        
        let viewModel = NotchBarViewModel()
        let notchBarContainerView = NotchBarContainerView(viewModel: viewModel)
        
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: NSSize(width: 700, height: 250)),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.level = .statusBar
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        window.contentView = notchBarContainerView
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        
        super.init(window: window)
        
        self.viewModel = viewModel
        self.notchBarContainerView = notchBarContainerView
        window.delegate = self
        
        // 监听 viewModel 变化
        viewModel.onExpandedChanged = { [weak self] isExpanded in
            self?.notchBarContainerView.updateExpanded(isExpanded)
            self?.updateWindowSize(isExpanded: isExpanded)  // 动态调整窗口尺寸
        }
        
        positionWindow()
        setupTrackingArea()
        setupGlobalMouseMonitor()  // 设置全局鼠标监听
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let monitor = globalMouseMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = localMouseMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    private func setupTrackingArea() {
        // 不再需要窗口内追踪，因为已经有全局监听
        print("[TrackingArea] 使用全局鼠标监听代替窗口追踪")
    }
    
    private func setupGlobalMouseMonitor() {
        // 全局监听：监听其他应用的鼠标移动
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.checkGlobalMousePosition()
        }
        
        // 本地监听：监听自己应用内的鼠标移动
        localMouseMonitor = NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.checkGlobalMousePosition()
            return event
        }
        
        print("[GlobalMonitor] 已启动全局+本地鼠标监听")
        print("[GlobalMonitor] 提示：移动鼠标到屏幕顶部测试事件接收")
    }
    
    private func checkGlobalMousePosition() {
        guard let window = window else { return }
        let screen = targetScreen  // 使用目标屏幕
            
        // 如果正在忽略鼠标离开（打开对话框），不进行监听
        if viewModel.shouldIgnoreMouseExit {
            return
        }
                
        // 获取鼠标在屏幕中的绝对位置
        let mouseLocation = NSEvent.mouseLocation
                
        // 计算触发区域在屏幕中的绝对位置
        let screenFrame = screen.frame
                
        // 刘海条触发区域：稍微进入刘海内部后触发（35pt高度）
        let triggerRect = NSRect(
            x: screenFrame.midX - collapsedWidth / 2,
            y: screenFrame.maxY - 35,
            width: collapsedWidth,
            height: 35
        )
                
        // 展开区域：完整的 700x250 窗口区域 + 5pt 顶部容差（解决边界值判断问题）
        let expandedRect = NSRect(
            x: screenFrame.midX - expandedWidth / 2,
            y: screenFrame.maxY - expandedHeight,
            width: expandedWidth,
            height: expandedHeight + 5
        )
                
        if viewModel.isExpanded {
            // 已展开状态：检查是否在展开区域内
            if !expandedRect.contains(mouseLocation) {
                viewModel.isExpanded = false
            }
        } else {
            // 收起状态：检查是否进入触发区域
            if triggerRect.contains(mouseLocation) {
                viewModel.isExpanded = true
            }
        }
    }
    
    private func positionWindow() {
        guard let window = window else { return }
        let screen = targetScreen  // 使用目标屏幕
        let screenFrame = screen.frame
        
        // 窗口顶部贴屏幕顶部
        let originX = screenFrame.midX - windowSize.width / 2
        let originY = screenFrame.maxY - windowSize.height
        
        window.setFrameOrigin(NSPoint(x: originX, y: originY))
    }
    
    private func updateWindowSize(isExpanded: Bool) {
        guard let window = window else { return }
        let screen = targetScreen  // 使用目标屏幕
        let screenFrame = screen.frame
        
        // 根据状态设置窗口尺寸
        let newWidth: CGFloat = isExpanded ? 700 : 200
        let newHeight: CGFloat = isExpanded ? 250 : 38
        
        // 保持水平居中，顶部贴屏幕顶部
        let originX = screenFrame.midX - newWidth / 2
        let originY = screenFrame.maxY - newHeight
        
        // 动画调整窗口大小和位置
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(
                NSRect(x: originX, y: originY, width: newWidth, height: newHeight),
                display: true
            )
        })
    }
    
    func show() {
        window?.orderFrontRegardless()
    }
}

final class SettingsWindowController: NSWindowController {
    convenience init() {
        let rootView = SettingsView()
        let hostingView = NSHostingView(rootView: rootView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 320),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.center()
        window.title = NSLocalizedString("设置", comment: "")
        window.isReleasedWhenClosed = false
        window.contentView = hostingView

        self.init(window: window)
    }

    func show() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

class NotchBarViewModel: ObservableObject {
    @Published var isExpanded: Bool = false
    @Published var shouldIgnoreMouseExit: Bool = false  // 忽略鼠标离开（打开对话框时）
    var onExpandedChanged: ((Bool) -> Void)?
    
    init() {
        // 监听 isExpanded 变化
        $isExpanded.sink { [weak self] newValue in
            self?.onExpandedChanged?(newValue)
        }.store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}

// AppKit 自定义 View，用 CAShapeLayer 实现圆角动画
class NotchBarContainerView: NSView {
    private let shapeLayer = CAShapeLayer()
    private let contentHostingView: NSHostingView<NotchBarView>
    private let viewModel: NotchBarViewModel
    private var isExpanded = false
    
    init(viewModel: NotchBarViewModel) {
        self.viewModel = viewModel
        self.contentHostingView = NSHostingView(rootView: NotchBarView(viewModel: viewModel))
        super.init(frame: .zero)
        
        wantsLayer = true
        
        // 设置 shapeLayer
        shapeLayer.fillColor = NSColor.black.cgColor
        layer?.addSublayer(shapeLayer)
        
        // 添加内容视图
        addSubview(contentHostingView)
        contentHostingView.frame = bounds
        contentHostingView.autoresizingMask = [.width, .height]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layout() {
        super.layout()
        updateShapePath(animated: false)
    }
    
    func updateExpanded(_ expanded: Bool) {
        isExpanded = expanded
        updateShapePath(animated: true)
    }
    
    private func updateShapePath(animated: Bool) {
        let width: CGFloat = isExpanded ? 700 : 200
        let height: CGFloat = isExpanded ? 250 : 38
        let cornerRadius: CGFloat = 16
        
        let path = NSBezierPath()
        let rect = NSRect(x: (700 - width) / 2, y: 250 - height, width: width, height: height)
        
        // 顶部直角，底部圆角
        path.move(to: NSPoint(x: rect.minX, y: rect.maxY))
        path.line(to: NSPoint(x: rect.maxX, y: rect.maxY))
        path.line(to: NSPoint(x: rect.maxX, y: rect.minY + cornerRadius))
        path.appendArc(withCenter: NSPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                       radius: cornerRadius, startAngle: 0, endAngle: 270, clockwise: true)
        path.line(to: NSPoint(x: rect.minX + cornerRadius, y: rect.minY))
        path.appendArc(withCenter: NSPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                       radius: cornerRadius, startAngle: 270, endAngle: 180, clockwise: true)
        path.close()
        
        let cgPath = path.cgPath
        
        if animated {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = shapeLayer.path
            animation.toValue = cgPath
            animation.duration = 0.3
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            shapeLayer.add(animation, forKey: "pathAnimation")
        }
        
        shapeLayer.path = cgPath
    }
}

extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        
        for i in 0..<elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            @unknown default:
                break
            }
        }
        return path
    }
}

// 自定义形状：模拟刘海形状，顶部完全平直（直角），只有底部圆角
struct NotchShape: Shape {
    var bottomCornerRadius: CGFloat = 12  // 底部圆角
    
    // 禁用动画数据，让形状不参与插值动画
    var animatableData: EmptyAnimatableData {
        get { EmptyAnimatableData() }
        set { }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // 从左上角开始（直角）
        path.move(to: CGPoint(x: 0, y: 0))
        
        // 顶部水平线
        path.addLine(to: CGPoint(x: width, y: 0))
        
        // 右侧垂直线
        path.addLine(to: CGPoint(x: width, y: height - bottomCornerRadius))
        
        // 右下角圆角
        path.addQuadCurve(
            to: CGPoint(x: width - bottomCornerRadius, y: height),
            control: CGPoint(x: width, y: height)
        )
        
        // 底部水平线
        path.addLine(to: CGPoint(x: bottomCornerRadius, y: height))
        
        // 左下角圆角
        path.addQuadCurve(
            to: CGPoint(x: 0, y: height - bottomCornerRadius),
            control: CGPoint(x: 0, y: height)
        )
        
        // 左侧垂直线回到起点
        path.closeSubpath()
        
        return path
    }
}

struct NotchBarView: View {
    @ObservedObject var viewModel: NotchBarViewModel
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showContent = false
    @State private var selectedModule: NotchBarModule = .shortcuts
    
    enum NotchBarModule: String, CaseIterable {
        case shortcuts = "快捷方式"
        case pomodoro = "番茄钟"
        case music = "音乐"
        
        var icon: String {
            switch self {
            case .shortcuts: return "app.badge"
            case .pomodoro: return "brain.head.profile"
            case .music: return "music.note"
            }
        }
    }
    
    // 周几字符串
    private var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale.current
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // 背景由 CAShapeLayer 绘制，这里不需要
            Color.clear
                .frame(width: 700, height: 250)
            
            // 应用内通知横幅
            if let notification = notificationManager.currentNotification {
                VStack {
                    NotificationBanner(
                        title: notification.title,
                        message: notification.message,
                        onDismiss: {
                            notificationManager.dismiss()
                        }
                    )
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    Spacer()
                }
                .zIndex(1000)
            }
            
            // 内容区域：延迟显示
            if showContent {
                VStack(alignment: .leading, spacing: 0) {
                    if viewModel.isExpanded {
                        // 展开状态：第一行需要显示在刘海左右两侧（菜单栏高度位置）
                        HStack(spacing: 0) {
                            TimeInfoView(compact: false)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(LocalizedStringKey("灵动刘海"))
                                .font(.system(size: 10, weight: .regular))
                                .foregroundStyle(.white.opacity(0.4))
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            // 右侧显示周几
                            Text(weekdayString)
                                .font(.system(size: 11, weight: .regular))
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            // 天气模块已隐藏
                            // WeatherInfoView(compact: false)
                            //     .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(height: 32)
                        .padding(.horizontal, 16)
                        .padding(.top, 2)  // 稍微向下一点点，避免被完全遮挡
                        
                        // 展开内容区域
                        VStack(spacing: 4) {
                            // 模块切换器
                            HStack(spacing: 12) {
                                ForEach(NotchBarModule.allCases, id: \.self) { module in
                                    Button(action: {
                                        selectedModule = module
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: module.icon)
                                                .font(.system(size: 10))
                                            Text(LocalizedStringKey(module.rawValue))
                                                .font(.system(size: 10, weight: .medium))
                                        }
                                        .foregroundStyle(
                                            selectedModule == module 
                                            ? Color.white.opacity(0.9) 
                                            : Color.white.opacity(0.5)
                                        )
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(
                                                    selectedModule == module 
                                                    ? Color.white.opacity(0.15) 
                                                    : Color.clear
                                                )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 24)
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                                .padding(.horizontal, 16)
                            
                            // 内容区域
                            Group {
                                switch selectedModule {
                                case .shortcuts:
                                    ShortcutGridView()
                                        .environmentObject(viewModel)
                                case .pomodoro:
                                    PomodoroView()
                                case .music:
                                    MusicView()
                                        .onAppear {
                                            // 进入音乐模块时开始监听
                                            MusicService.shared.startMonitoring()
                                        }
                                        .onDisappear {
                                            // 离开音乐模块时停止监听
                                            MusicService.shared.stopMonitoring()
                                        }
                                }
                            }
                            .frame(height: 190)  // 增加到 190pt，总高度 250pt
                            .transition(.opacity)
                        }
                        .padding(.top, 4)
                        .transition(.opacity)
                    } else {
                        // 收起状态：只显示时间和日期
                        HStack(spacing: 8) {
                            TimeInfoView(compact: true)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            // 天气模块已隐藏
                            // Spacer(minLength: 20)
                            // WeatherInfoView(compact: true)
                            //     .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(height: 30)
                        .padding(.horizontal, 12)
                        .padding(.top, 2)  // 稍微向下一点点
                    }
                    
                    Spacer(minLength: 0)
                }
                .frame(width: viewModel.isExpanded ? 700 : 200,
                       height: viewModel.isExpanded ? 250 : 38,
                       alignment: .top)
                .opacity(showContent ? 1 : 0)
                .animation(.easeIn(duration: 0.15).delay(0.15), value: showContent)
            }
        }
        .frame(width: 700, height: 250, alignment: .top)
        .animation(.spring(response: 0.3, dampingFraction: 0.75, blendDuration: 0), value: viewModel.isExpanded)
        .onChange(of: viewModel.isExpanded) { _, newValue in
            if newValue {
                // 展开时，延迟0.3秒显示内容（等待动画完成）
                showContent = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showContent = true
                }
            } else {
                // 收起时，立即显示内容
                showContent = true
            }
        }
        .onAppear {
            showContent = true  // 初始显示内容
        }
    }
}

struct MainMenuView: View {
    @ObservedObject var todoStore: TodoStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image("app_icon_1024")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(LocalizedStringKey("灵动刘海"))
                            .font(.headline)
                        Text(LocalizedStringKey("效率增强助手"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                Button(LocalizedStringKey("打开设置")) {
                    NotificationCenter.default.post(name: .openSettings, object: nil)
                }

                Button(LocalizedStringKey("退出")) {
                    NSApp.terminate(nil)
                }
            }
            .padding()

            Divider()

            TodoListView(todoStore: todoStore)
        }
        .frame(minWidth: 360, minHeight: 400)
    }
}

struct SettingsView: View {
    @AppStorage("showSecondaryScreenNotch") private var showSecondaryScreenNotch = true
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Image("app_icon_1024")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizedStringKey("灵动刘海"))
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    Text(LocalizedStringKey("软件介绍"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text(LocalizedStringKey("显示设置"))) {
                Toggle(LocalizedStringKey("在副屏显示刘海"), isOn: $showSecondaryScreenNotch)
                    .help(LocalizedStringKey("在副屏显示刘海帮助"))
            }
            
            Section(header: Text(LocalizedStringKey("关于"))) {
                HStack {
                    Text(LocalizedStringKey("开发者"))
                    Spacer()
                    Text("hianzuo")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(LocalizedStringKey("版权"))
                    Spacer()
                    Text("© 2026 Dynamic Notch")
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 480, minHeight: 400)
    }
}

extension Notification.Name {
    static let openSettings = Notification.Name("NotchIslandOpenSettings")
}
