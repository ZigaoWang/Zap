//
//  NoteItem.swift
//  Zap
//
//  Created by Zigao Wang on 9/22/24.
//

import Foundation

struct NoteItem: Identifiable, Codable, Equatable {
    let id: UUID
    let timestamp: Date
    let type: NoteType
    var isCompleted: Bool
    var transcription: String?
    
    init(id: UUID = UUID(), timestamp: Date = Date(), type: NoteType, isCompleted: Bool = false, transcription: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.isCompleted = isCompleted
        self.transcription = transcription
    }
    
    static func == (lhs: NoteItem, rhs: NoteItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.timestamp == rhs.timestamp &&
        lhs.type == rhs.type &&
        lhs.isCompleted == rhs.isCompleted &&
        lhs.transcription == rhs.transcription
    }
}

enum NoteType: Codable, Equatable {
    case text(String)
    case audio(String, TimeInterval)
    case photo(String)
    case video(String, TimeInterval)
}
