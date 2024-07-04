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
    @Published private var window: NSWindow?
    private var clipboardManager: ClipboardManager
    
    init(clipboardManager: ClipboardManager) {
        self.clipboardManager = clipboardManager
        super.init()
    }
    
    deinit {
    }
    
    func openWindow() {
        if window == nil {
            let windowSize = NSSize(width: 800, height: 800)
            
            window = NSWindowModified(contentRect: NSRect(origin: .zero, size: windowSize),
                              styleMask: [], // Nothing will interupt
                              backing: .buffered,
                              defer: false)
            window?.center()
            window?.setFrameAutosaveName("MySpecificWindow")
            window?.contentView = NSHostingView(rootView: ClipboardWindowView().environmentObject(clipboardManager))
            window?.delegate = self
            window?.makeKeyAndOrderFront(nil)
        } else {
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
