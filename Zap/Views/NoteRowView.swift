//
//  NoteRowView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI

struct NoteRowView: View {
    let note: NoteItem
    @EnvironmentObject var viewModel: NotesViewModel

    @State private var showImageFullScreen = false
    @State private var selectedImage: UIImage?
    @State private var showVideoPlayer = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 时间戳显示
            Text("创建时间: \(formattedDate(note.timestamp))")
                .font(.caption)
                .foregroundColor(.gray)

            // 笔记内容根据类型展示
            switch note.type {
            case .text(let text):
                Text(text)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)

            case .audio(let url, _):
                AudioPlayerInlineView(url: url)
                    .padding(.vertical, 5)

            case .photo(let url):
                if let uiImage = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(10)
                        .onTapGesture {
                            selectedImage = uiImage
                            showImageFullScreen = true
                        }
                        .sheet(isPresented: $showImageFullScreen) {
                            if let image = selectedImage {
                                ImageFullscreenView(image: image, isPresented: $showImageFullScreen)
                            }
                        }
                }

            case .video(let url, _):
                VideoThumbnailView(videoURL: url)
                    .frame(height: 200)
                    .cornerRadius(10)
                    .onTapGesture {
                        showVideoPlayer = true
                    }
                    .sheet(isPresented: $showVideoPlayer) {
                        VideoPlayerView(url: url, isPresented: $showVideoPlayer)
                    }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 5)
        .padding([.horizontal, .top], 10)
    }

    // 格式化日期显示
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

struct NoteRowView_Previews: PreviewProvider {
    static var previews: some View {
        NoteRowView(
            note: NoteItem(
                id: UUID(),
                timestamp: Date(),
                type: .audio(Bundle.main.url(forResource: "sample", withExtension: "m4a")!, 120.0)
            )
        )
        .environmentObject(NotesViewModel())
    }
}
