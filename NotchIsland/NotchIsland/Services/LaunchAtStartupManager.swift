//
//  LaunchAtStartupManager.swift
//  NotchIsland
//
//  Created by Ryan on 2026/1/17.
//

import Foundation
import ServiceManagement

class LaunchAtStartupManager: ObservableObject {
    
    @Published var isEnabled: Bool = false
    
    init() {
        updateStatus()
    }
    
    private func updateStatus() {
        isEnabled = SMAppService.mainAppCurrentProcessIsEnabled()
    }
    
    func setLaunchAtStartup(_ enabled: Bool) async throws {
        do {
            if enabled {
                try SMAppService.registerAppAsLoginItem()
            } else {
                try SMAppService.unregisterAppAsLoginItem()
            }
            updateStatus()
        } catch {
            print("Failed to update launch at startup setting: \(error)")
            throw error
        }
    }
    
    func toggleLaunchAtStartup() async {
        do {
            try await setLaunchAtStartup(!isEnabled)
        } catch {
            print("Failed to toggle launch at startup: \(error)")
        }
    }
}