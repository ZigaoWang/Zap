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
                    }
                    .onDelete(perform: viewModel.deleteNotes)
                }

                HStack(spacing: 10) {
                    ZapButton(title: "Zap Text", icon: "text.justify", color: .blue) {
                        hapticFeedback()
                        showingTextNote = true
                    }

                    ZapButton(title: viewModel.isRecording ? "Stop" : "Zap Audio", icon: viewModel.isRecording ? "stop.circle" : "mic", color: viewModel.isRecording ? .red : .green) {
                        hapticFeedback()
                        if viewModel.isRecording {
                            viewModel.stopRecording()
                        } else {
                            viewModel.startRecording()
                        }
                    }

                    ZapButton(title: "Album", icon: "photo.on.rectangle", color: .orange) {
                        hapticFeedback()
                        imagePickerSourceType = .photoLibrary
                        showingImagePicker = true
                    }

                    ZapButton(title: "Camera", icon: "camera", color: .purple) {
                        hapticFeedback()
                        imagePickerSourceType = .camera
                        showingImagePicker = true
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
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(NotesViewModel())
            .environmentObject(AppearanceManager())
    }
}
