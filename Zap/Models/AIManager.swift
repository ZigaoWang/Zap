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
    
    private let backendURL = URL(string: "https://api.zap.zigao.wang/api/openai")!
    
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
        
        // Explicitly define the type of the query dictionary
        let query: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that summarizes notes. Keep your response short, and respond in the language the user is using."],
                ["role": "user", "content": "Please summarize the following notes:\n\n\(textToSummarize)"]
            ]
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: query)
        
        var request = URLRequest(url: backendURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, _) = try await URLSession.shared.data(for: request)

        do {
            if let result = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = result["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content
            } else {
                return "Unable to summarize notes."
            }
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
            return "Error summarizing notes. Please try again."
        }
        
        // Decode the result as a dictionary and extract the content
        if let result = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = result["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        } else {
            return "Unable to summarize notes."
        }
    }
    
    private func transcribeAudio(fileName: String) async throws -> String {
        let audioURL = getDocumentsDirectory().appendingPathComponent(fileName)
        let audioData = try Data(contentsOf: audioURL)
        
        // Ensure the openAI instance is properly initialized
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            fatalError("OpenAI API Key not set in environment variables")
        }
        let openAI = OpenAI(apiToken: apiKey)
        
        let query = AudioTranscriptionQuery(file: audioData, fileType: .m4a, model: "whisper-1")
        let transcription = try await openAI.audioTranscriptions(query: query)
        return transcription.text
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
