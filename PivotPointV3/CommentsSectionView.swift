import SwiftUI

struct CommentsSectionView: View {
    @Binding var comments: String
    
    var body: some View {
        Section("Additional Comments") {
            TextEditor(text: $comments)
                .frame(height: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(comments.isEmpty ? Color.gray : Color.green, lineWidth: 1)
                )
                .keyboardToolbar()
        }
    }
}
