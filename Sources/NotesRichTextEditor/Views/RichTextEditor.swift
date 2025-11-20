import SwiftUI
import UIKit

struct RichTextEditor: UIViewRepresentable {
    @Binding var text: AttributedString
    @Binding var selection: NSRange
    @Binding var typingAttributes: [NSAttributedString.Key: Any]
    var controller: NotesEditorController?
    var configuration: NotesEditorConfiguration
    var font: UIFont
    var textColor: UIColor
    var shouldBecomeFirstResponder: Bool
    var focusPosition: FocusPosition
    var onEditingChanged: () -> Void
    var onCommit: () -> Void
    var onBackspaceAtStart: () -> Void
    
    func makeUIView(context: Context) -> BackspaceDetectingTextView {
        let textView = BackspaceDetectingTextView()
        textView.onBackspaceAtStart = onBackspaceAtStart
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = context.coordinator
        textView.font = font
        textView.textColor = textColor
        
        // Set initial text
        textView.attributedText = NSAttributedString(text)
        
        // Add toolbar
        if configuration.showsToolbar {
            let toolbarView = EditorToolbar(controller: controller, configuration: .constant(configuration))
            let hostingController = UIHostingController(rootView: toolbarView)
            hostingController.view.backgroundColor = .clear
            hostingController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60)
            
            // Ensure the view resizes correctly
            hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            textView.inputAccessoryView = hostingController.view
            
            // Keep a reference to the hosting controller to prevent deallocation
            // We can attach it to the text view using objc_setAssociatedObject or a subclass property
            // For now, let's assume the inputAccessoryView retains it, but UIHostingController might need to be retained.
            // Actually, inputAccessoryView is a strong reference.
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: BackspaceDetectingTextView, context: Context) {
        // Update font and text color
        uiView.font = font
        uiView.textColor = textColor
        
        // Only update if content changed to avoid cursor jumping
        var nsAttributedString = NSMutableAttributedString(text)
        
        // Only set default attributes where they don't already exist
        let fullRange = NSRange(location: 0, length: nsAttributedString.length)
        
        // Apply default color where no color is set
        nsAttributedString.enumerateAttribute(.foregroundColor, in: fullRange) { value, range, _ in
            if value == nil {
                nsAttributedString.addAttribute(.foregroundColor, value: textColor, range: range)
            }
        }
        
        // Apply default font where no font is set
        nsAttributedString.enumerateAttribute(.font, in: fullRange) { value, range, _ in
            if value == nil {
                nsAttributedString.addAttribute(.font, value: font, range: range)
            }
        }
        
        // Update if either the string or attributes changed
        if uiView.attributedText != nsAttributedString {
            context.coordinator.isUpdating = true
            let currentSelection = uiView.selectedRange
            uiView.attributedText = nsAttributedString
            // Restore selection if possible
            if currentSelection.location <= nsAttributedString.length {
                uiView.selectedRange = currentSelection
            }
            context.coordinator.isUpdating = false
        }
        
        // Apply typing attributes
        uiView.typingAttributes = typingAttributes
        
        // Handle first responder request
        if shouldBecomeFirstResponder && !uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
                // Set cursor based on focus position
                let location = self.focusPosition == .start ? 0 : uiView.text.count
                uiView.selectedRange = NSRange(location: location, length: 0)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        var isUpdating = false
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            guard !isUpdating else { return }
            parent.text = AttributedString(textView.attributedText)
            parent.onEditingChanged()
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            guard !isUpdating else { return }
            parent.selection = textView.selectedRange
            // Sync typing attributes back
            parent.typingAttributes = textView.typingAttributes
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                parent.onCommit()
                return false
            }
            return true
        }
        
        @objc func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

class BackspaceDetectingTextView: UITextView {
    var onBackspaceAtStart: (() -> Void)?
    
    override func deleteBackward() {
        if selectedRange.location == 0 && selectedRange.length == 0 {
            onBackspaceAtStart?()
        } else {
            super.deleteBackward()
        }
    }
}
