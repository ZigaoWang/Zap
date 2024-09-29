//
//  NoteRowView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVKit

struct NoteRowView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    let note: NoteItem
    @State private var showFullScreen = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    viewModel.toggleNoteCompletion(note)
                }) {
                    Image(systemName: note.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(note.isCompleted ? .green : .gray)
                }
                .buttonStyle(PlainButtonStyle())

                Text(note.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Group {
                switch note.type {
                case .text(let content):
                    Text(content)
                        .lineLimit(2)
                case .audio(let fileName, _):
                    AudioPlayerInlineView(url: URL(fileURLWithPath: getFilePath(fileName)))
                case .photo(let fileName):
                    ImagePreviewView(fileName: fileName)
                case .video(let fileName, _):
                    VideoPreviewView(fileName: fileName)
                }
            }
            .modifier(StrikethroughModifier(isCompleted: note.isCompleted))
        }
        .padding(.vertical, 8)
        .onTapGesture {
            showFullScreen = true
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            FullScreenNoteView(note: note, isPresented: $showFullScreen)
        }
    }
}

struct FullScreenNoteView: View {
    let note: NoteItem
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            VStack {
                switch note.type {
                case .text(let content):
                    ScrollView {
                        Text(content)
                            .padding()
                    }
                case .audio(let fileName, _):
                    AudioPlayerInlineView(url: URL(fileURLWithPath: getFilePath(fileName)))
                case .photo(let fileName):
                    FullScreenImageView(fileName: fileName)
                case .video(let fileName, _):
                    FullScreenVideoView(fileName: fileName)
                }
            }
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            })
            .navigationBarTitle(noteTypeTitle, displayMode: .inline)
        }
    }

    private var noteTypeTitle: String {
        switch note.type {
        case .text: return "Text Note"
        case .audio: return "Audio Note"
        case .photo: return "Photo Note"
        case .video: return "Video Note"
        }
    }
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
