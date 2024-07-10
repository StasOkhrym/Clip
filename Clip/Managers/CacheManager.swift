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
        guard let newItems = notification.userInfo?["items"] as? [NSPasteboardItem] else { return }
        
        for newItem in newItems {
            if let fileURLString = newItem.string(forType: .fileURL),
               let fileURL = URL(string: fileURLString.removingPercentEncoding ?? fileURLString) {
                removeCachedText(for: fileURL)
                loadCachedText(for: fileURL)
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

    func loadCachedText(for fileURL: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            if let fileHandle = try? FileHandle(forReadingFrom: fileURL) {
                defer {
                    try? fileHandle.close()
                }
                
                let data = fileHandle.readData(ofLength: self.chunkSize)
                
                if let chunk = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.cachedText[fileURL] = chunk
                    }
                }
            }
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


