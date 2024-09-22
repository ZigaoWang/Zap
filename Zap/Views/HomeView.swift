//
// HomeView.swift
// Zap
//
// Created by Zigao Wang on 9/21/24.
//

import SwiftUI

enum ImagePickerDestination {
    case photoVideo
    case cameraPhotoVideo
}

struct HomeView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    @State private var showingImagePicker = false
    @State private var imagePickerDestination: ImagePickerDestination = .photoVideo
    @State private var showingTextNote = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ZapButton(title: "Zap Text", icon: "text.justify", color: .blue) {
                    hapticFeedback()
                    showingTextNote = true
                }

                ZapButton(title: viewModel.isRecording ? "Stop Recording" : "Zap Audio", icon: viewModel.isRecording ? "stop.circle" : "mic", color: viewModel.isRecording ? .red : .green) {
                    hapticFeedback()
                    if viewModel.isRecording {
                        viewModel.stopRecording()
                    } else {
                        viewModel.startRecording()
                    }
                }

                ZapButton(title: "Choose from Album", icon: "photo.on.rectangle", color: .orange) {
                    hapticFeedback()
                    imagePickerDestination = .photoVideo
                    showingImagePicker = true
                }

                ZapButton(title: "Zap Photo/Video", icon: "camera", color: .purple) {
                    hapticFeedback()
                    imagePickerDestination = .cameraPhotoVideo
                    showingImagePicker = true
                }
            }
            .padding()
            .navigationTitle("Zap")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(destination: imagePickerDestination)
            }
            .sheet(isPresented: $showingTextNote) {
                TextNoteView()
            }
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
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .buttonStyle(SpringButtonStyle())
    }
}

struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(NotesViewModel())
    }
}
