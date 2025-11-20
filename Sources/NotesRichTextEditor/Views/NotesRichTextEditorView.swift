import SwiftUI

public struct NotesRichTextEditorView: View {
    @Binding var document: NotesDocument
    var configuration: NotesEditorConfiguration
    
    @StateObject private var viewModel = NotesEditorViewModel()
    
    public init(document: Binding<NotesDocument>, configuration: NotesEditorConfiguration = .default) {
        self._document = document
        self.configuration = configuration
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack(alignment: .leading, spacing: configuration.lineSpacing) {
                        ForEach(Array(document.blocks.enumerated()), id: \.element.id) { index, block in
                            blockView(for: block, at: index)
                                .padding(.horizontal, configuration.contentInset.leading)
                                .id(block.id)
                        }
                    }
                    .padding(.vertical, configuration.contentInset.top)
                    .onChange(of: viewModel.focusedBlockId) { newBlockId in
                        if let blockId = newBlockId {
                            withAnimation {
                                proxy.scrollTo(blockId, anchor: .bottom)
                            }
                        }
                        // Clear focusedBlockId after a delay to allow the view to render and trigger the focus
                        if newBlockId != nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                viewModel.focusedBlockId = nil
                            }
                        }
                    }
                }
            }
            
            if configuration.showsToolbar {
                EditorToolbar(controller: viewModel, configuration: .constant(configuration))
            }
        }
        .onAppear {
            viewModel.setup(binding: $document)
        }
        .onChange(of: document) { newValue in
            // Sync if needed, but binding in VM should handle it if we use it correctly.
            // Actually, if the binding reference changes (e.g. parent passes a new binding), we might need to update.
            viewModel.setup(binding: $document)
        }
    }
    
    @ViewBuilder
    private func blockView(for block: NotesBlock, at index: Int) -> some View {
        switch block {
        case .text(var textBlock):
            TextBlockView(
                block: Binding(
                    get: { textBlock },
                    set: { document.blocks[index] = .text($0) }
                ),
                selection: $viewModel.activeSelection,
                typingAttributes: $viewModel.typingAttributes,
                configuration: configuration,
                shouldBecomeFirstResponder: block.id == viewModel.focusedBlockId,
                focusPosition: viewModel.focusPosition,
                onCommit: { viewModel.handleReturn(for: block.id, document: &document) },
                onBackspace: { viewModel.handleBackspace(for: block.id, document: &document) },
                onEditingChanged: { viewModel.setActiveBlock(id: block.id) }
            )
        case .checklist(var checklistBlock):
            ChecklistBlockView(
                block: Binding(
                    get: { checklistBlock },
                    set: { document.blocks[index] = .checklist($0) }
                ),
                selection: $viewModel.activeSelection,
                typingAttributes: $viewModel.typingAttributes,
                configuration: configuration,
                shouldBecomeFirstResponder: block.id == viewModel.focusedBlockId,
                focusPosition: viewModel.focusPosition,
                onToggle: { viewModel.toggleChecklist(for: block.id, document: &document) },
                onCommit: { viewModel.handleReturn(for: block.id, document: &document) },
                onBackspace: { viewModel.handleBackspace(for: block.id, document: &document) },
                onEditingChanged: { viewModel.setActiveBlock(id: block.id) }
            )
        case .bullet(var bulletBlock):
            BulletListBlockView(
                block: Binding(
                    get: { bulletBlock },
                    set: { document.blocks[index] = .bullet($0) }
                ),
                selection: $viewModel.activeSelection,
                typingAttributes: $viewModel.typingAttributes,
                configuration: configuration,
                shouldBecomeFirstResponder: block.id == viewModel.focusedBlockId,
                focusPosition: viewModel.focusPosition,
                onCommit: { viewModel.handleReturn(for: block.id, document: &document) },
                onBackspace: { viewModel.handleBackspace(for: block.id, document: &document) },
                onEditingChanged: { viewModel.setActiveBlock(id: block.id) }
            )
        case .numbered(var numberedBlock):
            NumberedListBlockView(
                block: Binding(
                    get: { numberedBlock },
                    set: { document.blocks[index] = .numbered($0) }
                ),
                selection: $viewModel.activeSelection,
                typingAttributes: $viewModel.typingAttributes,
                configuration: configuration,
                shouldBecomeFirstResponder: block.id == viewModel.focusedBlockId,
                focusPosition: viewModel.focusPosition,
                onCommit: { viewModel.handleReturn(for: block.id, document: &document) },
                onBackspace: { viewModel.handleBackspace(for: block.id, document: &document) },
                onEditingChanged: { viewModel.setActiveBlock(id: block.id) }
            )
        case .image(var imageBlock):
            ImageBlockView(
                block: Binding(
                    get: { imageBlock },
                    set: { document.blocks[index] = .image($0) }
                ),
                configuration: configuration
            )
        }
    }
}
