import SwiftUI

@main
struct ClipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var clipboardManager = ClipboardManager()
    @StateObject private var cacheManager = CacheManager()

    var body: some Scene {
        MenuBarExtra("ClipApp", systemImage: "paperclip") {
            ContentView()
            .environmentObject(clipboardManager)
            .environmentObject(cacheManager)

        }.menuBarExtraStyle(.window)
    }
}
