import SwiftUI
import Combine

public enum FocusPosition {
    case start
    case end
}

public class NotesEditorViewModel: ObservableObject, NotesEditorController {
    @Published var activeBlockId: UUID?
    @Published var activeSelection: NSRange = NSRange(location: 0, length: 0)
    @Published var focusedBlockId: UUID?
    @Published var focusPosition: FocusPosition = .start
    @Published var typingAttributes: [NSAttributedString.Key: Any] = [:]
    
    // We need a way to modify the document from the controller methods.
    // Since the document is a binding in the view, we can't modify it directly here unless we have a reference or a closure.
    // A common pattern is to have a closure that the view sets.
    var updateDocument: (( (inout NotesDocument) -> Void ) -> Void)?
    
    public init() {}
    
    public func setup(binding: Binding<NotesDocument>) {
        self.updateDocument = { action in
            // Create a mutable copy, apply action, and write back
            var document = binding.wrappedValue
            action(&document)
            binding.wrappedValue = document
        }
    }
    
    public func toggleStyle(_ style: NotesTextStyle) {
        guard let activeBlockId = activeBlockId else { return }
        
        // If no text is selected, toggle typing attributes
        if activeSelection.length == 0 {
            toggleTypingAttribute(style)
            return
        }
        
        updateDocument? { document in
            guard let index = document.blocks.firstIndex(where: { $0.id == activeBlockId }) else { return }
            
            // Apply style to the block's attributed text at activeSelection
            var blockToCheck: AttributedString?
            
            switch document.blocks[index] {
            case .text(let b): blockToCheck = b.attributedText
            case .checklist(let b): blockToCheck = b.attributedText
            case .bullet(let b): blockToCheck = b.attributedText
            case .numbered(let b): blockToCheck = b.attributedText
            default: break
            }
            
            guard var text = blockToCheck else { return }
            
            // Convert to NSMutableAttributedString for UIKit manipulation
            var nsText = NSMutableAttributedString(text)
            let range = self.activeSelection
            
            // Make sure range is valid
            guard range.location + range.length <= nsText.length else { return }
            
            switch style {
            case .bold:
                self.toggleBoldTrait(in: &nsText, range: range)
            case .italic:
                self.toggleItalicTrait(in: &nsText, range: range)
            case .underline:
                self.toggleUnderline(in: &nsText, range: range)
            case .strikethrough:
                self.toggleStrikethrough(in: &nsText, range: range)
            case .heading1:
                self.applyFont(UIFont.preferredFont(forTextStyle: .largeTitle), in: &nsText, range: range)
            case .heading2:
                self.applyFont(UIFont.preferredFont(forTextStyle: .title2), in: &nsText, range: range)
            case .body:
                self.applyFont(UIFont.preferredFont(forTextStyle: .body), in: &nsText, range: range)
            }
            
            // Convert back to AttributedString
            text = AttributedString(nsText)
            
            // Update block
            switch document.blocks[index] {
            case .text(var b): b.attributedText = text; document.blocks[index] = .text(b)
            case .checklist(var b): b.attributedText = text; document.blocks[index] = .checklist(b)
            case .bullet(var b): b.attributedText = text; document.blocks[index] = .bullet(b)
            case .numbered(var b): b.attributedText = text; document.blocks[index] = .numbered(b)
            default: break
            }
        }
    }
    
