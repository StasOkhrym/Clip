//
//  ClipboardItem.swift
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
