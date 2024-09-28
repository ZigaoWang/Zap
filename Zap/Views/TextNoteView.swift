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
    @State private var text: String = ""

    var body: some View {
        NavigationView {
            TextEditor(text: $text)
                .padding()
                .navigationTitle("Zap Text!")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Save") {
                        viewModel.addTextNote(text)
                        presentationMode.wrappedValue.dismiss()
                    }
                )
        }
    }
}

struct TextNoteView_Previews: PreviewProvider {
    static var previews: some View {
        TextNoteView().environmentObject(NotesViewModel())
    }
}
