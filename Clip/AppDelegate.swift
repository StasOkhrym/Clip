import Cocoa
import HotKey
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate! = nil

    let hotKey = HotKey(key: .v, modifiers: [.command, .shift])
    private var windowManager: MyWindowManager!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AppDelegate.instance = self
        windowManager = MyWindowManager(clipboardManager: ClipboardManager())
        setupHotKey()
    }

    private func setupHotKey() {
        hotKey.keyDownHandler = {
            self.windowManager.openWindow()
        }
        hotKey.keyUpHandler = {
            self.windowManager.closeWindow()
        }
    }
    
    @objc private func handleCloseWindowNotification() {
        self.windowManager.closeWindow()
    }
}
