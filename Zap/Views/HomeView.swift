//
// HomeView.swift
// Zap
//
// Created by Zigao Wang on 9/21/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var showingImagePicker = false
    @State private var showingCameraPicker = false
    @State private var showingTextNote = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.notes) { note in
                        NoteRowView(note: note)
                    }
                    .onDelete(perform: viewModel.deleteNotes)
                }

                HStack(spacing: 10) {
                    VStack(spacing: 10) {
                        ZapButton(title: "Zap Text", icon: "text.justify", color: .blue) {
                            hapticFeedback()
                            showingTextNote = true
                        }

                        ZapButton(title: "Album", icon: "photo.on.rectangle", color: .orange) {
                            hapticFeedback()
                            imagePickerSourceType = .photoLibrary
                            showingImagePicker = true
                        }
                    }

                    VStack(spacing: 10) {
                        ZapButton(title: viewModel.isRecording ? "Stop" : "Zap Audio", icon: viewModel.isRecording ? "stop.circle" : "mic", color: viewModel.isRecording ? .red : .green) {
                            hapticFeedback()
                            if viewModel.isRecording {
                                viewModel.stopRecording()
                            } else {
                                viewModel.startRecording()
                            }
                        }

                        ZapButton(title: "Camera", icon: "camera", color: .purple) {
                            hapticFeedback()
                            imagePickerSourceType = .camera
                            showingImagePicker = true
                        }
                    }
                }
                .frame(height: 150)
                .padding()
            }
            .navigationTitle("Zap")
            .navigationBarItems(trailing:
                Button(action: {
                    // Add action for settings button
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(.primary)
                }
            )
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: imagePickerSourceType)
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showingTextNote) {
                TextNoteView()
                    .environmentObject(viewModel)
            }
        }
        .font(.system(size: appearanceManager.fontSizeValue))
        .onChange(of: viewModel.notes.count) { _ in
            print("Notes updated, count: \(viewModel.notes.count)")
        }
    }

    func hapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

struct ZapButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 10)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
