//
//  ClipboardManager.swift
//  Clip
//
//  Created by Станіслав Охрим on 25.06.2024.
//
import SwiftUI
import Combine
import AppKit




class ClipboardManager: ObservableObject {
    @Published var clipboardItems: [NSPasteboardItem] = []

    private var timer: Timer?
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = 0

    init() {
        lastChangeCount = pasteboard.changeCount
        startMonitoring()
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    func checkClipboard() {
        guard pasteboard.changeCount != lastChangeCount else {
            return
        }
        
        lastChangeCount = pasteboard.changeCount
        
        DispatchQueue.main.async {
            if let items = self.pasteboard.pasteboardItems {
                for item in items {
                    if !self.clipboardItems.contains(where: { $0.string(forType: .string) == item.string(forType: .string) }) {
                        if self.clipboardItems.count >= 20 {
                            self.clipboardItems.removeFirst()
                        }
                        self.clipboardItems.append(item) // Create a copy to avoid reuse issues
                        self.objectWillChange.send()
                        print(self.clipboardItems.count)
                    }
                }
            }
        }
    }

    func copyItemToClipboard(index: Int) {
        guard index >= 0 && index < clipboardItems.count else {
            return
        }

        let item = clipboardItems[index]
        let newItem = NSPasteboardItem()

        // Copy data for each type in the item
        item.types.forEach { type in
            switch type {
            case .string:
                if let string = item.string(forType: .string) {
                    newItem.setString(string, forType: .string)
                }
            case .tiff:
                if let tiffData = item.data(forType: .tiff) {
                    newItem.setData(tiffData, forType: .tiff)
                }
            case .fileURL:
                if let fileURLString = item.string(forType: .fileURL),
                   let fileURL = URL(string: fileURLString) {
                    newItem.setString(fileURL.absoluteString, forType: .fileURL)
                }
            default:
                break
            }
        }

        pasteboard.clearContents()
        pasteboard.writeObjects([newItem])
    }


    deinit {
        timer?.invalidate()
        print("ClipboardManager deinitialized")
    }
}
