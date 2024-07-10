import SwiftUI


class ClipboardManager: ObservableObject {
    @Published var clipboardItems: [NSPasteboardItem] = []

    private var timer: Timer?
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = 0
    
    static let newItemNotification = Notification.Name("ClipboardManagerNewItemAtIndex")
    static let itemRemovedNotification = Notification.Name("ClipboardManagerItemRemovedAtIndex")


    init() {
        lastChangeCount = pasteboard.changeCount
        startMonitoring()
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    private func deepCopyItem(item: NSPasteboardItem) -> NSPasteboardItem {
        let newItem = NSPasteboardItem()
        
        for type in item.types {
            if let data = item.data(forType: type) {
                newItem.setData(data, forType: type)
            }
        }
        return newItem
    }

    func checkClipboard() {
        guard pasteboard.changeCount != lastChangeCount else {
            return
        }
        
        DispatchQueue.main.async {
            if let items = self.pasteboard.pasteboardItems {
                for item in items {
                    if !self.clipboardItems.contains(
                        // Compare based on string representation for simplicity
                        where: {
                            existingItem in 
                            existingItem.string(forType: .string) == item.string(forType: .string)
                        }
                    ){
                        if self.clipboardItems.count >= MAX_ITEM_COUNT {
                            NotificationCenter.default.post(
                                name: ClipboardManager.itemRemovedNotification,
                                object: self,
                                userInfo: ["item": self.clipboardItems[0]]
                            )
                            self.clipboardItems.removeFirst()
                        }
                        
                        let newItem = self.deepCopyItem(item: item)
                        
                        self.clipboardItems.append(newItem)
                        self.lastChangeCount = self.pasteboard.changeCount

                        NotificationCenter.default.post(
                            name: ClipboardManager.newItemNotification,
                            object: self,
                            userInfo: ["item": newItem]
                            
                        )
                    }
                }
            }
        }
    }


    func copyItemToClipboard(index: Int) {
        guard index >= 0 && index < clipboardItems.count else { return }

        pasteboard.clearContents()
        
        let item = clipboardItems[index]
        let newItem = self.deepCopyItem(item: item)
        
        pasteboard.writeObjects([newItem])
    }

    deinit {
        timer?.invalidate()
    }
}
