import SwiftUI
import Combine
import AppKit


class CacheManager: ObservableObject {
    @Published var cachedText: [URL: String] = [:]
    private let chunkSize: Int = 2 << 10 // 4 KB
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewItemNotification(_:)),
            name: ClipboardManager.newItemNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleItemRemovedNotification(_:)),
            name: ClipboardManager.itemRemovedNotification,
            object: nil
        )
    }

    @objc func handleNewItemNotification(_ notification: Notification) {
        guard let newItem = notification.userInfo?["item"] as? NSPasteboardItem else { return }

        if let fileURLString = newItem.string(forType: .fileURL),
           let fileURL = URL(string: fileURLString.removingPercentEncoding ?? fileURLString) {
            removeCachedText(for: fileURL)
            
            let text = readFile(fileURL: fileURL)
            if let text = text {
                cachedText[fileURL] = text
            }
        }
    }

    @objc func handleItemRemovedNotification(_ notification: Notification) {
        guard let removedItem = notification.userInfo?["item"] as? NSPasteboardItem else { return }

        if let fileURLString = removedItem.string(forType: .fileURL),
           let fileURL = URL(string: fileURLString.removingPercentEncoding ?? fileURLString) {
            removeCachedText(for: fileURL)
        }
    }

    func readFile(fileURL: URL) -> String? {
        if let cachedText = cachedText[fileURL] {
            return cachedText
        }

        guard let fileHandle = try? FileHandle(forReadingFrom: fileURL) else {
            return nil
        }

        defer {
            try? fileHandle.close()
        }

        let data = fileHandle.readData(ofLength: chunkSize)

        if let chunk = String(data: data, encoding: .utf8) {
            cachedText[fileURL] = chunk
            return chunk
        } else {
            return nil
        }
    }

    func getText(fileURL: URL) -> String? {
        return cachedText[fileURL]
    }

    func removeCachedText(for fileURL: URL) {
        cachedText.removeValue(forKey: fileURL)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


