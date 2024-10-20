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
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 12) {
            completionButton
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    noteTypeIcon
                    Text(note.timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.white)
                    Spacer()
                    editButton
                    deleteButton
                }
                
                noteContent
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(noteBackgroundColor)
        .cornerRadius(16)
        .shadow(color: noteBackgroundColor.opacity(0.3), radius: 5, x: 0, y: 3)
        .opacity(note.isCompleted ? 0.7 : 1)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: note.isCompleted)
        .fullScreenCover(isPresented: $showFullScreen) {
            FullScreenMediaView(note: note, isPresented: $showFullScreen)
        }
        .sheet(isPresented: $isEditing) {
            EditNoteView(note: note) { updatedNote in
                viewModel.updateNote(updatedNote)
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Note"),
                message: Text("Are you sure you want to delete this note?"),
                primaryButton: .destructive(Text("Delete")) {
                    viewModel.deleteNote(note)
                },
                secondaryButton: .cancel()
            )
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
    
    private var completionButton: some View {
        Button(action: {
            viewModel.toggleNoteCompletion(note)
        }) {
            Image(systemName: note.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundColor(.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var noteTypeIcon: some View {
        Image(systemName: noteTypeIconName)
            .foregroundColor(.white)
            .font(.system(size: 16))
    }
    
    private var noteTypeIconName: String {
        switch note.type {
        case .text: return "text.bubble.fill"
        case .audio: return "mic.circle.fill"
        case .photo: return "camera.fill"
        case .video: return "video.fill"
        }
    }
    
    private var noteBackgroundColor: Color {
        switch note.type {
        case .text: return .green
        case .audio: return .blue
        case .photo: return .orange
        case .video: return .red
        }
    }
    
    private var editButton: some View {
        Group {
            if isEditable {
                Button(action: {
                    isEditing = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            showingDeleteAlert = true
        }) {
            Image(systemName: "trash")
                .font(.system(size: 16))
                .foregroundColor(.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var noteContent: some View {
        Group {
            switch note.type {
            case .text(let content):
                Text(content)
                    .lineLimit(2)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            case .audio(_, let duration):
                VStack(alignment: .leading, spacing: 4) {
                    AudioPlayerInlineView(note: note)
                        .accentColor(.white)
                        .tint(.white)
                    if let transcription = note.transcription {
                        Text(transcription)
                            .lineLimit(2)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }
            case .photo(let fileName):
                HStack {
                    ImagePreviewView(fileName: fileName)
                        .frame(width: 70, height: 70)
                        .cornerRadius(10)
                    Text("Photo Note")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                .onTapGesture { showFullScreen = true }
            case .video(let fileName, let duration):
                HStack {
                    VideoPreviewView(fileName: fileName)
                        .frame(width: 70, height: 70)
                        .cornerRadius(10)
                    VStack(alignment: .leading) {
                        Text("Video Note")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                        Text(formatDuration(duration))
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }
                .onTapGesture { showFullScreen = true }
            }
        }
    }
    
    private var isEditable: Bool {
        switch note.type {
        case .text, .audio: return true
        default: return false
        }
    }
    
    private var contentToEdit: String {
        switch note.type {
        case .text(let content): return content
        case .audio: return note.transcription ?? ""
        default: return ""
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
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? "0:00"
    }
}
