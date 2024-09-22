//
//  NoteItem.swift
//  Zap
//
//  Created by Zigao Wang on 9/22/24.
//

import Foundation

struct NoteItem: Identifiable {
    let id: UUID
    let timestamp: Date
    let type: NoteType
}

enum NoteType {
    case text(String)
    case audio(URL, TimeInterval)
    case photo(URL)
    case video(URL, TimeInterval)
}
