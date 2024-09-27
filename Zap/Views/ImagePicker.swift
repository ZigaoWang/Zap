//
//  ImagePicker.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import UIKit
import Photos

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
                let imageURL = saveImageToDocuments(image)
                parent.viewModel.addPhotoNote(url: imageURL)
                
                // Only save to album if the source is camera
                if parent.sourceType == .camera {
                    saveToAlbum(image: image)
                }
            } else if let videoURL = info[.mediaURL] as? URL {
                let savedVideoURL = saveVideoToDocuments(videoURL)
                let asset = AVAsset(url: savedVideoURL)
                let duration = asset.duration.seconds
                parent.viewModel.addVideoNote(url: savedVideoURL, duration: duration)
                
                // Only save to album if the source is camera
                if parent.sourceType == .camera {
                    saveToAlbum(videoURL: videoURL)
                }
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }

        private func saveImageToDocuments(_ image: UIImage) -> URL {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = UUID().uuidString + ".jpg"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            if let data = image.jpegData(compressionQuality: 1.0) {
                try? data.write(to: fileURL)
            }
            return fileURL
        }

        private func saveVideoToDocuments(_ videoURL: URL) -> URL {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = UUID().uuidString + ".mov"
            let destinationURL = documentsDirectory.appendingPathComponent(fileName)
            do {
                try FileManager.default.copyItem(at: videoURL, to: destinationURL)
            } catch {
                print("Error saving video: \(error)")
            }
            return destinationURL
        }

        private func saveToAlbum(image: UIImage? = nil, videoURL: URL? = nil) {
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else { return }
                
                PHPhotoLibrary.shared().performChanges {
                    if let image = image {
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    } else if let videoURL = videoURL {
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                    }
                } completionHandler: { success, error in
                    if success {
                        print("Saved to album successfully")
                    } else if let error = error {
                        print("Error saving to album: \(error)")
                    }
                }
            }
        }
    }
}
