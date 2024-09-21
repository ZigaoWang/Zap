//
//  ImagePicker.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import UIKit
import AVFoundation

enum ImagePickerDestination {
    case photo
    case video
    case photoVideo
}

struct ImagePicker: UIViewControllerRepresentable {
    var destination: ImagePickerDestination
    @Environment(\.presentationMode) var presentationMode
    var viewModel: NotesViewModel

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let mediaType = info[.mediaType] as? String {
                if mediaType == "public.image" {
                    if let uiImage = info[.originalImage] as? UIImage {
                        // 保存图片到文件系统
                        let filename = UUID().uuidString + ".jpg"
                        let url = getDocumentsDirectory().appendingPathComponent(filename)
                        if let data = uiImage.jpegData(compressionQuality: 0.8) {
                            do {
                                try data.write(to: url)
                                parent.viewModel.addPhotoNote(url: url)
                            } catch {
                                print("保存图片失败: \(error.localizedDescription)")
                            }
                        }
                    }
                } else if mediaType == "public.movie" {
                    if let mediaURL = info[.mediaURL] as? URL {
                        // 保存视频到文件系统
                        let filename = UUID().uuidString + ".mp4"
                        let destinationURL = getDocumentsDirectory().appendingPathComponent(filename)
                        do {
                            try FileManager.default.copyItem(at: mediaURL, to: destinationURL)
                            // 获取持续时间
                            let asset = AVURLAsset(url: destinationURL)
                            let duration = CMTimeGetSeconds(asset.duration)
                            parent.viewModel.addVideoNote(url: destinationURL, duration: duration)
                        } catch {
                            print("保存视频失败: \(error.localizedDescription)")
                        }
                    }
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func getDocumentsDirectory() -> URL {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator

        switch destination {
        case .photo:
            picker.sourceType = .camera
            picker.mediaTypes = ["public.image"]
        case .video:
            picker.sourceType = .camera
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeHigh
        case .photoVideo:
            picker.sourceType = .photoLibrary // 从图库选择
            picker.mediaTypes = ["public.image", "public.movie"]
            picker.videoQuality = .typeHigh
        }

        picker.allowsEditing = false
        picker.videoMaximumDuration = 300 // 最大5分钟
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct ImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        ImagePicker(destination: .photoVideo, viewModel: NotesViewModel())
    }
}
