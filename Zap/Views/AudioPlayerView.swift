//
//  AudioPlayerView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    let url: URL
    let duration: TimeInterval

    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var player: AVAudioPlayer?
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                HStack {
                    Button(action: togglePlayPause) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title)
                    }

                    Slider(value: $progress, in: 0...duration) { editing in
                        if !editing {
                            player?.currentTime = progress
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear(perform: setupPlayer)
        .onDisappear {
            player?.stop()
        }
    }

    func setupPlayer() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()

            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if let player = player {
                    progress = player.currentTime
                    if !player.isPlaying {
                        isPlaying = false
                    }
                }
            }
        } catch {
            errorMessage = "Error setting up player: \(error.localizedDescription)"
            print("Error setting up player: \(error)")
        }
    }

    func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
}
