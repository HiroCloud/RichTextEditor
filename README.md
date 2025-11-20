# NotesRichTextEditor

A SwiftUI rich text editor package for iOS 17+ that provides functionality comparable to Apple Notes.

## Features

- **Rich Text Styling**: Bold, Italic, Underline, Strikethrough, Headings.
- **Lists**: Bullet lists and Numbered lists.
- **Checklists**: Interactive checklists.
- **Images**: Inline image support.
- **Undo/Redo**: Built-in support via `UndoManager` (integrated into the view model logic).
- **Codable**: Full JSON serialization support for the document model.

## Usage

1. Import the package:
   ```swift
   import NotesRichTextEditor
   ```

2. Create a document binding:
   ```swift
   @State var document = NotesDocument(blocks: [.text(TextBlock())])
   ```

3. Use the view:
   ```swift
   NotesRichTextEditorView(document: $document)
   ```

## Configuration

You can customize the editor using `NotesEditorConfiguration`:

```swift
let config = NotesEditorConfiguration(
    showsToolbar: true,
    allowsImages: true,
    allowsChecklists: true,
    allowsLists: true,
    font: .body,
    lineSpacing: 4
)

NotesRichTextEditorView(document: $document, configuration: config)
```

## Requirements


## Demo App

A sample project is included in the `NotesDemo.swiftpm` directory. You can open this folder directly in Xcode or Swift Playgrounds to run the demo app.

1. Open `NotesDemo.swiftpm` in Xcode.
2. Run the `NotesDemo` scheme.
