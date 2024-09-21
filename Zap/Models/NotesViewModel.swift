//
//  NotesViewModel.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import Foundation
import Combine

// 定义笔记类型
enum NoteType: Codable {
    case text(String)
    case audio(URL, Double)    // URL 和持续时间
    case photo(URL)           // 图片的文件 URL
    case video(URL, Double)    // 视频 URL 和持续时间
    
    // 编码和解码支持
    enum CodingKeys: String, CodingKey {
        case type
        case content
    }

    enum NoteTypeIdentifier: String, Codable {
        case text
        case audio
        case photo
        case video
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode(NoteTypeIdentifier.text, forKey: .type)
            try container.encode(text, forKey: .content)
        case .audio(let url, let duration):
            try container.encode(NoteTypeIdentifier.audio, forKey: .type)
            try container.encode([url.absoluteString, String(duration)], forKey: .content)
        case .photo(let url):
            try container.encode(NoteTypeIdentifier.photo, forKey: .type)
            try container.encode(url.absoluteString, forKey: .content)
        case .video(let url, let duration):
            try container.encode(NoteTypeIdentifier.video, forKey: .type)
            try container.encode([url.absoluteString, String(duration)], forKey: .content)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeIdentifier = try container.decode(NoteTypeIdentifier.self, forKey: .type)
        switch typeIdentifier {
        case .text:
            let text = try container.decode(String.self, forKey: .content)
            self = .text(text)
        case .audio:
            let data = try container.decode([String].self, forKey: .content)
            if data.count == 2, let url = URL(string: data[0]), let duration = Double(data[1]) {
                self = .audio(url, duration)
            } else {
                throw DecodingError.dataCorruptedError(forKey: .content, in: container, debugDescription: "Invalid audio data")
            }
        case .photo:
            let urlString = try container.decode(String.self, forKey: .content)
            if let url = URL(string: urlString) {
                self = .photo(url)
            } else {
                throw DecodingError.dataCorruptedError(forKey: .content, in: container, debugDescription: "Invalid photo URL")
            }
        case .video:
            let data = try container.decode([String].self, forKey: .content)
            if data.count == 2, let url = URL(string: data[0]), let duration = Double(data[1]) {
                self = .video(url, duration)
            } else {
                throw DecodingError.dataCorruptedError(forKey: .content, in: container, debugDescription: "Invalid video data")
            }
        }
    }
}

// 定义笔记项
struct NoteItem: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let type: NoteType
}

// ViewModel 管理所有笔记
class NotesViewModel: ObservableObject {
    @Published var notes: [NoteItem] = []
    
    private let notesKey = "notes"
    
    init() {
        loadNotes()
    }
    
    // 加载笔记
    func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: notesKey) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let decoded = try? decoder.decode([NoteItem].self, from: data) {
                notes = decoded.sorted { $0.timestamp > $1.timestamp }
                return
            }
        }
        notes = []
    }
    
    // 保存笔记
    func saveNotes() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(notes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
    }
    
    // 添加文字笔记
    func addTextNote(_ text: String) {
        let newNote = NoteItem(id: UUID(), timestamp: Date(), type: .text(text))
        notes.insert(newNote, at: 0)
        saveNotes()
    }
    
    // 添加音频笔记
    func addAudioNote(url: URL, duration: Double) {
        let newNote = NoteItem(id: UUID(), timestamp: Date(), type: .audio(url, duration))
        notes.insert(newNote, at: 0)
        saveNotes()
    }
    
    // 添加照片笔记
    func addPhotoNote(url: URL) {
        let newNote = NoteItem(id: UUID(), timestamp: Date(), type: .photo(url))
        notes.insert(newNote, at: 0)
        saveNotes()
    }
    
    // 添加视频笔记
    func addVideoNote(url: URL, duration: Double) {
        let newNote = NoteItem(id: UUID(), timestamp: Date(), type: .video(url, duration))
        notes.insert(newNote, at: 0)
        saveNotes()
    }
    
    // 删除笔记
    func deleteNote(at offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            switch note.type {
            case .photo(let url), .audio(let url, _), .video(let url, _):
                try? FileManager.default.removeItem(at: url)
            case .text:
                break
            }
        }
        notes.remove(atOffsets: offsets)
        saveNotes()
    }
}
