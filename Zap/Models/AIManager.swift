//
//  AIManager.swift
//  Zap
//
//  Created by Zigao Wang on 10/9/24.
//

import Foundation

class AIManager {
    static let shared = AIManager()
    private let apiKey: String
    private let apiBaseURL = URL(string: "https://api.zap.zigao.wang/api/openai")!
    
    private init() {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            fatalError("OpenAI API Key not set in environment variables")
        }
        self.apiKey = apiKey
    }
    
    func transcribeAudio(fileName: String) async throws -> String {
        let audioURL = getDocumentsDirectory().appendingPathComponent(fileName)
        let audioData = try Data(contentsOf: audioURL)
        
        var request = URLRequest(url: apiBaseURL.appendingPathComponent("transcribe"))
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/mpeg\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1".data(using: .utf8)!)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug: Print raw response and status code
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
        }
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw transcription response: \(jsonString)")
        }
        
        // Handle server errors
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let errorMessage = json["error"] as? String {
                throw NSError(domain: "AIManager", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            } else {
                throw NSError(domain: "AIManager", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error occurred"])
            }
        }
        
        // Try to decode the response
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let text = json["text"] as? String {
            return text
        } else {
            throw NSError(domain: "AIManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to parse transcription response"])
        }
    }
    
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
            case .audio(_, _):
                if let transcription = note.transcription {
                    textToSummarize += transcription + "\n\n"
                }
            }
        }
        
        var request = URLRequest(url: apiBaseURL.appendingPathComponent("chat"))
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that summarizes notes."],
                ["role": "user", "content": "Please summarize the following notes:\n\n\(textToSummarize)"]
            ],
            "max_tokens": 150
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug: Print raw response and status code
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
        }
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw summarization response: \(jsonString)")
        }
        
        // Handle server errors
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let errorMessage = json["error"] as? String {
                throw NSError(domain: "AIManager", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            } else {
                throw NSError(domain: "AIManager", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error occurred"])
            }
        }
        
        // Try to decode the response
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        } else {
            throw NSError(domain: "AIManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to parse summarization response"])
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
