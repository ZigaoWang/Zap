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
    @State private var selectedTab = "全部"
    
    let tabs = ["全部", "文字", "音频", "照片", "视频"]

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
    }
    
    private var filteredNotes: [NoteItem] {
        switch selectedTab {
        case "全部":
            return viewModel.notes
        case "文字":
            return viewModel.notes.filter { if case .text = $0.type { return true } else { return false } }
        case "音频":
            return viewModel.notes.filter { if case .audio = $0.type { return true } else { return false } }
        case "照片":
            return viewModel.notes.filter { if case .photo = $0.type { return true } else { return false } }
        case "视频":
            return viewModel.notes.filter { if case .video = $0.type { return true } else { return false } }
        default:
            return viewModel.notes
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: Date())
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
