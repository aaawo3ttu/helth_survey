import SwiftUI
import UIKit

enum ImagePickerTarget {
    case question
    case option(Option)
}

// 画像ピッカービュー
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedQuestionImage: UIImage?
    @Binding var selectedOptionImage: UIImage?
    var target: ImagePickerTarget

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
        
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                switch parent.target {
                case .question:
                    parent.selectedQuestionImage = image
                case .option:
                    parent.selectedOptionImage = image
                }
            }
            picker.dismiss(animated: true)
        }
    }
}
