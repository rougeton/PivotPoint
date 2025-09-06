import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    var sourceType: UIImagePickerController.SourceType
    var onImagePicked: (Data?) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        // Check if the source type (e.g., camera) is actually available on the device.
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            // If not available, print an error and return a placeholder view controller.
            print("Source type \(sourceType.rawValue) is not available.")
            // Immediately call the completion handler with nil to signal failure.
            DispatchQueue.main.async {
                onImagePicked(nil)
                dismiss()
            }
            return UIViewController()
        }
        
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let imageData = (info[.originalImage] as? UIImage)?.jpegData(compressionQuality: 0.8)
            // Ensure we call back on the main thread.
            DispatchQueue.main.async {
                self.parent.onImagePicked(imageData)
                self.parent.dismiss()
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // Ensure we call back on the main thread.
            DispatchQueue.main.async {
                self.parent.onImagePicked(nil)
                self.parent.dismiss()
            }
        }
    }
}
