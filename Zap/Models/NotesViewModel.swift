//
//  NotesViewModel.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVFoundation
import Speech
import NaturalLanguage

class NotesViewModel: ObservableObject {
    @Published var notes: [NoteItem] = []
    @Published var isRecording = false
    @Published var isSummarizing = false
    @Published var summary: String = ""
    @Published var errorMessage: String? = nil
    
    private var audioRecorder: AVAudioRecorder?
    private let supportedLocales: [Locale] = [
        Locale(identifier: "en-US"),
        Locale(identifier: "zh-Hans")
    ]
    
    init() {
        loadNotes()
    }
    
    // MARK: - Note Management
    
    func addTextNote(_ text: String) {
        let newNote = NoteItem(type: .text(text))
        notes.insert(newNote, at: 0)
        saveNotes()
    }
    
    func addAudioNote(fileName: String, duration: TimeInterval) {
        let newNote = NoteItem(type: .audio(fileName, duration))
        notes.insert(newNote, at: 0)
        saveNotes()
        
        // Start transcription asynchronously
        Task {
            await transcribeAudioNote(newNote)
        }
    }
    
    func addPhotoNote(fileName: String) {
        let newNote = NoteItem(type: .photo(fileName))
        notes.insert(newNote, at: 0)
        saveNotes()
    }
    
    func addVideoNote(fileName: String, duration: TimeInterval) {
        let newNote = NoteItem(type: .video(fileName, duration))
        notes.insert(newNote, at: 0)
        saveNotes()
    }
    
    func toggleNoteCompletion(_ note: NoteItem) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isCompleted.toggle()
            saveNotes()
        }
    }
    
    func deleteNotes(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        saveNotes()
    }
    
    func updateTranscription(for note: NoteItem, with transcription: String) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].transcription = transcription
            saveNotes()
        }
    }
    
    // MARK: - Audio Recording
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            
            DispatchQueue.main.async {
                self.isRecording = true
            }
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        
        DispatchQueue.main.async {
            self.isRecording = false
            if let recorder = self.audioRecorder {
                let audioFilename = recorder.url.lastPathComponent
                let duration = recorder.currentTime
                self.addAudioNote(fileName: audioFilename, duration: duration)
            }
            self.audioRecorder = nil
        }
    }
    
    // MARK: - Transcription
    
    func transcribeAudioNote(_ note: NoteItem) async {
        guard case .audio(let fileName, _) = note.type else { return }
        
        do {
            let audioFileURL = getDocumentsDirectory().appendingPathComponent(fileName)
            let transcription = try await AIManager.shared.transcribeAudio(url: audioFileURL)
            await MainActor.run {
                if let index = notes.firstIndex(where: { $0.id == note.id }) {
                    notes[index].transcription = transcription
                    saveNotes()
                }
            }
        } catch {
            print("Error transcribing audio: \(error)")
        }
    }
    
    // MARK: - Language Detection
    
    func detectLanguage(for text: String) -> String {
        let languageRecognizer = NLLanguageRecognizer()
        languageRecognizer.processString(text)
        guard let dominantLanguage = languageRecognizer.dominantLanguage else {
            return "Unknown"
        }
        switch dominantLanguage {
        case .english:
            return "English"
        case .simplifiedChinese, .traditionalChinese:
            return "Chinese"
        default:
            return "Other"
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            try data.write(to: getDocumentsDirectory().appendingPathComponent("notes.json"))
        } catch {
            print("Unable to save notes: \(error)")
        }
    }
    
    private func loadNotes() {
        let url = getDocumentsDirectory().appendingPathComponent("notes.json")
        
        guard let data = try? Data(contentsOf: url) else { return }
        
        do {
            notes = try JSONDecoder().decode([NoteItem].self, from: data)
        } catch {
            print("Unable to load notes: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func editTextNote(_ note: NoteItem, newText: String) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].type = .text(newText)
            saveNotes()
        }
    }

    func editAudioTranscription(_ note: NoteItem, newTranscription: String) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].transcription = newTranscription
            saveNotes()
        }
    }
    
    // MARK: - AI Summarize
    
    func summarizeNotes() {
        Task {
            do {
                self.isSummarizing = true
                self.errorMessage = nil
                let newSummary = try await AIManager.shared.summarizeNotes(notes)
                await MainActor.run {
                    self.summary = newSummary
                    self.isSummarizing = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to generate summary: \(error.localizedDescription)"
                    self.isSummarizing = false
                }
            }
        }
    }
    
    // Add this function to the NotesViewModel class
    func deleteNote(_ note: NoteItem) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
}
