//
//  TextNoteView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI

struct TextNoteView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: NotesViewModel
    @State private var noteText = ""

    var body: some View {
        NavigationView {
            TextEditor(text: $noteText)
                .padding()
                .navigationBarTitle("New Text Note", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Save") {
                        viewModel.addTextNote(noteText)
                        presentationMode.wrappedValue.dismiss()
                    }
                )
        }
    }
}
