//
//  Workspace.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import Foundation

struct Workspace: Codable {
    var boards: [Board]
    var currentBoardId: UUID?
    var userId: String
    
    init(boards: [Board] = [], currentBoardId: UUID? = nil, userId: String = "") {
        self.boards = boards
        self.currentBoardId = currentBoardId
        self.userId = userId
    }
}
