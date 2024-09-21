//
//  VideoPlayerView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let url: URL
    @Binding var isPresented: Bool

    var player: AVPlayer {
        AVPlayer(url: url)
    }

    var body: some View {
        NavigationView {
            VideoPlayer(player: player)
                .onAppear {
                    player.play()
                }
                .onDisappear {
                    player.pause()
                }
                .navigationBarItems(trailing: Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                })
                .background(Color.black)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(url: Bundle.main.url(forResource: "sample", withExtension: "mp4")!, isPresented: .constant(true))
    }
}
