//
//  TodoListView.swift
//  NotchIsland
//
//  待办列表视图，用于在弹出菜单中展示和管理 Todo
//

import SwiftUI

struct TodoListView: View {
    @ObservedObject var todoStore: TodoStore
    @State private var newTodoTitle: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("待办事项")
                .font(.headline)

            HStack {
                TextField("新建待办…", text: $newTodoTitle)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        addTodo()
                    }
                Button("添加") {
                    addTodo()
                }
                .keyboardShortcut(.return, modifiers: [])
            }

            Divider()

            if todoStore.items.isEmpty {
                Text("暂无待办事项")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(todoStore.items) { item in
                            TodoItemRow(item: item, todoStore: todoStore)
                        }
                    }
                }
                .frame(maxHeight: 200)
            }

            Spacer()
        }
        .padding()
        .frame(minWidth: 320, minHeight: 240)
    }

    private func addTodo() {
        todoStore.addItem(title: newTodoTitle)
        newTodoTitle = ""
    }
}

struct TodoItemRow: View {
    let item: TodoItem
    @ObservedObject var todoStore: TodoStore

    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                todoStore.toggleCompletion(for: item)
            }) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            Text(item.title)
                .strikethrough(item.isCompleted, color: .secondary)
                .foregroundStyle(item.isCompleted ? .secondary : .primary)
                .font(.subheadline)

            Spacer()

            Button(action: {
                if let index = todoStore.items.firstIndex(where: { $0.id == item.id }) {
                    todoStore.deleteItem(at: IndexSet(integer: index))
                }
            }) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.primary.opacity(0.03))
        )
    }
}

#Preview {
    TodoListView(todoStore: TodoStore())
}
