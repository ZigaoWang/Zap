//
//  NoteRowView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI

struct NoteRowView: View {
    let note: NoteItem
    @State private var showFullScreen = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(note.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(formattedDuration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            switch note.type {
            case .text(let content):
                Text(content)
                    .lineLimit(3)
            case .audio(let fileName, let duration):
                let url = getDocumentsDirectory().appendingPathComponent(fileName)
                AudioPlayerView(url: url, duration: duration)
            case .photo(let fileName):
                let url = getDocumentsDirectory().appendingPathComponent(fileName)
                Image(uiImage: UIImage(contentsOfFile: url.path) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .onTapGesture { showFullScreen = true }
            case .video(let fileName, _):
                let url = getDocumentsDirectory().appendingPathComponent(fileName)
                VideoThumbnailView(videoURL: url)
                    .onTapGesture { showFullScreen = true }
            }
        }
        .padding(.vertical, 8)
        .fullScreenCover(isPresented: $showFullScreen) {
            FullScreenMediaView(note: note, isPresented: $showFullScreen)
        }
    }

    private var formattedDuration: String {
        switch note.type {
        case .text:
            return ""
        case .audio(_, let duration), .video(_, let duration):
            return String(format: "%.1f sec", duration)
        case .photo:
            return ""
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
