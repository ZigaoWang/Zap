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
            } catch {
                print("无法加载音频文件: \(error.localizedDescription)")
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

// 重命名后的代理类，避免与系统协议冲突
class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    @Binding var isPlaying: Bool
    var stopTimer: () -> Void

    init(isPlaying: Binding<Bool>, stopTimer: @escaping () -> Void) {
        self._isPlaying = isPlaying
        self.stopTimer = stopTimer
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        stopTimer()
    }
}

struct AudioPlayerInlineView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerInlineView(url: Bundle.main.url(forResource: "sample", withExtension: "m4a")!)
            .environmentObject(NotesViewModel())
    }
}
