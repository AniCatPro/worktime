// worktimeApp.swift
// Created by Павел Афанасьев on 28.11.2024.

import SwiftUI
import SwiftData

@main
struct WorktimeApp: App {
    @State private var isWindowVisible = true

    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    isWindowVisible = true
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
                .onDisappear {
                    isWindowVisible = false
                }
                .frame(width: 300, height: 250)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appTermination) {
                Button("Quit") {
                    NSApplication.shared.terminate(self)
                }
            }
        }
    }
}
