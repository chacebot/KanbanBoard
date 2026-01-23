//
//  Board.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import Foundation

struct BoardShare: Codable, Equatable {
    let userId: String
    let userName: String
    let accessLevel: ShareAccessLevel
    let sharedAt: Date
    
    enum ShareAccessLevel: String, Codable {
        case view = "view"
        case edit = "edit"
    }
}

struct Board: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var columns: [Column]
    var completedCards: [Card]
    var createdAt: Date
    var updatedAt: Date
    var sharedWith: [BoardShare]
    var ownerId: String
    
    init(id: UUID = UUID(), name: String, columns: [Column] = [], completedCards: [Card] = [], createdAt: Date = Date(), updatedAt: Date = Date(), sharedWith: [BoardShare] = [], ownerId: String = "") {
        self.id = id
        self.name = name
        self.columns = columns
        self.completedCards = completedCards
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sharedWith = sharedWith
        self.ownerId = ownerId
    }
    
    static let defaultBoard = Board(name: "My Board", columns: [
        Column(title: "To Do"),
        Column(title: "In Progress")
    ])
    
    // Custom decoder to handle migration from old format
    enum CodingKeys: String, CodingKey {
        case id, name, columns, completedCards, createdAt, updatedAt, sharedWith, ownerId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode new format fields, use defaults if not present (old format)
        id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        name = (try? container.decode(String.self, forKey: .name)) ?? "My Board"
        columns = try container.decode([Column].self, forKey: .columns)
        completedCards = try container.decode([Card].self, forKey: .completedCards)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        sharedWith = (try? container.decode([BoardShare].self, forKey: .sharedWith)) ?? []
        ownerId = (try? container.decode(String.self, forKey: .ownerId)) ?? ""
    }
}
