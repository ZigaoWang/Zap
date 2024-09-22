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
}

enum NoteType: Codable {
    case text(String)
    case audio(URL, TimeInterval)
    case photo(URL)
    case video(URL, TimeInterval)

    private enum CodingKeys: String, CodingKey {
        case type, content, url, duration
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
            let url = try container.decode(URL.self, forKey: .url)
            let duration = try container.decode(TimeInterval.self, forKey: .duration)
            self = .audio(url, duration)
        case .photo:
            let url = try container.decode(URL.self, forKey: .url)
            self = .photo(url)
        case .video:
            let url = try container.decode(URL.self, forKey: .url)
            let duration = try container.decode(TimeInterval.self, forKey: .duration)
            self = .video(url, duration)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let content):
            try container.encode(NoteTypeCoding.text, forKey: .type)
            try container.encode(content, forKey: .content)
        case .audio(let url, let duration):
            try container.encode(NoteTypeCoding.audio, forKey: .type)
            try container.encode(url, forKey: .url)
            try container.encode(duration, forKey: .duration)
        case .photo(let url):
            try container.encode(NoteTypeCoding.photo, forKey: .type)
            try container.encode(url, forKey: .url)
        case .video(let url, let duration):
            try container.encode(NoteTypeCoding.video, forKey: .type)
            try container.encode(url, forKey: .url)
            try container.encode(duration, forKey: .duration)
        }
    }
}
