//
//  VideoThumbnailView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVFoundation

struct VideoThumbnailView: View {
    let videoURL: URL
    @State private var thumbnail: UIImage?
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 100)
                    .clipped()
            } else {
                Color.gray
                    .frame(height: 100)
                    .overlay(ProgressView())
            }
        }
        .onAppear(perform: generateThumbnail)
    }
    
    private func generateThumbnail() {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            DispatchQueue.main.async {
                thumbnail = UIImage(cgImage: cgImage)
            }
        } catch {
            DispatchQueue.main.async {
                errorMessage = "Error generating thumbnail: \(error.localizedDescription)"
            }
        }
    }
}
