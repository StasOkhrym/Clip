//
//  Window.swift
//  Clip
//
//  Created by Станіслав Охрим on 24.06.2024.
//
import SwiftUI


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
                    switch currentItem.availableType(from: [.string, .tiff, .fileURL]) {
                    case .string:
                        if let text = currentItem.string(forType: .string) {
                            Text(text)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .padding(.horizontal)
                                .padding(.top)
                        } else {
                            Text("Invalid text data")
                        }
                    case .tiff:
                        if let imageData = currentItem.data(forType: .tiff),
                           let nsImage = NSImage(data: imageData) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            Text("Invalid image data")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .padding(.horizontal)
                                .padding(.top)
                        }
                    case .fileURL:
                        if let fileURLString = currentItem.string(forType: .fileURL),
                           let fileURL = URL(string: fileURLString) {
                            handleFileURL(fileURL)
                        } else {
                            Text("Invalid file URL")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .padding(.horizontal)
                                .padding(.top)
                        }
                    default:
                        Text("Unknown item \(currentItem.types) \(currentItem.data(forType: .string))")
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(.horizontal)
                            .padding(.top)
                    }
                }
        }
    }

    private var statusView: some View {
        HStack {
            Text("Item \(currentIndex + 1) of \(clipboardManager.clipboardItems.count)")
                .padding(.bottom, 5)
        }
    }

    private func handleFileURL(_ fileURL: URL) -> some View {
        let fileExtension = fileURL.pathExtension.lowercased()
        if fileExtension == "jpg" || fileExtension == "png" || fileExtension == "gif" {
            if let nsImage = NSImage(contentsOf: fileURL) {
                return AnyView(
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                )
            }
        } else if fileExtension == "txt" {
            if let text = try? String(contentsOf: fileURL, encoding: .utf8) {
                return AnyView(
                    Text(text)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.horizontal)
                        .padding(.top)
                )
            }
        }
        return AnyView(Text("Unsupported file type"))
    }

    private func setupKeyHandlers() {
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                // Ignore repeated key events
                guard !event.isARepeat else {
                    return nil
                }

                switch event.keyCode {
                case 123: // Left arrow key
                    currentIndex = max(0, currentIndex - 1)
                    return event
                case 124: // Right arrow key
                    currentIndex = min(clipboardManager.clipboardItems.count - 1, currentIndex + 1)
                    return event
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
