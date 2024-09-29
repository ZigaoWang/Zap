//
//  AudioPlayerInlineView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVFoundation

struct AudioPlayerInlineView: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var playbackTime: Double = 0
    @State private var duration: Double = 0
    @State private var timer: Timer?

    let url: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isPlaying ? .red : .green)
                    .onTapGesture {
                        togglePlayPause()
                    }

                Slider(value: $playbackTime, in: 0...duration, onEditingChanged: { editing in
                    if !editing {
                        audioPlayer?.currentTime = playbackTime
                    }
                })

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

    func setupAudioPlayer() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)

                audioPlayer = try AVAudioPlayer(contentsOf: url)
                duration = audioPlayer?.duration ?? 0
                audioPlayer?.delegate = AudioPlayerDelegate(isPlaying: $isPlaying)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Unable to load audio file: \(error.localizedDescription)")
            }
        }
    }

    func togglePlayPause() {
        guard let player = audioPlayer else { return }
        if isPlaying {
            player.stop()
            isPlaying = false
            stopTimer()
        } else {
            player.play()
            isPlaying = true
            startTimer()
        }
    }

    func startTimer() {
        playbackTime = audioPlayer?.currentTime ?? 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let player = self.audioPlayer {
                self.playbackTime = player.currentTime
                if !player.isPlaying {
                    self.isPlaying = false
                    self.stopTimer()
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func formatTime(_ time: Double) -> String {
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    @Binding var isPlaying: Bool

    init(isPlaying: Binding<Bool>) {
        self._isPlaying = isPlaying
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}
