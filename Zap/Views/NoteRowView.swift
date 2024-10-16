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
    @State private var isEditing = false
    @State private var editedContent = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 15) {
                Image(systemName: note.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(note.isCompleted ? appearanceManager.accentColor : .gray)
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(note.timestamp, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        if isEditable {
                            Button(action: {
                                isEditing.toggle()
                                if isEditing {
                                    editedContent = contentToEdit
                                }
                            }) {
                                Image(systemName: isEditing ? "xmark.circle" : "pencil")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    Group {
                        switch note.type {
                        case .text(let content):
                            Text(content)
                        case .audio(let fileName, let duration):
                            AudioPlayerInlineView(note: note)
                            if let transcription = note.transcription {
                                Text(transcription)
                            }
                        case .photo(let fileName):
                            ImagePreviewView(fileName: fileName)
                                .onTapGesture {
                                    showFullScreen = true
                                }
                        case .video(let fileName, let duration):
                            VideoPreviewView(fileName: fileName)
                                .onTapGesture {
                                    showFullScreen = true
                                }
                        }
                    }
                }
            }
            
            if isEditing {
                VStack {
                    TextEditor(text: $editedContent)
                        .frame(height: 100)
                        .border(Color.gray, width: 1)
                    
                    HStack {
                        Spacer()
                        Button("Save") {
                            saveEdits()
                            isEditing = false
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.top, 4)
                .transition(.opacity)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        .opacity(note.isCompleted ? 0.6 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: note.isCompleted)
        .fullScreenCover(isPresented: $showFullScreen) {
            FullScreenMediaView(note: note, isPresented: $showFullScreen)
        }
        .swipeActions(edge: .leading) {
            Button {
                viewModel.toggleNoteCompletion(note)
            } label: {
                Label(note.isCompleted ? "Uncomplete" : "Complete", systemImage: note.isCompleted ? "xmark.circle" : "checkmark.circle")
            }
            .tint(note.isCompleted ? .orange : .green)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                viewModel.deleteNote(note)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var isEditable: Bool {
        switch note.type {
        case .text, .audio:
            return true
        default:
            return false
        }
    }
    
    private var contentToEdit: String {
        switch note.type {
        case .text(let content):
            return content
        case .audio:
            return note.transcription ?? ""
        default:
            return ""
        }
    }
    
    private func saveEdits() {
        switch note.type {
        case .text:
            viewModel.editTextNote(note, newText: editedContent)
        case .audio:
            viewModel.editAudioTranscription(note, newTranscription: editedContent)
        default:
            break
        }
    }
}
