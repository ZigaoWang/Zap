//
//  AudioPlayerView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var playbackTime: Double = 0
    @State private var duration: Double = 0
    @State private var timer: Timer?
    @State private var isLoading = true

    let url: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isLoading {
                ProgressView("加载中...")
            } else {
                HStack {
                    Text(formatTime(playbackTime))
                    Slider(value: $playbackTime, in: 0...duration, onEditingChanged: { editing in
                        if !editing {
                            audioPlayer?.currentTime = playbackTime
                        }
                    })
                    Text(formatTime(duration))
                }

                Button(action: {
                    togglePlayPause()
                }) {
                    Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(isPlaying ? .red : .green)
                }
            }
        }
        .padding()
        .onAppear {
            setupAudioPlayer()
        }
        .onDisappear {
            stopTimer()
            audioPlayer?.stop()
        }
    }

    // 设置音频播放器
    func setupAudioPlayer() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // 配置音频会话
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)

                audioPlayer = try AVAudioPlayer(contentsOf: url)
                duration = audioPlayer?.duration ?? 0
                audioPlayer?.delegate = AudioPlayerDelegate(isPlaying: $isPlaying, stopTimer: stopTimer)
                audioPlayer?.prepareToPlay()

                DispatchQueue.main.async {
                    isLoading = false
                }
            } catch {
                print("无法加载音频文件: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }
    }

    // 切换播放/停止
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

    // 开始计时器
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

    // 停止计时器
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // 格式化时间显示
    func formatTime(_ time: Double) -> String {
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

