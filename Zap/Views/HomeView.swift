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
    @State private var showingSettings = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.notes) { note in
                        NoteRowView(note: note)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    if let index = viewModel.notes.firstIndex(where: { $0.id == note.id }) {
                                        viewModel.deleteNotes(at: IndexSet(integer: index))
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    viewModel.toggleNoteCompletion(note)
                                } label: {
                                    Label(note.isCompleted ? "Uncomplete" : "Complete", systemImage: note.isCompleted ? "xmark.circle" : "checkmark.circle")
                                }
                                .tint(note.isCompleted ? .orange : .green)
                            }
                    }
                }

                HStack(spacing: 10) {
                    Button(action: {
                        hapticFeedback()
                        showingTextNote = true
                    }) {
                        VStack {
                            Image(systemName: "text.justify")
                                .font(.system(size: 24))
                            Text("Zap Text")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }

                    Button(action: {
                        hapticFeedback()
                        if viewModel.isRecording {
                            viewModel.stopRecording()
                        } else {
                            viewModel.startRecording()
                        }
                    }) {
                        VStack {
                            Image(systemName: viewModel.isRecording ? "stop.circle" : "mic")
                                .font(.system(size: 24))
                            Text(viewModel.isRecording ? "Stop" : "Zap Audio")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(viewModel.isRecording ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }

                    Button(action: {
                        hapticFeedback()
                        imagePickerSourceType = .photoLibrary
                        showingImagePicker = true
                    }) {
                        VStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 24))
                            Text("Album")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }

                    Button(action: {
                        hapticFeedback()
                        imagePickerSourceType = .camera
                        showingImagePicker = true
                    }) {
                        VStack {
                            Image(systemName: "camera")
                                .font(.system(size: 24))
                            Text("Camera")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .frame(height: 70)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .navigationTitle("Zap")
            .navigationBarItems(trailing:
                Button(action: {
                    showingSettings = true
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
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(appearanceManager)
            }
        }
        .accentColor(appearanceManager.accentColor)
        .font(.system(size: appearanceManager.fontSizeValue))
    }

    func hapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(NotesViewModel())
            .environmentObject(AppearanceManager())
    }
}
