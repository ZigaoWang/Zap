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
                if viewModel.notes.isEmpty {
                    Text("No notes available")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.notes) { note in
                            NoteRowView(note: note)
                        }
                        .onDelete(perform: viewModel.deleteNotes)
                    }
                    .listStyle(InsetGroupedListStyle())
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

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
