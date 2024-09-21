//
// HomeView.swift
// Zap
//
// Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVFoundation

struct HomeView: View {
@EnvironmentObject var viewModel: NotesViewModel
@State private var isRecording = false
@State private var audioRecorder: AVAudioRecorder?
@State private var audioFilename: URL?

@State private var showingImagePicker = false
@State private var imagePickerDestination: ImagePickerDestination = .photoVideo

var body: some View {
    NavigationView {
        VStack(spacing: 40) {
            // Zap Text! 按钮
            NavigationLink(destination: TextNoteView()) {
                HStack {
                    Image(systemName: "text.justify")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                    Text("Zap Text!")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 70)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .cornerRadius(20)
                .shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            // Zap Audio! 按钮
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }) {
                HStack {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                    Text(isRecording ? "停止录音" : "Zap Audio!")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 70)
                .background(
                    LinearGradient(gradient: Gradient(colors: [isRecording ? Color.red : Color.green, isRecording ? Color.orange : Color.yellow]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .cornerRadius(20)
                .shadow(color: (isRecording ? Color.orange : Color.yellow).opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            // Zap Photo/Video! 从图库选择按钮
            Button(action: {
                imagePickerDestination = .photoVideo
                showingImagePicker = true
            }) {
                HStack {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                    Text("从图库选择")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 70)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .cornerRadius(20)
                .shadow(color: Color.pink.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(destination: imagePickerDestination, viewModel: viewModel)
            }
            
            // 新增：Zap Photo! 拍摄照片按钮
            Button(action: {
                imagePickerDestination = .photo
                showingImagePicker = true
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                    Text("拍摄照片")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 70)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.green, Color.teal]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .cornerRadius(20)
                .shadow(color: Color.teal.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(destination: imagePickerDestination, viewModel: viewModel)
            }
            
            // 新增：Zap Video! 拍摄视频按钮
            Button(action: {
                imagePickerDestination = .video
                showingImagePicker = true
            }) {
                HStack {
                    Image(systemName: "video.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                    Text("拍摄视频")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 70)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.purple, Color.indigo]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .cornerRadius(20)
                .shadow(color: Color.indigo.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(destination: imagePickerDestination, viewModel: viewModel)
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationTitle("Zap")
    }
}

// 开始录音
func startRecording() {
    let audioSession = AVAudioSession.sharedInstance()
    do {
        try audioSession.setCategory(.record, mode: .default, options: [])
        try audioSession.setActive(true)
        
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask
        )[0]
        let filename = UUID().uuidString + ".m4a"
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        audioFilename = fileURL
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        audioRecorder?.record()
        
        isRecording = true
    } catch {
        print("录音失败: \(error.localizedDescription)")
        // 移除提示信息
    }
}

// 停止录音并保存
func stopRecording() {
    audioRecorder?.stop()
    isRecording = false
    if let url = audioFilename {
        // 获取持续时间
        let asset = AVURLAsset(url: url)
        let duration = CMTimeGetSeconds(asset.duration)
        viewModel.addAudioNote(url: url, duration: duration)
    }
    audioRecorder = nil
    audioFilename = nil
}
}

struct HomeView_Previews: PreviewProvider {
static var previews: some View {
HomeView()
.environmentObject(NotesViewModel())
}
}
