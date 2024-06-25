//
//  WindowManager.swift
//  Clip
//
//  Created by Станіслав Охрим on 25.06.2024.
//

import SwiftUI
import AppKit

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
            
            window = NSWindow(contentRect: NSRect(origin: .zero, size: windowSize),
                              styleMask: [], // Nothing will interupt
                              backing: .buffered,
                              defer: false)
            window?.center()
            
            let hostingView = NSHostingView(rootView: ClipboardWindowView())
            hostingView.frame = (window?.contentRect(forFrameRect: (window?.frame)!))!
            window?.contentView = hostingView
            
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

