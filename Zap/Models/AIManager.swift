//
//  AIManager.swift
//  Zap
//
//  Created by Zigao Wang on 10/9/24.
//

import Foundation
import OpenAI

class AIManager {
    static let shared = AIManager()
    private init() {}
    
    private let openAI: OpenAI = {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            fatalError("OpenAI API Key not set in environment variables")
        }
        return OpenAI(apiToken: apiKey)
    }()
    
    func summarizeNotes(_ notes: [NoteItem]) async throws -> String {
        var textToSummarize = ""
        
        for note in notes {
            switch note.type {
            case .text(let content):
                textToSummarize += content + "\n\n"
            case .photo(let fileName):
                textToSummarize += "Image: \(fileName)\n\n"
            case .video(let fileName, _):
                textToSummarize += "Video: \(fileName)\n\n"
            case .audio(let fileName, _):
                if let transcription = note.transcription {
                    textToSummarize += transcription + "\n\n"
                } else {
                    let audioTranscription = try await transcribeAudio(fileName: fileName)
                    textToSummarize += audioTranscription + "\n\n"
                }
            }
        }
        
        let query = ChatQuery(messages: [
            .init(role: .system, content: "You are a helpful assistant that summarizes notes.")!,
            .init(role: .user, content: "Please summarize the following notes:\n\n\(textToSummarize)")!
        ], model: .gpt4_o_mini)
        
        let result = try await openAI.chats(query: query)
        
        if let firstChoice = result.choices.first,
           let content = firstChoice.message.content {
            return String(describing: content)
        } else {
            return "Unable to summarize notes."
        }
    }
    
    private func transcribeAudio(fileName: String) async throws -> String {
        let audioURL = getDocumentsDirectory().appendingPathComponent(fileName)
        let audioData = try Data(contentsOf: audioURL)
        
        let query = AudioTranscriptionQuery(file: audioData, fileType: .m4a, model: "whisper-1")
        let transcription = try await openAI.audioTranscriptions(query: query)
        return transcription.text
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
