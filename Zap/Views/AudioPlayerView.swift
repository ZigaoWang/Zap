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
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if isPlaying {
                        player?.pause()
                    } else {
                        player?.play()
                    }
                    isPlaying.toggle()
                }) {
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
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.stop()
        }
    }
    
    private func setupPlayer() {
        do {
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
            print("Error setting up player: \(error.localizedDescription)")
        }
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView(url: URL(fileURLWithPath: ""), duration: 60)
    }
}
