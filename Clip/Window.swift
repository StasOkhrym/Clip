//
//  Window.swift
//  Clip
//
//  Created by Станіслав Охрим on 24.06.2024.
//
import SwiftUI
import AppKit

class MyWindowManager: NSObject, ObservableObject, NSWindowDelegate {
    @Published private var window: NSWindow?

    override init() {
        super.init()
        print("MyWindowManager initialized")
    }
    
    deinit {
        print("MyWindowManager deinitialized")
    }

    func openWindow() {
        print("Attempting to open window...")
        if window == nil {
            let contentRect = NSRect(x: 0, y: 0, width: 480, height: 300)
            window = NSWindow(
                contentRect: contentRect,
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window?.title = "My Specific Window"
            window?.center()
            window?.setFrameAutosaveName("MySpecificWindow")
            window?.contentView = NSHostingView(rootView: SpecificWindowContentView(manager: self))
            window?.delegate = self
            window?.makeKeyAndOrderFront(nil)
            print("Window opened successfully.")
        } else {
            window?.makeKeyAndOrderFront(nil)
            print("Window already exists, bringing it to front.")
        }
    }

    func closeWindow() {
        print("Attempting to close window...")
        guard let window = window else {
            print("No window to close.")
            return
        }
        window.orderOut(nil)
//        window.delegate = nil
//        window.close()
        
        self.window = nil
        print("Window closed.")
    }

    func windowWillClose(_ notification: Notification) {
        print("Window will close, releasing resources.")
        window = nil
    }
}

struct SpecificWindowContentView: View {
    @ObservedObject var manager: MyWindowManager
    
    var body: some View {
        VStack {
            Text("My Specific Window Content")
                .font(.title)
                .padding()
            Button("Close Window") {
                manager.closeWindow()
            }
            .padding()
        }
    }
}
