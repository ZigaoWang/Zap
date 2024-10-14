//
//  AIManager.swift
//  Zap
//
//  Created by Zigao Wang on 10/9/24.
//

import Foundation
import UIKit
import Vision
import os.log
import AVFoundation

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
    
    func summarizeNotes(_ notes: [NoteItem]) async throws -> String {
        var messages: [[String: Any]] = [
            ["role": "system", "content": "You are a helpful assistant that summarizes notes, including descriptions of images."]
        ]
        
        for (index, note) in notes.enumerated() {
            switch note.type {
            case .text(let content):
                messages.append(["role": "user", "content": content])
                print("Added text note \(index): \(content)")
            case .photo(let fileName):
                if let image = loadImage(fileName: fileName),
                   let description = try await analyzeImage(image) {
                    messages.append(["role": "user", "content": "Image description: \(description)"])
                    print("Added image note \(index): \(fileName) with description")
                } else {
                    print("Failed to process image note \(index): \(fileName)")
                }
            case .video(let fileName, _):
                messages.append(["role": "user", "content": "Video: \(fileName)"])
                print("Added video note \(index): \(fileName)")
            case .audio(_, _):
                if let transcription = note.transcription {
                    messages.append(["role": "user", "content": "Audio transcription: \(transcription)"])
                    print("Added audio note \(index) with transcription")
                } else {
                    print("Audio note \(index) has no transcription")
                }
            }
        }
        
        messages.append(["role": "user", "content": "Please summarize all the notes, including descriptions of images."])
        
        return try await sendSummarizationRequest(messages: messages)
    }
    
    private func analyzeImage(_ image: UIImage) async throws -> String? {
        guard let imageData = compressImage(image) else {
            print("Failed to compress image")
            return nil
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: apiBaseURL.appendingPathComponent("process-notes"))
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add text content
        let textContent = "Please analyze this image and provide a brief description."
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"text\"\r\n\r\n".data(using: .utf8)!)
        body.append(textContent.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"images\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add closing boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response type")
            return nil
        }
        
        print("HTTP Status Code: \(httpResponse.statusCode)")
        print("Response Headers: \(httpResponse.allHeaderFields)")
        
        if !(200...299).contains(httpResponse.statusCode) {
            print("HTTP request failed: \(response)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response body: \(responseString)")
            }
            return nil
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content
            } else {
                print("Failed to parse image analysis response")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw response: \(responseString)")
                }
                return nil
            }
        } catch {
            print("Error parsing JSON: \(error)")
            return nil
        }
    }
    
    private func sendSummarizationRequest(messages: [[String: Any]]) async throws -> String {
        var request = URLRequest(url: apiBaseURL.appendingPathComponent("chat"))
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "max_tokens": 500
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
            print("HTTP request failed: \(response)")
            throw NSError(domain: "AIManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "HTTP request failed"])
        }
        
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        } else {
            print("Failed to parse summarization response. Raw data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
            throw NSError(domain: "AIManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "Unable to parse summarization response"])
        }
    }
    
    private func loadImage(fileName: String) -> UIImage? {
        if let image = UIImage(named: fileName) {
            return image
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let imagePath = documentsDirectory?.appendingPathComponent(fileName),
           let image = UIImage(contentsOfFile: imagePath.path) {
            return image
        }
        
        print("Failed to load image: \(fileName)")
        return nil
    }
    
    func transcribeAudio(url: URL) async throws -> String {
        let audioData = try Data(contentsOf: url)
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: apiBaseURL.appendingPathComponent("transcribe"))
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add model field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)
        
        // Add file field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add closing boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
            print("HTTP request failed: \(response)")
            throw NSError(domain: "AIManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        }
        
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let transcription = json["text"] as? String {
            return transcription
        } else {
            print("Failed to parse transcription response. Raw data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
            throw NSError(domain: "AIManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse transcription response"])
        }
    }
}

private func compressImage(_ image: UIImage, maxSizeKB: Int = 1000) -> Data? {
    var compression: CGFloat = 1.0
    let maxCompression: CGFloat = 0.1
    var imageData = image.jpegData(compressionQuality: compression)
    
    while (imageData?.count ?? 0) > maxSizeKB * 1024 && compression > maxCompression {
        compression -= 0.1
        imageData = image.jpegData(compressionQuality: compression)
    }
    
    return imageData
}
