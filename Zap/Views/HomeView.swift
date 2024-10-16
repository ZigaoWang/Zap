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
    @State private var showingTextNote = false
    @State private var showingSettings = false
    @State private var showingImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Notes list
                List {
                    if !viewModel.summary.isEmpty {
                        Section(header: Text("Summary")) {
                            Text(viewModel.summary)
                                .font(.subheadline)
                        }
                    }
                    
                    ForEach(viewModel.notes) { note in
                        NoteRowView(note: note)
                    }
                }
                .listStyle(InsetGroupedListStyle())

                // Summarize button
                Button(action: {
                    viewModel.summarizeNotes()
                }) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text(viewModel.isSummarizing ? "Generating Summary..." : "Magic Summary")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isSummarizing ? Color.gray : Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isSummarizing)
                .padding()

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                // Zap buttons
                HStack(spacing: 15) {
                    zapButton(title: "Text", icon: "text.justify", color: .blue) {
                        showingTextNote = true
                    }
                    zapButton(title: viewModel.isRecording ? "Stop" : "Audio",
                              icon: viewModel.isRecording ? "stop.circle" : "mic",
                              color: viewModel.isRecording ? .red : .green) {
                        if viewModel.isRecording {
                            viewModel.stopRecording()
                        } else {
                            viewModel.startRecording()
                        }
                    }
                    zapButton(title: "Camera", icon: "camera", color: .orange) {
                        imageSource = .camera
                        showingImagePicker = true
                    }
                    zapButton(title: "Album", icon: "photo", color: .purple) {
                        imageSource = .photoLibrary
                        showingImagePicker = true
                    }
                }
                .padding()
            }
            .navigationTitle("Zap")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .accentColor(appearanceManager.accentColor)
        .font(.system(size: appearanceManager.fontSizeValue))
        .sheet(isPresented: $showingTextNote) {
            TextNoteView().environmentObject(viewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView().environmentObject(appearanceManager)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: imageSource)
        }
    }

    private func zapButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

// HapticManager to centralize haptic feedback
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
