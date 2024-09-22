//
//  SavedNotesView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI

struct SavedNotesView: View {
    @EnvironmentObject var viewModel: NotesViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.notes) { note in
                    NoteRowView(note: note)
                }
                .onDelete(perform: deleteNotes)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Saved Notes")
        }
    }
    
    func deleteNotes(at offsets: IndexSet) {
        viewModel.deleteNotes(at: offsets)
    }
}

struct SavedNotesView_Previews: PreviewProvider {
    static var previews: some View {
        SavedNotesView().environmentObject(NotesViewModel())
    }
}
