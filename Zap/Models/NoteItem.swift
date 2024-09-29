//
//  NoteItem.swift
//  Zap
//
//  Created by Zigao Wang on 9/22/24.
//

import Foundation

struct NoteItem: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let type: NoteType
    var isCompleted: Bool

    init(id: UUID = UUID(), timestamp: Date = Date(), type: NoteType, isCompleted: Bool = false) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.isCompleted = isCompleted
    }
}

enum NoteType: Codable {
    case text(String)
    case audio(String, TimeInterval)
    case photo(String)
    case video(String, TimeInterval)

    private enum CodingKeys: String, CodingKey {
        case type, content, fileName, duration
    }

    enum NoteTypeCoding: String, Codable {
        case text, audio, photo, video
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(NoteTypeCoding.self, forKey: .type)
        switch type {
        case .text:
            let content = try container.decode(String.self, forKey: .content)
            self = .text(content)
        case .audio:
            let fileName = try container.decode(String.self, forKey: .fileName)
            let duration = try container.decode(TimeInterval.self, forKey: .duration)
            self = .audio(fileName, duration)
        case .photo:
            let fileName = try container.decode(String.self, forKey: .fileName)
            self = .photo(fileName)
        case .video:
            let fileName = try container.decode(String.self, forKey: .fileName)
            let duration = try container.decode(TimeInterval.self, forKey: .duration)
            self = .video(fileName, duration)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let content):
            try container.encode(NoteTypeCoding.text, forKey: .type)
            try container.encode(content, forKey: .content)
        case .audio(let fileName, let duration):
            try container.encode(NoteTypeCoding.audio, forKey: .type)
            try container.encode(fileName, forKey: .fileName)
            try container.encode(duration, forKey: .duration)
        case .photo(let fileName):
            try container.encode(NoteTypeCoding.photo, forKey: .type)
            try container.encode(fileName, forKey: .fileName)
        case .video(let fileName, let duration):
            try container.encode(NoteTypeCoding.video, forKey: .type)
            try container.encode(fileName, forKey: .fileName)
            try container.encode(duration, forKey: .duration)
        }
    }
}
