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

                HStack(spacing: 10) {
                    mainActionButton(title: "Zap Text", icon: "text.justify", color: .blue) {
                        HapticManager.shared.impact(.medium)
                        showingTextNote = true
                    }

                    mainActionButton(title: viewModel.isRecording ? "Stop" : "Zap Audio",
                                     icon: viewModel.isRecording ? "stop.circle" : "mic",
                                     color: viewModel.isRecording ? .red : .green) {
                        if viewModel.isRecording {
                            viewModel.stopRecording()
                            HapticManager.shared.notification(.success)
                        } else {
                            viewModel.startRecording()
                            HapticManager.shared.impact(.heavy)
                        }
                    }

                    mainActionButton(title: "Album", icon: "photo.on.rectangle", color: .orange) {
                        HapticManager.shared.impact(.medium)
                        imagePickerSourceType = .photoLibrary
                        showingImagePicker = true
                    }

                    mainActionButton(title: "Camera", icon: "camera", color: .purple) {
                        HapticManager.shared.impact(.medium)
                        imagePickerSourceType = .camera
                        showingImagePicker = true
                    }
                }
                .frame(height: 70)
                .padding(.horizontal)
                .padding(.bottom, 8)
                Button(action: {
                    viewModel.summarizeNotes()
                }) {
                    Text("Summarize Notes")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isSummarizing)

                if viewModel.isSummarizing {
                    ProgressView("Summarizing...")
                } else if !viewModel.summary.isEmpty {
                    Text("Summary:")
                        .font(.headline)
                    Text(viewModel.summary)
                        .padding()
                }
            }
            .navigationTitle("Zap")
            .navigationBarItems(trailing:
                Button(action: {
                    HapticManager.shared.impact(.light)
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

    private func mainActionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
