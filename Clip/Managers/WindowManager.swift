//
//  WindowManager.swift
//  Clip
//
//  Created by Станіслав Охрим on 25.06.2024.
//

import SwiftUI
import AppKit


// To avoid
// Warning: -[NSWindow makeKeyWindow] called on NSWindow 0x10b704620 which returned NO from -[NSWindow canBecomeKeyWindow].
class NSWindowModified: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
}

class MyWindowManager: NSObject, ObservableObject, NSWindowDelegate {
    @Published private var window: NSWindowModified?
    private var clipboardManager: ClipboardManager

    init(clipboardManager: ClipboardManager) {
        self.clipboardManager = clipboardManager
        super.init()
    }

    func openWindow() {
        if window == nil {
            let windowSize = NSSize(width: 800, height: 600)

            window = NSWindowModified(contentRect: NSRect(origin: .zero, size: windowSize),
                                     styleMask: [],
                                     backing: .buffered,
                                     defer: false)
            window?.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.7)
            window?.center()

            window?.contentView = NSHostingView(rootView: ClipboardWindowView().environmentObject(clipboardManager))
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
    }

    func windowWillClose(_ notification: Notification) {
        window = nil
    }

}
