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
    private let maxItemsCount = 20
    private let pasteboardName = "com.example.MyApp.ClipboardItems"

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
        guard let items = pasteboard.pasteboardItems else {
            return
        }

        for item in items {
            if !isDuplicateClipboardItem(item) {
                addClipboardItem(item)
            }
        }
    }

    private func isDuplicateClipboardItem(_ newItem: NSPasteboardItem) -> Bool {
        guard let lastItem = clipboardItems.last else {
            return false
        }

        return newItem.types == lastItem.types && newItem.data(forType: .string) == lastItem.data(forType: .string)
    }

    private func addClipboardItem(_ item: NSPasteboardItem) {
        if clipboardItems.count >= maxItemsCount {
            clipboardItems.removeFirst()
        }
        clipboardItems.append(item)
        saveClipboardItems()
    }

    private func saveClipboardItems() {
        var archivedItems: [Data] = []

        for item in clipboardItems {
            let data = try? NSKeyedArchiver.archivedData(withRootObject: item, requiringSecureCoding: false)
            archivedItems.append(data ?? Data())
        }

        pasteboard.declareTypes([.string], owner: nil)
        do {
            pasteboard.setData(try NSKeyedArchiver.archivedData(withRootObject: archivedItems, requiringSecureCoding: false), forType: .tiff)
        } catch {
            print("g")
        }
        }

    private func loadClipboardItems() {
        guard let archivedItemsData = pasteboard.data(forType: .tiff) else {
            return
        }

        do {
            let archivedItems = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedItemsData) as? [Data] ?? []
            var items: [NSPasteboardItem] = []

            for archivedData in archivedItems {
                if let item = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedData) as? NSPasteboardItem {
                    items.append(item)
                }
            }

            clipboardItems = items
        } catch {
            print("Failed to load clipboard items: \(error)")
        }
    }

    func copyItemToClipboard(index: Int) {
        guard index >= 0 && index < clipboardItems.count else { return }

        let currentItem = clipboardItems[index]
        pasteboard.clearContents()

        let newPasteboardItem = NSPasteboardItem()
        currentItem.types.forEach { type in
            if let data = currentItem.data(forType: type) {
                newPasteboardItem.setData(data, forType: type)
            }
        }

        pasteboard.writeObjects([newPasteboardItem])
    }

    deinit {
        pasteboard.clearContents()
        timer?.invalidate()
    }
}
