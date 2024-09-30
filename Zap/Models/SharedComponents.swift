//
//  SharedComponents.swift
//  Zap
//
//  Created by Zigao Wang on 9/29/24.
//

import SwiftUI
import AVKit

struct StrikethroughModifier: ViewModifier {
    let isCompleted: Bool
    
    func body(content: Content) -> some View {
        if isCompleted {
            content.overlay(Rectangle().frame(height: 1).foregroundColor(.gray))
        } else {
            content
        }
    }
}

struct ImagePreviewView: View {
    let fileName: String

    var body: some View {
        if let image = UIImage(contentsOfFile: getFilePath(fileName)) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
                .frame(maxWidth: .infinity)
        }
    }
}

struct VideoPreviewView: View {
    let fileName: String
    @State private var thumbnail: UIImage?

    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                    )
            } else {
                Image(systemName: "video")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            generateThumbnail()
        }
    }

    private func generateThumbnail() {
        let asset = AVAsset(url: URL(fileURLWithPath: getFilePath(fileName)))
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        do {
            let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            thumbnail = UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error)")
        }
    }
}

func getFilePath(_ fileName: String) -> String {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return documentsPath.appendingPathComponent(fileName).path
}

struct FullScreenImageView: View {
    let fileName: String
    
    var body: some View {
        if let image = UIImage(contentsOfFile: getFilePath(fileName)) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .edgesIgnoringSafeArea(.all)
        } else {
            Text("Image not found")
        }
    }
}

struct FullScreenVideoView: View {
    let fileName: String
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: URL(fileURLWithPath: getFilePath(fileName))))
            .edgesIgnoringSafeArea(.all)
    }
}
