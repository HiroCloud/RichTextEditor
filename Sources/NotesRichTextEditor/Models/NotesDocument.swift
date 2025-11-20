import SwiftUI
import Foundation

// MARK: - Document Container

public struct NotesDocument: Identifiable, Codable, Equatable {
    public var id: UUID
    public var blocks: [NotesBlock]
    
    public init(id: UUID = UUID(), blocks: [NotesBlock] = []) {
        self.id = id
        self.blocks = blocks
    }
    
    public func toData() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
    
    public static func fromData(_ data: Data) throws -> NotesDocument {
        let decoder = JSONDecoder()
        return try decoder.decode(NotesDocument.self, from: data)
    }
}

// MARK: - Block Types

public struct TextBlock: Codable, Equatable, Identifiable {
    public var id: UUID
    public var attributedText: AttributedString
    
    public init(id: UUID = UUID(), attributedText: AttributedString = AttributedString()) {
        self.id = id
        self.attributedText = attributedText
    }
}

public struct ChecklistBlock: Codable, Equatable, Identifiable {
    public var id: UUID
    public var isChecked: Bool
    public var attributedText: AttributedString
    
    public init(id: UUID = UUID(), isChecked: Bool = false, attributedText: AttributedString = AttributedString()) {
        self.id = id
        self.isChecked = isChecked
        self.attributedText = attributedText
    }
}

public struct BulletListBlock: Codable, Equatable, Identifiable {
    public var id: UUID
    public var attributedText: AttributedString
    
    public init(id: UUID = UUID(), attributedText: AttributedString = AttributedString()) {
        self.id = id
        self.attributedText = attributedText
    }
}

public struct NumberedListBlock: Codable, Equatable, Identifiable {
    public var id: UUID
    public var index: Int
    public var attributedText: AttributedString
    
    public init(id: UUID = UUID(), index: Int = 1, attributedText: AttributedString = AttributedString()) {
        self.id = id
        self.index = index
        self.attributedText = attributedText
    }
}

public struct ImageBlock: Codable, Equatable, Identifiable {
    public var id: UUID
    public var imageIdentifier: String
    public var caption: AttributedString?
    
    public init(id: UUID = UUID(), imageIdentifier: String, caption: AttributedString? = nil) {
        self.id = id
        self.imageIdentifier = imageIdentifier
        self.caption = caption
    }
}

// MARK: - Block Enum

public enum NotesBlock: Codable, Equatable, Identifiable {
    case text(TextBlock)
    case checklist(ChecklistBlock)
    case bullet(BulletListBlock)
    case numbered(NumberedListBlock)
    case image(ImageBlock)
    
    public var id: UUID {
        switch self {
        case .text(let block): return block.id
        case .checklist(let block): return block.id
        case .bullet(let block): return block.id
        case .numbered(let block): return block.id
        case .image(let block): return block.id
        }
    }
}
