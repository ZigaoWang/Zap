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
        transcribeAudioNote(newNote)
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
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        
        if let recorder = audioRecorder {
            let duration = recorder.currentTime
            let fileName = recorder.url.lastPathComponent
            addAudioNote(fileName: fileName, duration: duration)
        }
        
        audioRecorder = nil
    }
    
    // MARK: - Transcription
    
    private func transcribeAudioNote(_ note: NoteItem) {
        guard case .audio(let fileName, _) = note.type else { return }
        
        let audioURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        // Try transcription with each supported locale
        for locale in supportedLocales {
            if let speechRecognizer = SFSpeechRecognizer(locale: locale) {
                let request = SFSpeechURLRecognitionRequest(url: audioURL)
                request.shouldReportPartialResults = false
                
                speechRecognizer.recognitionTask(with: request) { [weak self] (result, error) in
                    guard let result = result, error == nil else {
                        print("Transcription failed for locale \(locale.identifier): \(error?.localizedDescription ?? "No error description")")
                        return
                    }
                    
                    let transcription = result.bestTranscription.formattedString
                    if !transcription.isEmpty {
                        self?.updateTranscription(for: note, with: transcription)
                        return // Stop trying other locales if we get a non-empty transcription
                    }
                }
            }
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
    
    @Published var summary: String = ""
        @Published var isSummarizing = false

    func summarizeNotes() {
            isSummarizing = true
            Task {
                do {
                    let summarizedText = try await AIManager.shared.summarizeNotes(notes)
                    DispatchQueue.main.async {
                        self.summary = summarizedText
                        self.isSummarizing = false
                    }
                } catch {
                    print("Error summarizing notes: \(error)")
                    DispatchQueue.main.async {
                        self.summary = "Error summarizing notes. Please try again."
                        self.isSummarizing = false
                    }
                }
            }
        }
}
