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
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Environment(\.colorScheme) var colorScheme
    let note: NoteItem
    
    var body: some View {
        HStack(spacing: 15) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                    viewModel.toggleNoteCompletion(note)
                }
                // Removed playCompletionSound() call
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
    }
}

struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: configuration.isPressed)
    }
}
