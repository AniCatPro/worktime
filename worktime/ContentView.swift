// ContentView.swift
// Created by Павел Афанасьев on 28.11.2024.

import SwiftUI

class StatusBarManager: NSObject {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    @objc func statusBarButtonClicked() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first, !window.isVisible {
            window.makeKeyAndOrderFront(self)
        }
    }

    func updateStatusBar(isWorkingHours: Bool, timeToEnd: String) {
        if let button = statusItem.button {
            button.title = isWorkingHours ? "До конца: \(timeToEnd)" : "Не рабочее время"
            button.action = #selector(statusBarButtonClicked)
            button.target = self
        }
    }

    func removeStatusBar() {
        NSStatusBar.system.removeStatusItem(statusItem)
    }
}

struct ContentView: View {
    @State private var isShortDay = false
    @State private var currentTime = Date()
    @State private var timer: Timer?
    @State private var workStartTime = Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: Date())!
    @State private var workEndTime = Calendar.current.date(bySettingHour: 16, minute: 30, second: 0, of: Date())!
    @State private var lunchTime = Calendar.current.date(bySettingHour: 12, minute: 30, second: 0, of: Date())!
    @State private var showInStatusBar = true
    
    private let statusBarManager = StatusBarManager()

    var adjustedEndTime: Date {
        isShortDay ? Calendar.current.date(byAdding: .hour, value: -1, to: workEndTime)! : workEndTime
    }
    
    var timeToLunch: String {
        if currentTime < lunchTime {
            return formatTimeDifference(from: currentTime, to: lunchTime)
        } else {
            return "Обед закончился"
        }
    }
    
    var timeToEnd: String {
        if currentTime < adjustedEndTime {
            return formatTimeDifference(from: currentTime, to: adjustedEndTime)
        } else {
            return "Рабочий день завершен"
        }
    }
    
    var isWorkingHours: Bool {
        currentTime >= workStartTime && currentTime <= adjustedEndTime
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Обратный отсчет рабочего дня")
                .font(.headline)
            
            if isWorkingHours {
                VStack(spacing: 10) {
                    Text("До обеда: \(timeToLunch)")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("До конца рабочего дня: \(timeToEnd)")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            } else {
                Text("Сейчас не рабочее время")
                    .foregroundColor(.gray)
                    .font(.title3)
            }

            Toggle("Сокращенный день (на 1 час меньше)", isOn: $isShortDay)
                .padding()

            Toggle("Показывать таймер в панели задач", isOn: $showInStatusBar)
                .padding()
                .onChange(of: showInStatusBar) { newValue in
                    if newValue {
                        updateStatusBar()
                    } else {
                        statusBarManager.removeStatusBar()
                    }
                }

            VStack(alignment: .leading, spacing: 10) {
                Text("Настройки рабочего времени")
                    .font(.headline)
                HStack {
                    Text("Начало:")
                    DatePicker("", selection: $workStartTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                HStack {
                    Text("Конец:")
                    DatePicker("", selection: $workEndTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
            }
            .padding()

            Button("Скрыть приложение") {
                hideWindow()
            }
            .padding()
            
            Button("Закрыть приложение полностью") {
                NSApplication.shared.terminate(self)
            }
            .padding()
        }
        .padding()
        .onAppear {
            startTimer()
        }
        .onDisappear(perform: stopTimer)
        .frame(minWidth: 300, minHeight: 200)
    }
    
    func formatTimeDifference(from start: Date, to end: Date) -> String {
        let diff = Calendar.current.dateComponents([.hour, .minute, .second], from: start, to: end)
        return String(format: "%02d:%02d:%02d", diff.hour ?? 0, diff.minute ?? 0, diff.second ?? 0)
    }
    
    func startTimer() {
        if showInStatusBar {
            updateStatusBar()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            currentTime = Date()
            if showInStatusBar {
                updateStatusBar()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        statusBarManager.removeStatusBar()
    }
    
    func updateStatusBar() {
        statusBarManager.updateStatusBar(isWorkingHours: isWorkingHours, timeToEnd: timeToEnd)
    }
    
    func hideWindow() {
        NSApplication.shared.hide(self)
    }
}
