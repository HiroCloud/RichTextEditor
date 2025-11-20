import XCTest
@testable import NotesRichTextEditor
import SwiftUI

final class NotesRichTextEditorTests: XCTestCase {
    func testDocumentSerialization() throws {
        let textBlock = TextBlock(attributedText: AttributedString("Hello"))
        let checklistBlock = ChecklistBlock(isChecked: true, attributedText: AttributedString("Check"))
        let document = NotesDocument(blocks: [.text(textBlock), .checklist(checklistBlock)])
        
        let data = try document.toData()
        let decoded = try NotesDocument.fromData(data)
        
        XCTAssertEqual(decoded.blocks.count, 2)
        
        if case .text(let b) = decoded.blocks[0] {
            XCTAssertEqual(b.attributedText, textBlock.attributedText)
        } else {
            XCTFail("First block should be text")
        }
        
        if case .checklist(let b) = decoded.blocks[1] {
            XCTAssertEqual(b.isChecked, true)
            XCTAssertEqual(b.attributedText, checklistBlock.attributedText)
        } else {
            XCTFail("Second block should be checklist")
        }
    }
    
    func testViewModelReturn() {
        var document = NotesDocument(blocks: [.text(TextBlock(attributedText: AttributedString("Line 1")))])
        let viewModel = NotesEditorViewModel()
        
        viewModel.handleReturn(at: 0, document: &document)
        
        XCTAssertEqual(document.blocks.count, 2)
        if case .text = document.blocks[1] {
            // Success
        } else {
            XCTFail("New block should be text")
        }
    }
    
    func testViewModelBackspace() {
        var document = NotesDocument(blocks: [
            .text(TextBlock(attributedText: AttributedString("1"))),
            .text(TextBlock(attributedText: AttributedString("2")))
        ])
        let viewModel = NotesEditorViewModel()
        
        viewModel.handleBackspace(at: 1, document: &document)
        
        XCTAssertEqual(document.blocks.count, 1)
        if case .text(let b) = document.blocks[0] {
            XCTAssertEqual(b.attributedText, AttributedString("1"))
        } else {
            XCTFail("Remaining block should be the first one")
        }
    }
}
