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
    @State private var showFullScreen = false
    @State private var showingEditView = false
    
    var body: some View {
        HStack(spacing: 15) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                    viewModel.toggleNoteCompletion(note)
                }
            }) {
                Image(systemName: note.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 30))
                    .foregroundColor(note.isCompleted ? appearanceManager.accentColor : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(note.timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: {
                        showingEditView = true
                    }) {
                        Image(systemName: "pencil")
                    }
                }
                
                Group {
                    switch note.type {
                    case .text(let content):
                        Text(content)
                            .lineLimit(2)
                    case .audio:
                        AudioPlayerInlineView(note: note)
                    case .photo(let fileName):
                        ImagePreviewView(fileName: fileName)
                            .onTapGesture {
                                showFullScreen = true
                            }
                    case .video(let fileName, _):
                        VideoPreviewView(fileName: fileName)
                            .onTapGesture {
                                showFullScreen = true
                            }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.leading, note.isCompleted ? 20 : 0)
        .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        .opacity(note.isCompleted ? 0.6 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: note.isCompleted)
        .fullScreenCover(isPresented: $showFullScreen) {
            FullScreenMediaView(note: note, isPresented: $showFullScreen)
        }
        .sheet(isPresented: $showingEditView) {
            editView
        }
    }
    
    @ViewBuilder
    private var editView: some View {
        switch note.type {
        case .text:
            TextNoteEditView(note: note)
        case .audio:
            AudioNoteEditView(note: note)
        case .photo:
            PhotoNoteEditView(note: note)
        case .video:
            Text("Video editing not implemented")
        }
    }
}
