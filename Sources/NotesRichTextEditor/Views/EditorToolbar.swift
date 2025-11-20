import SwiftUI

struct EditorToolbar: View {
    var controller: NotesEditorController?
    @Binding var configuration: NotesEditorConfiguration
    
    var body: some View {
        HStack(spacing: 25) {
            if configuration.showsToolbar {
                Button(action: { controller?.toggleStyle(.bold) }) {
                    Image(systemName: "bold")
                        .font(.system(size: 18, weight: .medium))
                }
                
                Button(action: { controller?.toggleStyle(.italic) }) {
                    Image(systemName: "italic")
                        .font(.system(size: 18, weight: .medium))
                }
                
                Button(action: { controller?.toggleStyle(.underline) }) {
                    Image(systemName: "underline")
                        .font(.system(size: 18, weight: .medium))
                }
                
                if configuration.allowsChecklists {
                    Button(action: { 
                        controller?.toggleBlockType(.checklist)
                    }) {
                        Image(systemName: "checklist")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
                
                if configuration.allowsLists {
                    Button(action: { 
                        controller?.toggleBlockType(.bullet)
                    }) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
                
                if configuration.allowsImages {
                    Button(action: { 
                        // Logic to insert image
                        controller?.insertImage(identifier: "placeholder")
                    }) {
                        Image(systemName: "paperclip")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
                
                Spacer()
                
                Button(action: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
        )
    }
}
