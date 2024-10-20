//
//  ToDoListView.swift
//  Zap
//
//  Created by Zigao Wang on 10/20/24.
//

import SwiftUI

struct ToDoListView: View {
    @Binding var notes: [NoteItem]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(notes) { note in
                    HStack {
                        Button(action: {
                            toggleNoteCompletion(note)
                        }) {
                            Image(systemName: note.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(note.isCompleted ? .green : .gray)
                        }
                        Text(noteContent(for: note))
                            .strikethrough(note.isCompleted)
                    }
                }
            }
            .navigationTitle("To-Do List")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func toggleNoteCompletion(_ note: NoteItem) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isCompleted.toggle()
        }
    }

    private func noteContent(for note: NoteItem) -> String {
        switch note.type {
        case .text(let content):
            return content
        case .audio:
            return "Audio Note"
        case .photo:
            return "Photo Note"
        case .video:
            return "Video Note"
        }
    }
}
