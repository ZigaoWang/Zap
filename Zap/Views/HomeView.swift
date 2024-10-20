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
    @State private var selectedTab = "All"
    @State private var isOrganizing = false
    
    let tabs = ["All", "Text", "Audio", "Photo", "Video"]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top bar with logo, title, date, and icons
                HStack {
                    Image("ZapLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .cornerRadius(6)
                    
                    Text("Zap Notes")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(formattedDate())
                        .font(.subheadline)
                    
                    Button(action: {
                        organizeAndPlanNotes()
                    }) {
                        Image(systemName: "wand.and.stars")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(appearanceManager.accentColor)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isOrganizing)
                    
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                    }
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))

                // Tab bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(tabs, id: \.self) { tab in
                            Button(action: {
                                selectedTab = tab
                            }) {
                                Text(tab)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)
                                    .background(selectedTab == tab ? appearanceManager.accentColor : Color.clear)
                                    .foregroundColor(selectedTab == tab ? .white : .primary)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))

                // Notes list
                List {
                    ForEach(filteredNotes) { note in
                        NoteRowView(note: note)
                            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    }
                    .onDelete(perform: viewModel.deleteNotes)
                }
                .listStyle(PlainListStyle())

                // Command button (joystick)
                CommandButton(viewModel: viewModel)
                    .padding(.bottom, 8)
            }
            .navigationBarHidden(true)
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
        .overlay(
            Group {
                if isOrganizing {
                    ProgressView("Organizing notes...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
        )
    }
    
    private var filteredNotes: [NoteItem] {
        switch selectedTab {
        case "All":
            return viewModel.notes
        case "Text":
            return viewModel.notes.filter { if case .text = $0.type { return true } else { return false } }
        case "Audio":
            return viewModel.notes.filter { if case .audio = $0.type { return true } else { return false } }
        case "Photo":
            return viewModel.notes.filter { if case .photo = $0.type { return true } else { return false } }
        case "Video":
            return viewModel.notes.filter { if case .video = $0.type { return true } else { return false } }
        default:
            return viewModel.notes
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, EEEE"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }

    private func organizeAndPlanNotes() {
        isOrganizing = true
        Task {
            do {
                let organizedNotes = try await AIManager.shared.organizeAndPlanNotes(viewModel.notes)
                await MainActor.run {
                    viewModel.notes = organizedNotes + viewModel.notes
                    isOrganizing = false
                }
            } catch {
                print("Error organizing notes: \(error)")
                await MainActor.run {
                    isOrganizing = false
                    // Here you might want to show an alert to the user
                }
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

struct SummaryView: View {
    let summary: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                Text(summary)
                    .padding()
            }
            .navigationTitle("AI Summary")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
