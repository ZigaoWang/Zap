//
//  NoteRowView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVKit
import AVFoundation

struct NoteRowView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Environment(\.colorScheme) var colorScheme
    let note: NoteItem
    @State private var showFullScreen = false
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        HStack(spacing: 15) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                    viewModel.toggleNoteCompletion(note)
                }
                playCompletionSound()
            }) {
                Image(systemName: note.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 30))
                    .foregroundColor(note.isCompleted ? appearanceManager.accentColor : .gray)
            }
            .buttonStyle(SpringButtonStyle())
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(note.timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
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
            }
        }
        .padding(.vertical, 8)
        .padding(.leading, note.isCompleted ? 20 : 0)
        .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        .opacity(note.isCompleted ? 0.6 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: note.isCompleted)
        .onTapGesture {
            showFullScreen = true
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            FullScreenNoteView(note: note, isPresented: $showFullScreen)
        }
        .onAppear {
            setupAudioPlayer()
        }
    }
    
    private func setupAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "completion_sound", withExtension: "mp3") else {
            print("Sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error setting up audio player: \(error.localizedDescription)")
        }
    }
    
    private func playCompletionSound() {
        audioPlayer?.play()
    }
}

struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: configuration.isPressed)
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
