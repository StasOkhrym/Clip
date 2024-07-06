import SwiftUI

@main
struct ClipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var clipboardManager = ClipboardManager()

    var body: some Scene {
        MenuBarExtra("ClipApp", systemImage: "paperclip") {
            ContentView()
            .environmentObject(clipboardManager)

        }.menuBarExtraStyle(.window)
    }
}
