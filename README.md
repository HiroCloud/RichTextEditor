# NotesRichTextEditor

A SwiftUI package for rich text editing with block-based content, similar to Apple Notes. Supports text styling, checklists, bullet lists, numbered lists, and more.

## Features

### Text Styling
- **Bold**, *Italic*, and <u>Underline</u> formatting
- Strikethrough support
- Heading styles (H1, H2, Body)
- Typing attributes for new text

### Block Types
- **Text Blocks**: Plain text with rich formatting
- **Checklist Blocks**: Interactive todo items with checkboxes
- **Bullet Lists**: Unordered lists with bullet points
- **Numbered Lists**: Ordered lists with automatic numbering
- **Image Blocks**: Image placeholders (basic implementation)

### Editor Features
- Dark mode support
- Dynamic Type support
- Keyboard-integrated toolbar
- Auto-scrolling to new blocks
- Smart cursor positioning
- Block type conversion
- Return key handling (create new blocks)
- Backspace key handling (merge/delete blocks)

## Installation

### Swift Package Manager

Add this to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/NotesRichTextEditor.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select version/branch
4. Add to your target

## Usage

### Basic Implementation

```swift
import SwiftUI
import NotesRichTextEditor

struct ContentView: View {
    @State private var document = NotesDocument(
        blocks: [
            .text(TextBlock(attributedText: AttributedString("Hello, World!")))
        ]
    )
    
    var body: some View {
        NotesRichTextEditorView(
            document: $document,
            configuration: .default
        )
    }
}
```

### Custom Configuration

```swift
var customConfig = NotesEditorConfiguration.default
customConfig.font = .preferredFont(forTextStyle: .body)
customConfig.showsToolbar = true
customConfig.allowsChecklists = true
customConfig.allowsLists = true

NotesRichTextEditorView(
    document: $document,
    configuration: customConfig
)
```

### Document Serialization

```swift
// Save to JSON
if let data = document.toData() {
    try? data.write(to: fileURL)
}

// Load from JSON
if let data = try? Data(contentsOf: fileURL),
   let document = NotesDocument.fromData(data) {
    self.document = document
}
```

## Architecture

### Core Components

- **`NotesDocument`**: The data model containing an array of blocks
- **`NotesBlock`**: Enum representing different block types
- **`NotesRichTextEditorView`**: Main SwiftUI view
- **`RichTextEditor`**: UIViewRepresentable wrapper for UITextView
- **`NotesEditorViewModel`**: Manages editor state and operations
- **`EditorToolbar`**: Floating toolbar with formatting controls

### Block System

Each block is self-contained with its own `AttributedString`:
- Blocks have unique `UUID` identifiers
- Blocks can be converted between types
- Blocks maintain their own formatting state

## Demo Project

A sample project is included at `NotesDemo.swiftpm`:

```bash
cd NotesDemo.swiftpm
open .
```

Select "NotesDemo" as the run destination in Xcode.

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+

## Testing

Run tests with:

```bash
swift test
```

Or in Xcode:
- `Cmd+U` to run all tests

## TODO

### Image Support
- [ ] Implement actual image storage (currently placeholder only)
- [ ] Add image picker integration (PHPickerViewController)
- [ ] Support pasting images from clipboard
- [ ] Image resizing and aspect ratio handling
- [ ] Image persistence in document model
- [ ] Image export/import with document

### Text Size Controls
- [ ] Add font size picker to toolbar
- [ ] Implement increase/decrease font size buttons
- [ ] Support for custom font sizes per block
- [ ] Persistent font size preferences
- [ ] Text size accessibility options

### Additional Features
- [ ] Undo/Redo support
- [ ] Find and Replace
- [ ] Text alignment (left, center, right, justify)
- [ ] Link insertion and editing
- [ ] Table support
- [ ] Code block formatting
- [ ] Export to PDF/Markdown
- [ ] Collaborative editing support

## Known Issues

- Image blocks are placeholder-only (no actual image display/editing)
- Limited heading customization
- No text alignment controls

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[Specify your license here]

## Author

[Your name/organization]

## Acknowledgments

Built with SwiftUI and UIKit integration for rich text editing capabilities.
