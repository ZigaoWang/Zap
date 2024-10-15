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
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        if let index = viewModel.notes.firstIndex(where: { $0.id == note.id }) {
                                            viewModel.deleteNotes(at: IndexSet(integer: index))
                                            HapticManager.shared.impact(.rigid)
                                        }
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    withAnimation {
                                        viewModel.toggleNoteCompletion(note)
                                        HapticManager.shared.impact(.light)
                                    }
                                } label: {
                                    Label(note.isCompleted ? "Uncomplete" : "Complete", systemImage: note.isCompleted ? "xmark.circle" : "checkmark.circle")
                                }
                                .tint(note.isCompleted ? .orange : .green)
                            }
                    }
                }
                .listStyle(InsetGroupedListStyle())

                // Summarize button
                Button(action: {
                    viewModel.summarizeNotes()
                }) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Magically Summarize")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .disabled(viewModel.isSummarizing)
                .overlay(
                    Group {
                        if viewModel.isSummarizing {
                            HStack {
                                ProgressView()
                                Text("Generating summary...")
                            }
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                )

                // Zap buttons
                HStack(spacing: 15) {
                    zapButton(title: "Text", icon: "text.justify", color: .blue) {
                        showingTextNote = true
                    }
                    zapButton(title: "Audio", icon: "mic", color: .green) {
                        viewModel.startRecording()
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
