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
    let sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.mediaTypes = ["public.image", "public.movie"]
        picker.videoQuality = .typeHigh
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
                let fileName = saveImageToDocuments(image)
                parent.viewModel.addPhotoNote(fileName: fileName)
            } else if let videoURL = info[.mediaURL] as? URL {
                let fileName = saveVideoToDocuments(videoURL)
                let asset = AVAsset(url: videoURL)
                let duration = asset.duration.seconds
                parent.viewModel.addVideoNote(fileName: fileName, duration: duration)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        private func saveImageToDocuments(_ image: UIImage) -> String {
            let fileName = UUID().uuidString + ".jpg"
            let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
            if let data = image.jpegData(compressionQuality: 0.8) {
                try? data.write(to: fileURL)
            }
            return fileName
        }

        private func saveVideoToDocuments(_ videoURL: URL) -> String {
            let fileName = UUID().uuidString + ".mov"
            let destinationURL = getDocumentsDirectory().appendingPathComponent(fileName)
            try? FileManager.default.copyItem(at: videoURL, to: destinationURL)
            return fileName
        }

        private func getDocumentsDirectory() -> URL {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }
    }
}
