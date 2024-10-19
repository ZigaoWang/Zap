//
// HomeView.swift
// Zap
//
// Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVFoundation

struct HomeView: View {
    @StateObject var viewModel = NotesViewModel()
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var showingSettings = false
    @State private var isOrganizing = false

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
                    .onDelete(perform: viewModel.deleteNotes)
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

                // Command button
                CommandButton(viewModel: viewModel)
                    .padding()
            }
            .navigationTitle("Zap Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.3)) {
                                isOrganizing = true
                            }
                            viewModel.organizeAndPlanNotes()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.3)) {
                                    isOrganizing = false
                                }
                            }
                        }) {
                            Image(systemName: "wand.and.stars")
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(viewModel.isSummarizing ? Color.gray : Color.purple)
                                        .shadow(color: .purple.opacity(0.3), radius: isOrganizing ? 10 : 0, x: 0, y: 0)
                                )
                                .scaleEffect(isOrganizing ? 1.1 : 1.0)
                                .rotationEffect(Angle(degrees: isOrganizing ? 360 : 0))
                        }
                        .disabled(viewModel.isSummarizing)

                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .accentColor(appearanceManager.accentColor)
        .font(.system(size: appearanceManager.fontSizeValue))
        .environmentObject(viewModel)
        .sheet(isPresented: $showingSettings) {
            SettingsView().environmentObject(appearanceManager)
        }
        .sheet(isPresented: $viewModel.showingTextInput) {
            TextInputView(content: $viewModel.textInputContent, onSave: {
                viewModel.addTextNote(viewModel.textInputContent)
                viewModel.textInputContent = ""
                viewModel.showingTextInput = false
            })
        }
        .sheet(isPresented: $viewModel.showingImagePicker) {
            ImagePicker(sourceType: .photoLibrary) { image in
                viewModel.handleCapturedImage(image)
            }
        }
        .sheet(isPresented: $viewModel.showingCamera) {
            ImagePicker(sourceType: .camera) { image in
                viewModel.handleCapturedImage(image)
            }
        }
        .sheet(isPresented: $viewModel.showingVideoRecorder) {
            VideoPicker { videoURL in
                viewModel.handleCapturedVideo(videoURL)
            }
        }
    }
}

struct TextInputView: View {
    @Binding var content: String
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            TextEditor(text: $content)
                .padding()
                .navigationTitle("New Note")
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
