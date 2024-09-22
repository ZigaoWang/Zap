//
//  NotesViewModel.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVFoundation

class NotesViewModel: ObservableObject {
    @Published var notes: [NoteItem] = []
    @Published var isRecording = false
    private var audioRecorder: AVAudioRecorder?

    func addTextNote(_ text: String) {
        let newNote = NoteItem(id: UUID(), timestamp: Date(), type: .text(text))
        notes.append(newNote)
    }

    func addAudioNote(url: URL, duration: TimeInterval) {
        let newNote = NoteItem(id: UUID(), timestamp: Date(), type: .audio(url, duration))
        notes.append(newNote)
    }

    func addPhotoNote(url: URL) {
        let newNote = NoteItem(id: UUID(), timestamp: Date(), type: .photo(url))
        notes.append(newNote)
    }

    func addVideoNote(url: URL, duration: TimeInterval) {
        let newNote = NoteItem(id: UUID(), timestamp: Date(), type: .video(url, duration))
        notes.append(newNote)
    }

    func deleteNotes(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("\(Date().timeIntervalSince1970).m4a")

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true

        } catch {
            print("Could not start recording")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        if let url = audioRecorder?.url {
            let asset = AVAsset(url: url)
            let duration = asset.duration.seconds
            addAudioNote(url: url, duration: duration)
        }
        audioRecorder = nil
        isRecording = false
    }
}
