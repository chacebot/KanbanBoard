//
//  Column.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import Foundation

struct Column: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var cards: [Card]
    var createdAt: Date
    
    init(id: UUID = UUID(), title: String, cards: [Card] = [], createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.cards = cards
        self.createdAt = createdAt
    }
}
