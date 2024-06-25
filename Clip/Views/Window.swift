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
    
    private let currentIndexKey = "CurrentIndexKey"
    
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
        }
        .onDisappear {
            saveCurrentIndex()
            copyCurrentItemToClipboard()
        }
    }
    
    private func copyCurrentItemToClipboard() {
        guard !clipboardManager.clipboardItems.isEmpty else { return }
        
        let currentItem = clipboardManager.clipboardItems[currentIndex]
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        switch currentItem {
        case .text(let text):
            pasteboard.setString(text, forType: .string)
        case .image(let imageData):
            if let nsImage = NSImage(data: imageData) {
                pasteboard.writeObjects([nsImage])
            }
        case .unknown:
            // Handle unknown type if needed
            break
        }
    }
    
    private var currentItemView: some View {
        let currentItem = clipboardManager.clipboardItems[currentIndex]
        return Group {
            switch currentItem {
            case .text(let text):
                Text(text)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.horizontal)
                    .padding(.top)
            case .image(let imageData):
                if let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("Invalid image data")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            case .unknown:
                Text("Unknown item")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .padding(.bottom, 10)
    }
    
    private var statusView: some View {
        HStack {
            Text("Item \(currentIndex + 1) of \(clipboardManager.clipboardItems.count)")
                .padding(.bottom, 5)
        }
    }
    
    private func setupKeyHandlers() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 123 || event.keyCode == 124 {
                handleKeyEvent(event)
            }
            return event
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
