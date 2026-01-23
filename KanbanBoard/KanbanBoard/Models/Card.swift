//
//  Card.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import Foundation

struct CardHistoryEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let description: String
    let timestamp: Date
    
    init(id: UUID = UUID(), description: String, timestamp: Date = Date()) {
        self.id = id
        self.description = description
        self.timestamp = timestamp
    }
}

struct Card: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var photoFileNames: [String]
    var createdAt: Date
    var updatedAt: Date
    var history: [CardHistoryEntry]
    
    init(id: UUID = UUID(), title: String, description: String = "", photoFileNames: [String] = [], createdAt: Date = Date(), updatedAt: Date = Date(), history: [CardHistoryEntry] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.photoFileNames = photoFileNames
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.history = history
    }
    
    // Legacy support: migrate from old photoFileName to photoFileNames
    private enum CodingKeys: String, CodingKey {
        case id, title, description, photoFileName, photoFileNames, createdAt, updatedAt, history
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        // Try to decode new format first, fall back to old format
        if let fileNames = try? container.decode([String].self, forKey: .photoFileNames) {
            photoFileNames = fileNames
        } else {
            // Try to decode old single photo format
            let optionalFileName = try? container.decodeIfPresent(String.self, forKey: .photoFileName)
            if let fileName = optionalFileName {
                photoFileNames = [fileName]
            } else {
                photoFileNames = []
            }
        }
        
        // Decode history, default to empty array if not present
        if let historyEntries = try? container.decode([CardHistoryEntry].self, forKey: .history) {
            history = historyEntries
        } else {
            history = []
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(photoFileNames, forKey: .photoFileNames)
        try container.encode(history, forKey: .history)
    }
    
    mutating func addHistoryEntry(_ description: String) {
        let entry = CardHistoryEntry(description: description)
        history.append(entry)
    }
}
