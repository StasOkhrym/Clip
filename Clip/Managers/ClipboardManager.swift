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
    private let storageKey = "ClipboardItems"
    private let maxItemsCount = 20
    
    init() {
        loadClipboardItems()
        startMonitoring()
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    func checkClipboard() {
        let pasteboard = NSPasteboard.general
        guard let items = pasteboard.pasteboardItems else {
            return
        }
        
        for item in items {
            // Check for text content
            if let string = item.string(forType: .string) {
                if !isDuplicateClipboardItem(item) {
                    addClipboardItem(item)
                }
            }
            
            // Check for image content
            if let imageData = item.data(forType: .tiff) {
                if !isDuplicateClipboardItem(item) {
                    addClipboardItem(item)
                }
            }
        }
    }
    
    private func isDuplicateClipboardItem(_ newItem: NSPasteboardItem) -> Bool {
        guard let lastItem = clipboardItems.last else {
            return false
        }
        
        // Compare pasteboard items based on types you are interested in
        if let lastString = lastItem.string(forType: .string), let newString = newItem.string(forType: .string) {
            return lastString == newString
        }
        
        if let lastData = lastItem.data(forType: .tiff), let newData = newItem.data(forType: .tiff) {
            return lastData == newData
        }
        
        return false
    }
    
    private func addClipboardItem(_ item: NSPasteboardItem) {
        if clipboardItems.count >= maxItemsCount {
            clipboardItems.removeFirst()
        }
        clipboardItems.append(item)
        saveClipboardItems()
    }
    
    private func saveClipboardItems() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: clipboardItems, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save clipboard items: \(error)")
        }
    }

    
    private func loadClipboardItems() {
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            do {
                if let loadedItems = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [NSPasteboardItem] {
                    clipboardItems = loadedItems
                }
            } catch {
                print("Failed to load clipboard items: \(error)")
            }
        }
    }

    
    func copyItemToClipboard(index: Int) {
        guard index >= 0 && index < clipboardItems.count else { return }
        
        let currentItem = clipboardItems[index]
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        pasteboard.writeObjects([currentItem])
    }
    
    deinit {
        UserDefaults.standard.removeObject(forKey: storageKey)
        timer?.invalidate()
    }
}
