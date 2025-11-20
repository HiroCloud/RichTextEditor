import SwiftUI
import NotesRichTextEditor

struct ContentView: View {
    @State private var document = NotesDocument(blocks: [
        .text(TextBlock(attributedText: AttributedString("Welcome to NotesRichTextEditor!"))),
        .checklist(ChecklistBlock(isChecked: false, attributedText: AttributedString("Try checking this item"))),
        .bullet(BulletListBlock(attributedText: AttributedString("Bullet point 1"))),
        .bullet(BulletListBlock(attributedText: AttributedString("Bullet point 2"))),
        .numbered(NumberedListBlock(index: 1, attributedText: AttributedString("Numbered item 1"))),
        .numbered(NumberedListBlock(index: 2, attributedText: AttributedString("Numbered item 2")))
    ])
    
    @State private var showJSON = false
    
    var body: some View {
        NavigationStack {
            NotesRichTextEditorView(document: $document)
                .navigationTitle("Notes Demo")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Show JSON") {
                            showJSON = true
                        }
                    }
                }
                .sheet(isPresented: $showJSON) {
                    JSONView(document: document)
                }
        }
    }
}

struct JSONView: View {
    var document: NotesDocument
    
    var jsonString: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(document)
            return String(data: data, encoding: .utf8) ?? "Error"
        } catch {
            return "Error encoding: \(error)"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(jsonString)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
            }
            .navigationTitle("Document JSON")
        }
    }
}
