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
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.notes) { note in
                        NoteRowView(note: note)
                    }
                    .onDelete(perform: viewModel.deleteNote)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("已保存的笔记")
            .toolbar {
                EditButton()
            }
        }
    }
}

struct SavedNotesView_Previews: PreviewProvider {
    static var previews: some View {
        SavedNotesView()
            .environmentObject(NotesViewModel())
    }
}
