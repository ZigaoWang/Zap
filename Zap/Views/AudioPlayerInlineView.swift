//
//  AudioPlayerInlineView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVFoundation

struct AudioPlayerInlineView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var playbackTime: Double = 0
    @State private var duration: Double = 0
    @State private var timer: Timer?

    let url: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
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
        .onAppear {
            setupAudioPlayer()
        }
        .onDisappear {
            stopTimer()
            audioPlayer?.stop()
        }
    }

    private func setupAudioPlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            duration = audioPlayer?.duration ?? 0
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error setting up audio player: \(error.localizedDescription)")
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
}
