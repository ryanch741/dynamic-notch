//
//  TodoStore.swift
//  NotchIsland
//
//  待办事项的数据管理与持久化（使用 UserDefaults）
//

import Foundation
import Combine

final class TodoStore: ObservableObject {
    @Published var items: [TodoItem] = []

    private let storageKey = "NotchIsland.Todos"

    init() {
        loadItems()
    }

    func addItem(title: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newItem = TodoItem(title: title)
        items.append(newItem)
        saveItems()
    }

    func toggleCompletion(for item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
            saveItems()
        }
    }

    func deleteItem(at offsets: IndexSet) {
        let indicesToRemove = offsets.sorted(by: >)
        for index in indicesToRemove {
            if index < items.count {
                items.remove(at: index)
            }
        }
        saveItems()
    }

    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) else {
            return
        }
        items = decoded
    }
}
