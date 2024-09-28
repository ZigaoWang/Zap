//
//  MediaQualitySettings.swift
//  Zap
//
//  Created by Zigao Wang on 9/28/24.
//

import Foundation

class MediaQualitySettings: ObservableObject {
    @Published var videoResolution: VideoResolution = .hd1080p
    @Published var enableHDR: Bool = false
    @Published var enableLivePhotos: Bool = false
    
    enum VideoResolution: String, CaseIterable, Identifiable {
        case hd720p = "720p"
        case hd1080p = "1080p"
        case hd4K = "4K"
        
        var id: String { self.rawValue }
    }
}
