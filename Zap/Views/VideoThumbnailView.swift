//
//  VideoThumbnailView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVFoundation
import UIKit // 确保导入 UIKit

struct VideoThumbnailView: View {
    let videoURL: URL
    @State private var thumbnail: UIImage? = nil

    var body: some View {
        ZStack {
            if let thumb = thumbnail {
                Image(uiImage: thumb)
                    .resizable()
                    .scaledToFill()
                    .overlay(
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white.opacity(0.7))
                    )
            } else {
                Color.gray.opacity(0.3)
                    .overlay(
                        ProgressView()
                    )
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }

    func loadThumbnail() {
        let cacheKey = videoURL.absoluteString
        if let cachedImage = ImageCache.shared.getImage(forKey: cacheKey) {
            self.thumbnail = cachedImage
            return
        }

        DispatchQueue.global().async {
            let asset = AVAsset(url: videoURL)
            let assetImgGenerate = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 1, preferredTimescale: 60)
            do {
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: img)
                ImageCache.shared.setImage(uiImage, forKey: cacheKey)
                DispatchQueue.main.async {
                    self.thumbnail = uiImage
                }
            } catch {
                print("无法生成缩略图: \(error.localizedDescription)")
            }
        }
    }
}

struct VideoThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        VideoThumbnailView(videoURL: Bundle.main.url(forResource: "sample", withExtension: "mp4")!)
    }
}
