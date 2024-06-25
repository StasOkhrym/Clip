//
//  ClipApp.swift
//  Clip
//
//  Created by Станіслав Охрим on 24.06.2024.
//

import SwiftUI

@main
struct ClipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var clipboardManager = ClipboardManager()

    var body: some Scene {
        MenuBarExtra("ClipApp", systemImage: "hammer") {
            ContentView()
            .environmentObject(clipboardManager)

        }.menuBarExtraStyle(.window)
    }
}
