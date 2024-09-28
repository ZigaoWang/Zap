//
//  NotesViewModel.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVFoundation

class NotesViewModel: ObservableObject {
    @Published var notes: [NoteItem] = [] {
        didSet {
            saveNotes()
        }
    }
    @Published var isRecording = false
    private var audioRecorder: AVAudioRecorder?
    private let notesFileName = "notes.json"

    init() {
        loadNotes()
    }

    private func addNote(_ note: NoteItem) {
        notes.insert(note, at: 0)
    }

    func addTextNote(_ text: String) {
        let newNote = NoteItem(id: UUID(), timestamp: Date(), type: .text(text))
        addNote(newNote)
    }

    func addAudioNote(fileName: String, duration: TimeInterval) {
        let newNote = NoteItem(id: UUID(), timestamp: Date(), type: .audio(fileName, duration))
        addNote(newNote)
    }

    func addPhotoNote(fileName: String) {
        let newNote = NoteItem(id: UUID(), timestamp: Date(), type: .photo(fileName))
        addNote(newNote)
    }

    func addVideoNote(fileName: String, duration: TimeInterval) {
        let newNote = NoteItem(id: UUID(), timestamp: Date(), type: .video(fileName, duration))
        addNote(newNote)
    }

    func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            switch note.type {
            case .audio(let fileName, _), .photo(let fileName), .video(let fileName, _):
                let url = getDocumentsDirectory().appendingPathComponent(fileName)
                try? FileManager.default.removeItem(at: url)
            default:
                break
            }
        }
        notes.remove(atOffsets: offsets)
    }

    private func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            let url = getDocumentsDirectory().appendingPathComponent(notesFileName)
            try data.write(to: url)
        } catch {
            print("Failed to save notes: \(error)")
        }
    }

    private func loadNotes() {
        let url = getDocumentsDirectory().appendingPathComponent(notesFileName)
        do {
            let data = try Data(contentsOf: url)
            notes = try JSONDecoder().decode([NoteItem].self, from: data)
        } catch {
            print("Failed to load notes: \(error)")
            notes = []
        }
    }

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let fileName = "\(UUID().uuidString).m4a"
            let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName)

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
            print("Could not start recording: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        if let url = audioRecorder?.url {
            let duration = AVAsset(url: url).duration.seconds
            let fileName = url.lastPathComponent
            addAudioNote(fileName: fileName, duration: duration)
        }
        audioRecorder = nil
        isRecording = false
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
