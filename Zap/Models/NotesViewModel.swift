//
//  NotesViewModel.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI
import AVFoundation
import Speech

class NotesViewModel: ObservableObject {
    @Published var notes: [NoteItem] = []
    @Published var isRecording = false
    
    private var audioRecorder: AVAudioRecorder?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    init() {
        loadNotes()
    }
    
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
    
    private func transcribeAudioNote(_ note: NoteItem) {
        guard case .audio(let fileName, _) = note.type else { return }
        
        let audioURL = getDocumentsDirectory().appendingPathComponent(fileName)
        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        
        speechRecognizer?.recognitionTask(with: request) { [weak self] (result, error) in
            guard let result = result else {
                print("Transcription failed: \(error?.localizedDescription ?? "No error description")")
                return
            }
            
            let transcription = result.bestTranscription.formattedString
            self?.updateTranscription(for: note, with: transcription)
        }
    }
    
    func updateTextNote(_ note: NoteItem, with newText: String) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = NoteItem(id: note.id, timestamp: note.timestamp, type: .text(newText), isCompleted: note.isCompleted, transcription: note.transcription)
            saveNotes()
        }
    }
    
    func updateAudioNoteTranscription(_ note: NoteItem, with newTranscription: String) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].transcription = newTranscription
            saveNotes()
        }
    }
    
    func updatePhotoNote(_ note: NoteItem, fileName: String, annotations: [Drawing]) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            if let image = UIImage(contentsOfFile: url.path) {
                UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
                image.draw(at: .zero)
                
                for drawing in annotations {
                    let path = UIBezierPath()
                    if let firstPoint = drawing.points.first {
                        path.move(to: firstPoint)
                        for point in drawing.points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    
                    UIColor(drawing.color).setStroke()
                    path.lineWidth = drawing.lineWidth
                    path.stroke()
                }
                
                if let annotatedImage = UIGraphicsGetImageFromCurrentImageContext() {
                    UIGraphicsEndImageContext()
                    
                    if let data = annotatedImage.jpegData(compressionQuality: 0.8) {
                        do {
                            try data.write(to: url)
                            notes[index] = NoteItem(id: note.id, timestamp: note.timestamp, type: .photo(fileName), isCompleted: note.isCompleted, transcription: note.transcription)
                            objectWillChange.send()
                        } catch {
                            print("Failed to save annotated image: \(error)")
                        }
                    }
                }
            }
        }
    }
    
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
    
    func updatePhotoNote(_ note: NoteItem, fileName: String) {
            if let index = notes.firstIndex(where: { $0.id == note.id }) {
                notes[index] = NoteItem(id: note.id, timestamp: Date(), type: .photo(fileName), isCompleted: note.isCompleted, transcription: note.transcription)
                saveNotes()
            }
        }
        
        func getDocumentsDirectory() -> URL {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }
        
        func getFilePath(_ fileName: String) -> String {
            getDocumentsDirectory().appendingPathComponent(fileName).path
        }
}
