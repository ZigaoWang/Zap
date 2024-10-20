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
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var duration: Double = 0.01  // Set a non-zero minimum value
    
    let note: NoteItem
    
    var body: some View {
        VStack {
            HStack {
                Button(action: togglePlayPause) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                Slider(value: $progress, in: 0...max(duration, 0.01)) { editing in
                    if !editing {
                        player?.seek(to: CMTime(seconds: progress, preferredTimescale: 1000))
                    }
                }
                .accentColor(.white)
                
                Text(formatTime(progress))
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .onAppear(perform: setupPlayer)
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func setupPlayer() {
        guard case .audio(let fileName, _) = note.type else { return }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioUrl = documentsPath.appendingPathComponent(fileName)
        
        player = AVPlayer(url: audioUrl)
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 1000), queue: .main) { time in
            progress = time.seconds
        }
        
        if let duration = player?.currentItem?.duration, duration.seconds.isFinite {
            self.duration = max(duration.seconds, 0.01)
        }
    }
    
    private func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
