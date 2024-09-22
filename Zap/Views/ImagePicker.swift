//
//  ImagePicker.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVFoundation

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: NotesViewModel
    let destination: ImagePickerDestination

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        switch destination {
        case .photoVideo:
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.image", "public.movie"]
        case .cameraPhotoVideo:
            picker.sourceType = .camera
            picker.mediaTypes = ["public.image", "public.movie"]
            picker.cameraCaptureMode = .photo
        }
        
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

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                let imageURL = saveImage(image)
                parent.viewModel.addPhotoNote(url: imageURL)
            } else if let videoURL = info[.mediaURL] as? URL {
                let asset = AVAsset(url: videoURL)
                let duration = asset.duration.seconds
                parent.viewModel.addVideoNote(url: videoURL, duration: duration)
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }

        private func saveImage(_ image: UIImage) -> URL {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = UUID().uuidString
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                try? imageData.write(to: fileURL, options: .atomic)
            }
            return fileURL
        }
    }
}
