//
//  Window.swift
//  Clip
//
//  Created by Станіслав Охрим on 24.06.2024.
//
import SwiftUI

let SUPPORTED_TYPE: [NSPasteboard.PasteboardType] = [
    .string,
    .png,
    .tiff,
    .fileURL,
    .URL,
    .fileContents
]

struct ClipboardWindowView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var currentIndex = 0
    @State private var eventMonitor: Any?
    @State private var frontmostApplication: NSRunningApplication?

    var body: some View {
        VStack {
            if !clipboardManager.clipboardItems.isEmpty {
                currentItemView
                statusView
            } else {
                Text("No clipboard items")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            loadCurrentIndex()
            setupKeyHandlers()
            
            // Store application over which window was opened
            // in order to pass focus back to it after window is closed
            self.frontmostApplication = NSWorkspace.shared.frontmostApplication

            // Ensure the current app is activated when the window opens
            NSApp.activate(ignoringOtherApps: true)
        }
        .onDisappear {
            saveCurrentIndex()
            removeKeyHandlers()
            
            clipboardManager.copyItemToClipboard(index: currentIndex)
            
            NSApp.activate(ignoringOtherApps: false)

            if let previousApp = self.frontmostApplication {
                previousApp.activate(options: .activateAllWindows)
            }
        }
    }
    
    private func centerWindow(_ window: NSWindow) {
        if let screenVisibleFrame = NSScreen.main?.visibleFrame {
            let xPos = (screenVisibleFrame.width - window.frame.width) / 2 + screenVisibleFrame.origin.x
            let yPos = (screenVisibleFrame.height - window.frame.height) / 2 + screenVisibleFrame.origin.y
            window.setFrame(NSRect(x: xPos, y: yPos, width: window.frame.width, height: window.frame.height), display: true)
        }
    }

    private var currentItemView: some View {
        Group {
            let currentItem = clipboardManager.clipboardItems[currentIndex]
            
            VStack {
                 if let view = createView(for: currentItem) {
                     view
                 } else {
                     Text("Unsupported content")
                         .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                         .padding(.horizontal)
                         .padding(.top)
                 }
             }
             .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
             .padding(.horizontal)
             .padding(.top)
         }
    }
    
    
    private func createView(for item: NSPasteboardItem) -> AnyView? {
        if let text = item.string(forType: .string) {
            return AnyView(Text(text))
        }
        return nil
    }

    private var statusView: some View {
        HStack {
            Text("Item \(currentIndex + 1) of \(clipboardManager.clipboardItems.count)")
                .padding(.bottom, 5)
        }
    }
    
    private func playAlertSound() {
        NSSound.beep()
    }

    private func setupKeyHandlers() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Ignore repeated key events
            guard !event.isARepeat else {
                return nil
            }

            switch event.keyCode {
            case 123: // Left arrow key
                if currentIndex > 0 {
                    currentIndex = max(0, currentIndex - 1)
                } else {
                    // Indicate that you are at the last item
                    playAlertSound()
                }
                return nil
            case 124: // Right arrow key
                if currentIndex < clipboardManager.clipboardItems.count - 1 {
                    currentIndex = min(clipboardManager.clipboardItems.count - 1, currentIndex + 1)
                } else {
                    // Indicate that you are at the last item
                    playAlertSound()
                }
                return nil
            default:
                return event
            }
        }
    }

    
    private func removeKeyHandlers() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }


    private func saveCurrentIndex() {
        UserDefaults.standard.set(currentIndex, forKey: "currentIndexKey")
    }

    private func loadCurrentIndex() {
        if let savedIndex = UserDefaults.standard.object(forKey: "currentIndexKey") as? Int {
            currentIndex = savedIndex
        } else {
            currentIndex = 0
        }

        if currentIndex < 0 || currentIndex >= clipboardManager.clipboardItems.count {
            currentIndex = 0
        }
    }
}
