//
//  Window.swift
//  Clip
//
//  Created by Станіслав Охрим on 24.06.2024.
//
import SwiftUI
import AppKit

struct ClipboardWindowView: View {
    @StateObject private var clipboardManager = ClipboardManager()
    @State private var currentIndex = 0
    
    
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
            print("appeared")
            loadCurrentIndex()
            setupKeyHandlers()
            clipboardManager.checkClipboard()
        }
        .onDisappear {
            saveCurrentIndex()
            clipboardManager.copyItemToClipboard(index: currentIndex)
            
            
        }
    }
    
    private var currentItemView: some View {
        Group {
            if currentIndex < clipboardManager.clipboardItems.count {
                let currentItem = clipboardManager.clipboardItems[currentIndex]
                VStack {
                    switch currentItem.availableType(from: [.string, .tiff]) {
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
                        }
                    default:
                        Text("Unknown item")
                    }
                }
                .padding(.bottom, 10)
            } else {
                Text("Invalid index")
            }
        }
    }



    
    private var statusView: some View {
        HStack {
            Text("Item \(currentIndex + 1) of \(clipboardManager.clipboardItems.count)")
                .padding(.bottom, 5)
        }
    }
    
    private func setupKeyHandlers() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard let window = NSApp.mainWindow?.windowController?.window,
                  NSApplication.shared.keyWindow === window else {
                return event
            }

            guard !event.isARepeat else {
                return nil // Ignore repeated key events
            }

            switch event.keyCode {
            case 123: // Left arrow key
                currentIndex = max(0, currentIndex - 1)
                print("Left arrow key pressed")
                return nil // Consume the event
            case 124: // Right arrow key
                currentIndex = min(clipboardManager.clipboardItems.count - 1, currentIndex + 1)
                print("Right arrow key pressed")
                return nil // Consume the event
            default:
                return event
            }
        }
    }

    
    private func handleKeyEvent(_ event: NSEvent) {
        switch event.keyCode {
        case 123: // Left arrow key
            currentIndex = max(0, currentIndex - 1)
        case 124: // Right arrow key
            currentIndex = min(clipboardManager.clipboardItems.count - 1, currentIndex + 1)
        default:
            break
        }
    }
    
    private func saveCurrentIndex() {
        UserDefaults.standard.set(currentIndex, forKey: currentIndexKey)
    }
    
    private func loadCurrentIndex() {
        if let savedIndex = UserDefaults.standard.object(forKey: currentIndexKey) as? Int {
            currentIndex = savedIndex
        } else {
            currentIndex = 0 // Default value if no index is saved
        }
        
        // Ensure currentIndex is within bounds
        if currentIndex < 0 || currentIndex >= clipboardManager.clipboardItems.count {
            currentIndex = 0 // Reset to first item if saved index is out of bounds
        }
    }
}