    private func toggleTypingAttribute(_ style: NotesTextStyle) {
        // Get current font from typing attributes or default
        let currentFont = typingAttributes[.font] as? UIFont ?? UIFont.preferredFont(forTextStyle: .body)
        
        switch style {
        case .bold:
            var traits = currentFont.fontDescriptor.symbolicTraits
            if traits.contains(.traitBold) {
                traits.remove(.traitBold)
            } else {
                traits.insert(.traitBold)
            }
            if let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
                typingAttributes[.font] = UIFont(descriptor: descriptor, size: currentFont.pointSize)
            }
        case .italic:
            var traits = currentFont.fontDescriptor.symbolicTraits
            if traits.contains(.traitItalic) {
                traits.remove(.traitItalic)
            } else {
                traits.insert(.traitItalic)
            }
            if let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
                typingAttributes[.font] = UIFont(descriptor: descriptor, size: currentFont.pointSize)
            }
        case .underline:
            if let underlineStyle = typingAttributes[.underlineStyle] as? Int, underlineStyle != 0 {
                typingAttributes.removeValue(forKey: .underlineStyle)
            } else {
                typingAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
        case .strikethrough:
            if let strikethroughStyle = typingAttributes[.strikethroughStyle] as? Int, strikethroughStyle != 0 {
                typingAttributes.removeValue(forKey: .strikethroughStyle)
            } else {
                typingAttributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            }
        case .heading1:
            typingAttributes[.font] = UIFont.preferredFont(forTextStyle: .largeTitle)
        case .heading2:
            typingAttributes[.font] = UIFont.preferredFont(forTextStyle: .title2)
        case .body:
            typingAttributes[.font] = UIFont.preferredFont(forTextStyle: .body)
        }
    }
    
    private func toggleBoldTrait(in attributedString: inout NSMutableAttributedString, range: NSRange) {
        attributedString.enumerateAttribute(.font, in: range) { value, subRange, _ in
            guard let currentFont = value as? UIFont else { return }
            
            let newFont: UIFont
            if currentFont.fontDescriptor.symbolicTraits.contains(.traitBold) {
                // Remove bold
                var traits = currentFont.fontDescriptor.symbolicTraits
                traits.remove(.traitBold)
                if let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
                    newFont = UIFont(descriptor: descriptor, size: currentFont.pointSize)
                } else {
                    newFont = currentFont
                }
            } else {
                // Add bold
                var traits = currentFont.fontDescriptor.symbolicTraits
                traits.insert(.traitBold)
                if let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
                    newFont = UIFont(descriptor: descriptor, size: currentFont.pointSize)
                } else {
                    newFont = currentFont
                }
            }
            attributedString.addAttribute(.font, value: newFont, range: subRange)
        }
    }
    
    private func toggleItalicTrait(in attributedString: inout NSMutableAttributedString, range: NSRange) {
        attributedString.enumerateAttribute(.font, in: range) { value, subRange, _ in
            guard let currentFont = value as? UIFont else { return }
            
            let newFont: UIFont
            if currentFont.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                // Remove italic
                var traits = currentFont.fontDescriptor.symbolicTraits
                traits.remove(.traitItalic)
                if let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
                    newFont = UIFont(descriptor: descriptor, size: currentFont.pointSize)
                } else {
                    newFont = currentFont
                }
            } else {
                // Add italic
                var traits = currentFont.fontDescriptor.symbolicTraits
                traits.insert(.traitItalic)
                if let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
                    newFont = UIFont(descriptor: descriptor, size: currentFont.pointSize)
                } else {
                    newFont = currentFont
                }
            }
            attributedString.addAttribute(.font, value: newFont, range: subRange)
        }
    }
    
    private func toggleUnderline(in attributedString: inout NSMutableAttributedString, range: NSRange) {
        // Check if already underlined
        var hasUnderline = false
        attributedString.enumerateAttribute(.underlineStyle, in: range) { value, _, stop in
            if let underlineStyle = value as? Int, underlineStyle != 0 {
                hasUnderline = true
                stop.pointee = true
            }
        }
        
        if hasUnderline {
            attributedString.removeAttribute(.underlineStyle, range: range)
        } else {
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
    }
    
    private func toggleStrikethrough(in attributedString: inout NSMutableAttributedString, range: NSRange) {
        // Check if already strikethrough
        var hasStrikethrough = false
        attributedString.enumerateAttribute(.strikethroughStyle, in: range) { value, _, stop in
            if let strikethroughStyle = value as? Int, strikethroughStyle != 0 {
                hasStrikethrough = true
                stop.pointee = true
            }
        }
        
        if hasStrikethrough {
            attributedString.removeAttribute(.strikethroughStyle, range: range)
        } else {
            attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
    }
    
    private func applyFont(_ font: UIFont, in attributedString: inout NSMutableAttributedString, range: NSRange) {
        attributedString.addAttribute(.font, value: font, range: range)
    }
    
    public func setTextColor(_ color: Color) {
        guard let activeBlockId = activeBlockId else { return }
        
        updateDocument? { document in
            guard let index = document.blocks.firstIndex(where: { $0.id == activeBlockId }) else { return }
            
            var blockToCheck: AttributedString?
            switch document.blocks[index] {
            case .text(let b): blockToCheck = b.attributedText
            case .checklist(let b): blockToCheck = b.attributedText
            case .bullet(let b): blockToCheck = b.attributedText
            case .numbered(let b): blockToCheck = b.attributedText
            default: break
            }
            
            guard var text = blockToCheck else { return }
            
            if let range = Range(activeSelection, in: text) {
                text[range].foregroundColor = color
            }
            
            switch document.blocks[index] {
            case .text(var b): b.attributedText = text; document.blocks[index] = .text(b)
            case .checklist(var b): b.attributedText = text; document.blocks[index] = .checklist(b)
            case .bullet(var b): b.attributedText = text; document.blocks[index] = .bullet(b)
            case .numbered(var b): b.attributedText = text; document.blocks[index] = .numbered(b)
            default: break
            }
        }
    }
    
    
    public func toggleBlockType(_ type: BlockType) {
        guard let activeBlockId = activeBlockId else { return }
        
        updateDocument? { document in
            guard let index = document.blocks.firstIndex(where: { $0.id == activeBlockId }) else { return }
            
            let currentBlock = document.blocks[index]
            var attributedText = AttributedString()
            
            // Extract text from current block
            switch currentBlock {
            case .text(let b): attributedText = b.attributedText
            case .checklist(let b): attributedText = b.attributedText
            case .bullet(let b): attributedText = b.attributedText
            case .numbered(let b): attributedText = b.attributedText
            case .image: return // Can't convert image blocks
            }
            
            // Determine target block type
            let targetBlockType: BlockType
            
            // If current block is already the requested type, convert to text
            switch (currentBlock, type) {
            case (.checklist, .checklist), (.bullet, .bullet), (.numbered, .numbered):
                targetBlockType = .text
            default:
                targetBlockType = type
            }
            
            // Create new block
            let newBlock: NotesBlock
            switch targetBlockType {
            case .text:
                newBlock = .text(TextBlock(attributedText: attributedText))
            case .checklist:
                newBlock = .checklist(ChecklistBlock(isChecked: false, attributedText: attributedText))
            case .bullet:
                newBlock = .bullet(BulletListBlock(attributedText: attributedText))
            case .numbered:
                // Find the next number in sequence
                var nextIndex = 1
                if index > 0, case .numbered(let prevBlock) = document.blocks[index - 1] {
                    nextIndex = prevBlock.index + 1
                }
                newBlock = .numbered(NumberedListBlock(index: nextIndex, attributedText: attributedText))
            }
            
            document.blocks[index] = newBlock
            
            // Re-index numbered lists
            self.reindexNumberedLists(in: &document)
        }
    }
    
    public func insertImage(identifier: String) {
        guard let activeBlockId = activeBlockId else { return }
        
        updateDocument? { document in
            guard let index = document.blocks.firstIndex(where: { $0.id == activeBlockId }) else { return }
            
            let newBlock = NotesBlock.image(ImageBlock(imageIdentifier: identifier))
            document.blocks.insert(newBlock, at: index + 1)
        }
    }
    
    func setActiveBlock(id: UUID) {
        activeBlockId = id
    }
    
    // ... existing methods ...
    
    func handleReturn(for blockId: UUID, document: inout NotesDocument) {
        // Find the block by ID
        guard let index = document.blocks.firstIndex(where: { $0.id == blockId }) else { return }
        
        let currentBlock = document.blocks[index]
        
        // Check if current block is empty
        func isBlockEmpty(_ block: NotesBlock) -> Bool {
            switch block {
            case .text(let b): return b.attributedText.characters.isEmpty
            case .checklist(let b): return b.attributedText.characters.isEmpty
            case .bullet(let b): return b.attributedText.characters.isEmpty
            case .numbered(let b): return b.attributedText.characters.isEmpty
            case .image: return false
            }
        }
        
        // Logic to create new block based on current type
        var newBlock: NotesBlock
        
        // If current block is empty and is a special type, convert to text instead
        if isBlockEmpty(currentBlock) {
            switch currentBlock {
            case .checklist, .bullet, .numbered:
                // Convert the current empty block to text
                document.blocks[index] = .text(TextBlock())
                // Create a new text block
                newBlock = .text(TextBlock())
            case .text, .image:
                newBlock = .text(TextBlock())
            }
        } else {
            // Create new block of same type
            switch currentBlock {
            case .text:
                newBlock = .text(TextBlock())
            case .checklist:
                newBlock = .checklist(ChecklistBlock())
            case .bullet:
                newBlock = .bullet(BulletListBlock())
            case .numbered(let block):
                newBlock = .numbered(NumberedListBlock(index: block.index + 1))
            case .image:
                newBlock = .text(TextBlock())
            }
        }
        
        // Insert after current
        if index + 1 < document.blocks.count {
            document.blocks.insert(newBlock, at: index + 1)
        } else {
            document.blocks.append(newBlock)
        }
        
        // Re-index if needed (for numbered lists)
        reindexNumberedLists(in: &document)
        
        // Focus new block
        activeBlockId = newBlock.id
        focusPosition = .start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.focusedBlockId = newBlock.id
        }
    }
    
    func handleBackspace(for blockId: UUID, document: inout NotesDocument) {
        // Find the block by ID
        guard let index = document.blocks.firstIndex(where: { $0.id == blockId }) else { return }
        guard index > 0 else { return }
        
        // Remove current block and merge with previous if possible?
        // Or just delete if empty.
        // For now, simple delete.
        document.blocks.remove(at: index)
        
        // Re-index
        reindexNumberedLists(in: &document)
        
        // Focus previous block and keep keyboard visible
        if index - 1 >= 0 && index - 1 < document.blocks.count {
            let previousBlockId = document.blocks[index - 1].id
            activeBlockId = previousBlockId
            focusPosition = .end
            // Set focus to keep keyboard visible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.focusedBlockId = previousBlockId
            }
        }
    }
    
    func toggleChecklist(for blockId: UUID, document: inout NotesDocument) {
        guard let index = document.blocks.firstIndex(where: { $0.id == blockId }) else { return }
        guard case .checklist(var block) = document.blocks[index] else { return }
        block.isChecked.toggle()
        document.blocks[index] = .checklist(block)
    }
    
    private func reindexNumberedLists(in document: inout NotesDocument) {
        var currentIndex = 1
        for i in 0..<document.blocks.count {
            if case .numbered(var block) = document.blocks[i] {
                block.index = currentIndex
                document.blocks[i] = .numbered(block)
                currentIndex += 1
            } else {
                currentIndex = 1 // Reset if list is broken? Or continue? Apple Notes resets on break.
            }
        }
    }
}
