import SwiftUI

struct TextBlockView: View {
    @Binding var block: TextBlock
    @Binding var selection: NSRange
    @Binding var typingAttributes: [NSAttributedString.Key: Any]
    var configuration: NotesEditorConfiguration
    var shouldBecomeFirstResponder: Bool
    var onCommit: () -> Void
    var onBackspace: () -> Void
    var onEditingChanged: () -> Void
    
    var body: some View {
        RichTextEditor(
            text: $block.attributedText,
            selection: $selection,
            typingAttributes: $typingAttributes,
            font: configuration.font,
            textColor: configuration.textColor,
            shouldBecomeFirstResponder: shouldBecomeFirstResponder,
            onEditingChanged: onEditingChanged,
            onCommit: onCommit,
            onBackspaceAtStart: onBackspace
        )
    }
}

struct ChecklistBlockView: View {
    @Binding var block: ChecklistBlock
    @Binding var selection: NSRange
    @Binding var typingAttributes: [NSAttributedString.Key: Any]
    var configuration: NotesEditorConfiguration
    var shouldBecomeFirstResponder: Bool
    var onToggle: () -> Void
    var onCommit: () -> Void
    var onBackspace: () -> Void
    var onEditingChanged: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: block.isChecked ? "checkmark.circle.fill" : "circle")
                .foregroundColor(block.isChecked ? .gray : .accentColor)
                .onTapGesture {
                    onToggle()
                }
                .padding(.top, 4)
            
            RichTextEditor(
                text: $block.attributedText,
                selection: $selection,
                typingAttributes: $typingAttributes,
                font: configuration.font,
                textColor: configuration.textColor,
                shouldBecomeFirstResponder: shouldBecomeFirstResponder,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit,
                onBackspaceAtStart: onBackspace
            )
            .opacity(block.isChecked ? 0.5 : 1.0)
        }
    }
}

struct BulletListBlockView: View {
    @Binding var block: BulletListBlock
    @Binding var selection: NSRange
    @Binding var typingAttributes: [NSAttributedString.Key: Any]
    var configuration: NotesEditorConfiguration
    var shouldBecomeFirstResponder: Bool
    var onCommit: () -> Void
    var onBackspace: () -> Void
    var onEditingChanged: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            Text("•")
                .font(Font(configuration.font))
                .foregroundColor(Color(configuration.textColor))
                .padding(.leading, 8)
                .padding(.top, 0)
            
            RichTextEditor(
                text: $block.attributedText,
                selection: $selection,
                typingAttributes: $typingAttributes,
                font: configuration.font,
                textColor: configuration.textColor,
                shouldBecomeFirstResponder: shouldBecomeFirstResponder,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit,
                onBackspaceAtStart: onBackspace
            )
        }
    }
}

struct NumberedListBlockView: View {
    @Binding var block: NumberedListBlock
    @Binding var selection: NSRange
    @Binding var typingAttributes: [NSAttributedString.Key: Any]
    var configuration: NotesEditorConfiguration
    var shouldBecomeFirstResponder: Bool
    var onCommit: () -> Void
    var onBackspace: () -> Void
    var onEditingChanged: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\(block.index).")
                .font(Font(configuration.font))
                .foregroundColor(Color(configuration.textColor))
                .padding(.leading, 8)
                .monospacedDigit()
            
            RichTextEditor(
                text: $block.attributedText,
                selection: $selection,
                typingAttributes: $typingAttributes,
                font: configuration.font,
                textColor: configuration.textColor,
                shouldBecomeFirstResponder: shouldBecomeFirstResponder,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit,
                onBackspaceAtStart: onBackspace
            )
        }
    }
}

struct ImageBlockView: View {
    @Binding var block: ImageBlock
    var configuration: NotesEditorConfiguration
    
    var body: some View {
        VStack {
            Color.gray.opacity(0.2)
                .frame(height: 200)
                .overlay(Text("Image: \(block.imageIdentifier)"))
                .cornerRadius(8)
            
            if let caption = block.caption {
                Text(caption)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
