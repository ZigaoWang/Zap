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
                Text(transcription)
                    .font(.caption)
                    .foregroundColor(.secondary)
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
            if note.transcription == nil {
                transcribeAudio()
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

    private func transcribeAudio() {
        guard case .audio(let fileName, _) = note.type else {
            print("Note is not an audio note")
            return
        }
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Audio file does not exist at path: \(url.path)")
            transcriptionError = "Audio file not found"
            return
        }
        
        isTranscribing = true
        transcriptionError = nil
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
                    let request = SFSpeechURLRecognitionRequest(url: url)
                    
                    recognizer?.recognitionTask(with: request) { result, error in
                        isTranscribing = false
                        
                        if let error = error {
                            transcriptionError = error.localizedDescription
                            print("Recognition failed with error: \(error)")
                            return
                        }
                        
                        guard let result = result else {
                            transcriptionError = "No transcription result"
                            return
                        }
                        
                        let transcription = result.bestTranscription.formattedString
                        viewModel.updateTranscription(for: note, with: transcription)
                    }
                } else {
                    isTranscribing = false
                    transcriptionError = "Speech recognition not authorized"
                    print("Speech recognition not authorized")
                }
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
