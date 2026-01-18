//
//  LaunchAtStartupManager.swift
//  NotchIsland
//
//  Created by Ryan on 2026/1/17.
//

import Foundation
import ServiceManagement
import Combine

class LaunchAtStartupManager: ObservableObject {
    
    @Published var isEnabled: Bool = false
    
    private let service = SMAppService.mainApp
    
    init() {
        updateStatus()
    }
    
    func updateStatus() {
        isEnabled = service.status == .enabled
    }
    
    func setLaunchAtStartup(_ enabled: Bool) {
        do {
            if enabled {
                try service.register()
            } else {
                try service.unregister()
            }
            updateStatus()
        } catch {
            print("Failed to update launch at startup setting: \(error)")
        }
    }
    
    func toggleLaunchAtStartup() {
        setLaunchAtStartup(!isEnabled)
    }
}