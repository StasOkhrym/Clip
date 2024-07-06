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
        // Filepaths are trated as strings so check them first
        if let fileURLString = item.string(forType: .fileURL) {
            // Decode the URL string
            let decodedURLString = fileURLString.removingPercentEncoding ?? fileURLString
            if let fileURL = URL(string: decodedURLString) {
                return previewForFileURL(fileURL)
            }
        }

        // Check for string content
        if let text = item.string(forType: .string) {
            return AnyView(
                VStack{
                    Text("Text in the buffer")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .padding(.bottom, 10)
                        .cornerRadius(8)
                    
                    Text(text)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.horizontal)
                        .padding(.top)
                }
            )
        }
        
        // Check for image data (PNG or JPEG)
        if item.types.contains(.png) || item.types.contains(.tiff) || item.types.contains(.pdf) {
            if let imageData = item.data(forType: .png) ?? item.data(forType: .tiff) ?? item.data(forType: .pdf), let nsImage = NSImage(data: imageData) {
                return AnyView(
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                )
            }
        }

        return nil
    }
    
    private func previewForFileURL(_ fileURL: URL) -> AnyView? {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        // Handle different file types
        if let nsImage = NSImage(contentsOf: fileURL) {
            return AnyView(
                VStack{
                    Text("File: \(fileURL.relativePath)")                  
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .padding(.bottom, 10)
                        .cornerRadius(8)
                    HStack{
                        Spacer()
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.horizontal)
                        Spacer()
                    }
                    
                }
            )
        } 
        else if let text = try? String(contentsOf: fileURL, encoding: .utf8) {
            // Any text file encoded UTF-8 will have a preview
            return AnyView(
                VStack {
                    Text("File: \(fileURL.relativePath)")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .padding(.bottom, 10)
                        .cornerRadius(8)
                    Text(text)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.horizontal)
                        .padding(.top)
                }
            )
        }
        else {
            // Consider this as a binary files or other extensions which may be in WIP
            return AnyView(
                VStack {
                    Text("FIle in the buffer")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .padding(.bottom, 10)
                        .cornerRadius(8)
                    Text(fileURL.relativePath)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.horizontal)
                        .padding(.top)
                    
                }
            )
        }
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
