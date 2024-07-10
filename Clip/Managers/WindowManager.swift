import SwiftUI
import AppKit


// To avoid
// Warning: -[NSWindow makeKeyWindow] called on NSWindow <address> which returned NO from -[NSWindow canBecomeKeyWindow].
class NSWindowModified: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
}


class WindowManager: NSObject, ObservableObject, NSWindowDelegate {
    @Published private var window: NSWindowModified?
    private var clipboardManager: ClipboardManager
    private var cacheManager: CacheManager
    private var controller: ClipboardWindowController?

    init(clipboardManager: ClipboardManager, cacheManager: CacheManager) {
        self.clipboardManager = clipboardManager
        self.cacheManager = cacheManager
        super.init()
    }

    func openWindow() {
        if window == nil {
            let windowSize = NSSize(width: 800, height: 600)

            window = NSWindowModified(contentRect: NSRect(origin: .zero, size: windowSize),
                                      styleMask: [],
                                      backing: .buffered,
                                      defer: false)
            
            window?.backgroundColor = NSColor.clear
            window?.isOpaque = false
            window?.hasShadow = true
            window?.level = .floating
            window?.center()

            controller = ClipboardWindowController(clipboardManager: clipboardManager, cacheManager: cacheManager)

            let hostingView = NSHostingView(
                rootView: ClipboardWindowView(controller: controller!)
                            .environmentObject(clipboardManager)
                            .environmentObject(cacheManager)
            )
            hostingView.wantsLayer = true
            hostingView.layer?.cornerRadius = 8
            hostingView.layer?.masksToBounds = true
            hostingView.layer?.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor

            window?.contentView = hostingView
            window?.delegate = self
            window?.makeKeyAndOrderFront(nil)
        } else {
            window?.center()
            window?.makeKeyAndOrderFront(nil)
        }
    }
    
    func closeWindow() {
        guard let window = window else {
            return
        }
        window.orderOut(nil)
        self.window = nil
        
        controller = nil
    }

    func windowWillClose(_ notification: Notification) {
        window = nil
    }

    func getWindow() -> NSWindow? {
        return self.window
    }
}
