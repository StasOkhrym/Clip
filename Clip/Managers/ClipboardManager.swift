//
//  ClipboardManager.swift
//  Clip
//
//  Created by Станіслав Охрим on 25.06.2024.
//
import SwiftUI
import Combine

enum ClipboardItem: Identifiable, Codable {
    case text(String)
    case image(Data)
    case unknown
    
    var id: UUID {
        return UUID()
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case text
        case image
    }
    
    enum ItemType: String, Codable {
        case text
        case image
        case unknown
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ItemType.self, forKey: .type)
        switch type {
        case .text:
            let text = try container.decode(String.self, forKey: .text)
            self = .text(text)
        case .image:
            let imageData = try container.decode(Data.self, forKey: .image)
            self = .image(imageData)
        case .unknown:
            self = .unknown
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode(ItemType.text, forKey: .type)
            try container.encode(text, forKey: .text)
        case .image(let imageData):
            try container.encode(ItemType.image, forKey: .type)
            try container.encode(imageData, forKey: .image)
        case .unknown:
            try container.encode(ItemType.unknown, forKey: .type)
        }
    }
}

class ClipboardManager: ObservableObject {
    @Published var clipboardItems: [ClipboardItem] = []
    
    private var timer: Timer?
    private var previousClipboardContent: Data?
    private let storageURL: URL
    
    init() {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        storageURL = urls[0].appendingPathComponent("clipboard_items.json")
        
        loadClipboardItems()
        
        startMonitoring()
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        
        if let string = pasteboard.string(forType: .string) {
            let data = Data(string.utf8)
            if data != previousClipboardContent {
                previousClipboardContent = data
                addClipboardItem(.text(string))
            }
        } else if let imageData = pasteboard.data(forType: .tiff) {
            if imageData != previousClipboardContent {
                previousClipboardContent = imageData
                addClipboardItem(.image(imageData))
            }
        } else {
            let data = Data("unknown".utf8)
            if data != previousClipboardContent {
                previousClipboardContent = data
                addClipboardItem(.unknown)
            }
        }
    }
    
    private func addClipboardItem(_ item: ClipboardItem) {
        if clipboardItems.count >= 20 {
            clipboardItems.removeFirst()
        }
        clipboardItems.append(item)
        saveClipboardItems()
    }
    
    private func saveClipboardItems() {
        do {
            let data = try JSONEncoder().encode(clipboardItems)
            try data.write(to: storageURL)
        } catch {
            print("Failed to save clipboard items: \(error)")
        }
    }
    
    private func loadClipboardItems() {
        do {
            let data = try Data(contentsOf: storageURL)
            clipboardItems = try JSONDecoder().decode([ClipboardItem].self, from: data)
        } catch {
            print("Failed to load clipboard items: \(error)")
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
