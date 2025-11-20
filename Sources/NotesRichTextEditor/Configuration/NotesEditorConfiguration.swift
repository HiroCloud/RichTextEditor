import SwiftUI
import UIKit

public struct NotesEditorConfiguration {
    public var showsToolbar: Bool
    public var allowsImages: Bool
    public var allowsChecklists: Bool
    public var allowsLists: Bool
    public var font: UIFont
    public var textColor: UIColor
    public var lineSpacing: CGFloat
    public var contentInset: EdgeInsets
    
    public init(
        showsToolbar: Bool = true,
        allowsImages: Bool = true,
        allowsChecklists: Bool = true,
        allowsLists: Bool = true,
        font: UIFont = .preferredFont(forTextStyle: .body), // Matches Apple Notes & Dynamic Type
        textColor: UIColor = .label, // Adapts to light/dark mode
        lineSpacing: CGFloat = 4,
        contentInset: EdgeInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    ) {
        self.showsToolbar = showsToolbar
        self.allowsImages = allowsImages
        self.allowsChecklists = allowsChecklists
        self.allowsLists = allowsLists
        self.font = font
        self.textColor = textColor
        self.lineSpacing = lineSpacing
        self.contentInset = contentInset
    }

    public static var `default`: NotesEditorConfiguration {
        NotesEditorConfiguration()
    }
}

public enum NotesTextStyle: CaseIterable {
    case bold
    case italic
    case underline
    case strikethrough
    case heading1
    case heading2
    case body
}

public protocol NotesEditorController {
    func toggleStyle(_ style: NotesTextStyle)
    func setTextColor(_ color: Color)
    func insertImage(identifier: String)
    func toggleBlockType(_ type: BlockType)
}

public enum BlockType {
    case text
    case checklist
    case bullet
    case numbered
}

public protocol NotesUndoSupport {
    func undo()
    func redo()
    var canUndo: Bool { get }
    var canRedo: Bool { get }
}
