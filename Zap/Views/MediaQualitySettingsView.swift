//
//  MediaQualitySettingsView.swift
//  Zap
//
//  Created by Zigao Wang on 9/28/24.
//

import SwiftUI

struct MediaQualitySettingsView: View {
    @EnvironmentObject var mediaQualitySettings: MediaQualitySettings
    
    var body: some View {
        Form {
            Section(header: Text("Video Quality")) {
                Picker("Resolution", selection: $mediaQualitySettings.videoResolution) {
                    ForEach(MediaQualitySettings.VideoResolution.allCases) { resolution in
                        Text(resolution.rawValue).tag(resolution)
                    }
                }
            }
            
            Section(header: Text("Photo Quality")) {
                Toggle("Enable HDR", isOn: $mediaQualitySettings.enableHDR)
                Toggle("Enable Live Photos", isOn: $mediaQualitySettings.enableLivePhotos)
            }
        }
        .navigationTitle("Media Quality")
    }
}
