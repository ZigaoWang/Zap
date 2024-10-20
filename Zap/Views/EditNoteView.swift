//
//  EditNoteView.swift
//  Zap
//
//  Created by Zigao Wang on 10/20/24.
//

import SwiftUI

struct EditNoteView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var editedContent: String
    let note: NoteItem
    let onSave: (NoteItem) -> Void

    init(note: NoteItem, onSave: @escaping (NoteItem) -> Void) {
        self.note = note
        self.onSave = onSave
        
        switch note.type {
        case .text(let content):
            _editedContent = State(initialValue: content)
        case .audio(_, _), .photo(_), .video(_, _):
            _editedContent = State(initialValue: note.transcription ?? "")
        }
    }

    var body: some View {
        NavigationView {
            TextEditor(text: $editedContent)
                .padding()
                .navigationBarTitle("Edit Note", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Save") {
                        var updatedNote = note
                        switch updatedNote.type {
                        case .text:
                            updatedNote.type = .text(editedContent)
                        case .audio, .photo, .video:
                            updatedNote.transcription = editedContent
                        }
                        onSave(updatedNote)
                        presentationMode.wrappedValue.dismiss()
                    }
                )
        }
    }
}
