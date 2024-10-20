//
//  TextInputView.swift
//  Zap
//
//  Created by Zigao Wang on 10/20/24.
//

import SwiftUI

struct TextInputView: View {
    @Binding var content: String
    var onSave: () -> Void

    var body: some View {
        NavigationView {
            TextEditor(text: $content)
                .padding()
                .navigationBarTitle("New Note", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        content = ""
                        onSave()
                    },
                    trailing: Button("Save") {
                        onSave()
                    }
                )
        }
    }
}
