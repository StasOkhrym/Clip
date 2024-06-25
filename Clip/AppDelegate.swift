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
    
    func applicationWillTerminate(_ notification: Notification) {
        UserDefaults.standard.removeObject(forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: currentIndexKey)
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
