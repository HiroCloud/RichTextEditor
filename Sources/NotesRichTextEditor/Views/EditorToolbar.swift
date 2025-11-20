import SwiftUI

struct EditorToolbar: View {
    var controller: NotesEditorController?
    @Binding var configuration: NotesEditorConfiguration
    
    var body: some View {
        HStack(spacing: 20) {
            if configuration.showsToolbar {
                Button(action: { controller?.toggleStyle(.bold) }) {
                    Image(systemName: "bold")
                }
                
                Button(action: { controller?.toggleStyle(.italic) }) {
                    Image(systemName: "italic")
                }
                
                Button(action: { controller?.toggleStyle(.underline) }) {
                    Image(systemName: "underline")
                }
                
                if configuration.allowsChecklists {
                    Button(action: { 
                        controller?.toggleBlockType(.checklist)
                    }) {
                        Image(systemName: "checklist")
                    }
                }
                
                if configuration.allowsLists {
                    Button(action: { 
                        controller?.toggleBlockType(.bullet)
                    }) {
                        Image(systemName: "list.bullet")
                    }
                }
                
                if configuration.allowsImages {
                    Button(action: { 
                        // Logic to insert image
                        controller?.insertImage(identifier: "placeholder")
                    }) {
                        Image(systemName: "photo")
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .shadow(radius: 2)
    }
}
