//
//  AudioPlayerInlineView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVFoundation
import Speech

struct AudioPlayerInlineView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @EnvironmentObject var viewModel: NotesViewModel
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var playbackTime: Double = 0
    @State private var duration: Double = 0
    @State private var timer: Timer?
    @State private var isTranscribing = false
    @State private var transcriptionError: String?
    @State private var fileExists: Bool = false
    @State private var playerError: String?
    @State private var detectedLanguage: String = ""
    
    let note: NoteItem

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if fileExists {
                if let error = playerError {
                    Text("Playback error: \(error)")
                        .foregroundColor(.red)
                } else {
                    HStack {
                        Button(action: {
                            togglePlayPause()
                        }) {
                            Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(isPlaying ? .red : appearanceManager.accentColor)
                        }

                        Slider(value: $playbackTime, in: 0...duration, onEditingChanged: { editing in
                            if !editing {
                                audioPlayer?.currentTime = playbackTime
                            }
                        })
                        .accentColor(appearanceManager.accentColor)

                        Text(formatTime(playbackTime))
                            .font(.caption)
                    }
                }
            } else {
                Text("Audio file not found")
                    .foregroundColor(.red)
            }
            
            if isTranscribing {
                ProgressView("Transcribing...")
                    .padding(.top, 4)
            } else if let transcription = note.transcription, !transcription.isEmpty {
                VStack(alignment: .leading) {
                    Text(transcription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Detected Language: \(detectedLanguage)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            } else if let error = transcriptionError {
                Text("Transcription failed: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
        }
        .onAppear {
            checkFileExists()
            setupAudioPlayer()
            if let transcription = note.transcription {
                detectedLanguage = viewModel.detectLanguage(for: transcription)
            }
        }
        .onDisappear {
            stopTimer()
            audioPlayer?.stop()
        }
    }

    private func checkFileExists() {
        guard case .audio(let fileName, _) = note.type else {
            print("Note is not an audio note")
            return
        }
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        fileExists = FileManager.default.fileExists(atPath: url.path)
        print("Audio file exists: \(fileExists), path: \(url.path)")
    }

    private func setupAudioPlayer() {
        guard case .audio(let fileName, _) = note.type else {
            print("Note is not an audio note")
            return
        }
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            duration = audioPlayer?.duration ?? 0
            audioPlayer?.prepareToPlay()
            playerError = nil
        } catch {
            print("Error setting up audio player: \(error.localizedDescription)")
            playerError = error.localizedDescription
        }
    }

    private func togglePlayPause() {
        if isPlaying {
            audioPlayer?.pause()
            stopTimer()
        } else {
            audioPlayer?.play()
            startTimer()
        }
        isPlaying.toggle()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let player = audioPlayer {
                playbackTime = player.currentTime
                if !player.isPlaying {
                    isPlaying = false
                    stopTimer()
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
