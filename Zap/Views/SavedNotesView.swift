//
//  SavedNotesView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI

struct SavedNotesView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Environment(\.customFontSize) var fontSize
    
    var body: some View {
        NavigationView {
            Group {
                switch appearanceManager.listViewStyle {
                case .compact:
                    notesList.listStyle(InsetGroupedListStyle())
                case .standard:
                    notesList.listStyle(GroupedListStyle())
                case .expanded:
                    notesList.listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Saved Notes")
        }
        .font(.system(size: fontSize))
    }
    
    var notesList: some View {
        List {
            ForEach(viewModel.notes) { note in
                NoteRowView(note: note)
            }
            .onDelete(perform: deleteNotes)
        }
    }
    
    func deleteNotes(at offsets: IndexSet) {
        viewModel.deleteNotes(at: offsets)
    }
}
