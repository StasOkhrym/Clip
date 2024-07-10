import SwiftUI


struct ClipboardWindowView: View {
    @ObservedObject var controller: ClipboardWindowController

    internal init(controller: ClipboardWindowController) {
        self.controller = controller
    }

    var body: some View {
        VStack {
            if !controller.clipboardManager.clipboardItems.isEmpty {
                currentItemView
                statusView
            } else {
                Text("No clipboard items")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            controller.loadCurrentIndex()
            controller.setupKeyHandlers()
            controller.storeFrontmostApplication()

            // Ensure the current app is activated when the window opens
            NSApp.activate(ignoringOtherApps: true)
        }
        .onDisappear {
            controller.saveCurrentIndex()
            controller.cleanup()
            controller.clipboardManager.copyItemToClipboard(index: controller.currentIndex)

            // Restore focus to the previous frontmost application
            controller.activateCurrentApp()
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
            let currentItem = controller.clipboardManager.clipboardItems[controller.currentIndex]
            
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
            //let decodedURLString = fileURLString.removingPercentEncoding ?? fileURLString
            if let fileURL = URL(string: fileURLString) {
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
        else if let text = controller.cacheManager.getText(fileURL: fileURL) {
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
            Text("Item \(controller.currentIndex + 1) of \(controller.clipboardManager.clipboardItems.count)")
                .padding(.bottom, 5)
        }
    }
}
