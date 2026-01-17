//
//  ShortcutGridView.swift
//  NotchIsland
//
//  快捷方式网格视图（用于刘海条展开区域）
//

import SwiftUI

struct ShortcutGridView: View {
    @ObservedObject var service = ShortcutService.shared
    @EnvironmentObject var notchBarViewModel: NotchBarViewModel
    @State private var showingEditor = false
    @State private var editMode = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Text(LocalizedStringKey("快捷方式"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
                
                // 调试信息
                Text("(\(service.shortcuts.count))")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
                
                Spacer()
                
                // 编辑按钮
                if !service.shortcuts.isEmpty {
                    Button(action: {
                        editMode.toggle()
                    }) {
                        Image(systemName: editMode ? "checkmark.circle.fill" : "pencil.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                    .help(editMode ? NSLocalizedString("完成", comment: "") : NSLocalizedString("编辑", comment: ""))
                }
                
                // 添加按钮
                Button(action: {
                    showingEditor = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
                .help(LocalizedStringKey("添加快捷方式"))
            }
            .padding(.horizontal, 16)
            
            // 快捷方式网格
            if service.shortcuts.isEmpty {
                // 空状态
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "app.dashed")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.3))
                        Text(LocalizedStringKey("暂无快捷方式"))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                        Text(LocalizedStringKey("点击 + 添加"))
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .padding(.vertical, 8)
                    Spacer()
                }
            } else {
                // 网格布局
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [
                        GridItem(.fixed(60))
                    ], spacing: 12) {
                        ForEach(service.shortcuts) { shortcut in
                            ShortcutItemButton(shortcut: shortcut, editMode: editMode) {
                                service.removeShortcut(shortcut.id)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 70)
            }
        }
        .sheet(isPresented: $showingEditor) {
            ShortcutEditorView()
                .environmentObject(notchBarViewModel)
        }
        .onChange(of: showingEditor) { _, isShowing in
            // Sheet 打开时暂停鼠标监听
            notchBarViewModel.shouldIgnoreMouseExit = isShowing
        }
    }
}

struct ShortcutItemButton: View {
    let shortcut: ShortcutItem
    let editMode: Bool
    let onDelete: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 4) {
                // 图标
                if let icon = shortcut.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                } else {
                    Image(systemName: "app")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(width: 32, height: 32)
                }
                
                // 名称
                Text(shortcut.name)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovered ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
            .onTapGesture {
                if !editMode {
                    shortcut.open()
                }
            }
            .help(shortcut.name)
            
            // 删除按钮（编辑模式显示）
            if editMode {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.red)
                        .background(
                            Circle()
                                .fill(.white)
                                .frame(width: 12, height: 12)
                        )
                }
                .buttonStyle(.plain)
                .offset(x: 6, y: -6)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: editMode)
    }
}

#Preview {
    ShortcutGridView()
        .frame(width: 600, height: 120)
        .background(Color.black)
}
