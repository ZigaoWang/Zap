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
    
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            TextEditor(text: $text)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .navigationTitle("新文字笔记")
                .navigationBarTitleDisplayMode(.inline)
                .frame(height: 200)
            
            Button(action: {
                saveNote()
            }) {
                Text("保存")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding([.horizontal, .bottom])
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("提示"), message: Text(alertMessage), dismissButton: .default(Text("确定")))
        }
    }
    
    func saveNote() {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            alertMessage = "文字内容不能为空。"
            showingAlert = true
            return
        }
        viewModel.addTextNote(trimmedText)
        // 移除提示信息
        presentationMode.wrappedValue.dismiss()
    }
}

struct TextNoteView_Previews: PreviewProvider {
    static var previews: some View {
        TextNoteView()
            .environmentObject(NotesViewModel())
    }
}
