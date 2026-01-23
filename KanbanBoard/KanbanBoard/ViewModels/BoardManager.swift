//
//  BoardManager.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import Foundation
import Combine
import UIKit

class BoardManager: ObservableObject {
    @Published var workspace: Workspace {
        didSet {
            saveWorkspace()
        }
    }
    
    var board: Board {
        get {
            if let currentId = workspace.currentBoardId,
               let currentBoard = workspace.boards.first(where: { $0.id == currentId }) {
                return currentBoard
            }
            // Fallback to first board or create default
            if let firstBoard = workspace.boards.first {
                workspace.currentBoardId = firstBoard.id
                return firstBoard
            }
            // Create default board if none exist
            let defaultBoard = Board.defaultBoard
            workspace.boards.append(defaultBoard)
            workspace.currentBoardId = defaultBoard.id
            return defaultBoard
        }
        set {
            if let index = workspace.boards.firstIndex(where: { $0.id == newValue.id }) {
                workspace.boards[index] = newValue
            }
        }
    }
    
    private let persistenceKey = "kanban_workspace_data"
    private let legacyPersistenceKey = "kanban_board_data"
    
    init() {
        // Try to load workspace
        if let savedWorkspace = Self.loadWorkspace() {
            self.workspace = savedWorkspace
            // Ensure current board is valid
            if workspace.currentBoardId == nil || !workspace.boards.contains(where: { $0.id == workspace.currentBoardId }) {
                workspace.currentBoardId = workspace.boards.first?.id
            }
        } else if let legacyBoard = Self.loadLegacyBoard() {
            // Migrate from old single-board format
            // Old boards won't have id or name, so create a new board with those fields
            let migratedBoard = Board(
                id: UUID(),
                name: legacyBoard.name.isEmpty ? "My Board" : legacyBoard.name,
                columns: legacyBoard.columns,
                completedCards: legacyBoard.completedCards,
                createdAt: legacyBoard.createdAt,
                updatedAt: legacyBoard.updatedAt,
                ownerId: UIDevice.current.identifierForVendor?.uuidString ?? ""
            )
            self.workspace = Workspace(boards: [migratedBoard], currentBoardId: migratedBoard.id, userId: UIDevice.current.identifierForVendor?.uuidString ?? "")
        } else {
            // Create default workspace
            let defaultBoard = Board.defaultBoard
            self.workspace = Workspace(boards: [defaultBoard], currentBoardId: defaultBoard.id, userId: UIDevice.current.identifierForVendor?.uuidString ?? "")
        }
    }
    
    // MARK: - Board Management
    
    func switchToBoard(_ boardId: UUID) {
        if workspace.boards.contains(where: { $0.id == boardId }) {
            workspace.currentBoardId = boardId
        }
    }
    
    func createBoard(name: String) -> Board {
        let newBoard = Board(
            name: name.isEmpty ? "New Board" : name,
            columns: [
                Column(title: "To Do"),
                Column(title: "In Progress")
            ],
            ownerId: workspace.userId
        )
        workspace.boards.append(newBoard)
        workspace.currentBoardId = newBoard.id
        return newBoard
    }
    
    func renameBoard(_ boardId: UUID, newName: String) {
        guard let index = workspace.boards.firstIndex(where: { $0.id == boardId }) else {
            return
        }
        workspace.boards[index].name = newName
        workspace.boards[index].updatedAt = Date()
    }
    
    func deleteBoard(_ boardId: UUID) {
        // Don't allow deleting the last board
        guard workspace.boards.count > 1 else {
            return
        }
        
        workspace.boards.removeAll(where: { $0.id == boardId })
        
        // If we deleted the current board, switch to another
        if workspace.currentBoardId == boardId {
            workspace.currentBoardId = workspace.boards.first?.id
        }
    }
    
    func shareBoard(_ boardId: UUID, with userId: String, userName: String, accessLevel: BoardShare.ShareAccessLevel) {
        guard let index = workspace.boards.firstIndex(where: { $0.id == boardId }) else {
            return
        }
        
        let share = BoardShare(userId: userId, userName: userName, accessLevel: accessLevel, sharedAt: Date())
        
        // Remove existing share for this user if any
        workspace.boards[index].sharedWith.removeAll(where: { $0.userId == userId })
        workspace.boards[index].sharedWith.append(share)
        workspace.boards[index].updatedAt = Date()
    }
    
    func removeShare(_ boardId: UUID, userId: String) {
        guard let index = workspace.boards.firstIndex(where: { $0.id == boardId }) else {
            return
        }
        
        workspace.boards[index].sharedWith.removeAll(where: { $0.userId == userId })
        workspace.boards[index].updatedAt = Date()
    }
    
    // MARK: - Card Management
    
    func addCard(to columnId: UUID, title: String, description: String = "", photoFileNames: [String] = [], cardId: UUID = UUID()) {
        guard let columnIndex = board.columns.firstIndex(where: { $0.id == columnId }) else {
            return
        }
        
        var newCard = Card(id: cardId, title: title, description: description, photoFileNames: photoFileNames)
        let columnTitle = board.columns[columnIndex].title
        newCard.addHistoryEntry("Card created in \(columnTitle)")
        board.columns[columnIndex].cards.append(newCard)
        board.updatedAt = Date()
    }
    
    func deleteCard(_ cardId: UUID, from columnId: UUID) {
        guard let columnIndex = board.columns.firstIndex(where: { $0.id == columnId }),
              let cardIndex = board.columns[columnIndex].cards.firstIndex(where: { $0.id == cardId }) else {
            return
        }
        
        // Delete associated photos if they exist
        let card = board.columns[columnIndex].cards[cardIndex]
        ImageStorage.shared.deleteImages(fileNames: card.photoFileNames)
        
        board.columns[columnIndex].cards.remove(at: cardIndex)
        board.updatedAt = Date()
    }
    
    func updateCard(_ card: Card, in columnId: UUID) {
        guard let columnIndex = board.columns.firstIndex(where: { $0.id == columnId }),
              let cardIndex = board.columns[columnIndex].cards.firstIndex(where: { $0.id == card.id }) else {
            return
        }
        
        let oldCard = board.columns[columnIndex].cards[cardIndex]
        var updatedCard = card
        updatedCard.updatedAt = Date()
        
        // Track changes
        var changes: [String] = []
        if oldCard.title != updatedCard.title {
            changes.append("Title changed")
        }
        if oldCard.description != updatedCard.description {
            changes.append("Description changed")
        }
        if oldCard.photoFileNames.count != updatedCard.photoFileNames.count {
            if updatedCard.photoFileNames.count > oldCard.photoFileNames.count {
                changes.append("Photos added")
            } else {
                changes.append("Photos removed")
            }
        }
        
        if !changes.isEmpty {
            updatedCard.addHistoryEntry(changes.joined(separator: ", "))
        } else {
            // Preserve existing history
            updatedCard.history = oldCard.history
        }
        
        board.columns[columnIndex].cards[cardIndex] = updatedCard
        board.updatedAt = Date()
    }
    
    // MARK: - Drag and Drop
    
    func moveCard(_ cardId: UUID, from sourceColumnId: UUID, to destinationColumnId: UUID, at index: Int) {
        guard let sourceColumnIndex = board.columns.firstIndex(where: { $0.id == sourceColumnId }),
              let destinationColumnIndex = board.columns.firstIndex(where: { $0.id == destinationColumnId }),
              let cardIndex = board.columns[sourceColumnIndex].cards.firstIndex(where: { $0.id == cardId }) else {
            return
        }
        
        var card = board.columns[sourceColumnIndex].cards.remove(at: cardIndex)
        let sourceColumnTitle = board.columns[sourceColumnIndex].title
        let destinationColumnTitle = board.columns[destinationColumnIndex].title
        
        if sourceColumnTitle != destinationColumnTitle {
            card.addHistoryEntry("Moved from \(sourceColumnTitle) to \(destinationColumnTitle)")
            card.updatedAt = Date()
        }
        
        let insertIndex = min(index, board.columns[destinationColumnIndex].cards.count)
        board.columns[destinationColumnIndex].cards.insert(card, at: insertIndex)
        board.updatedAt = Date()
    }
    
    // MARK: - Completion Management
    
    func markCardAsDone(_ cardId: UUID, from columnId: UUID) {
        guard let columnIndex = board.columns.firstIndex(where: { $0.id == columnId }),
              let cardIndex = board.columns[columnIndex].cards.firstIndex(where: { $0.id == cardId }) else {
            return
        }
        
        var card = board.columns[columnIndex].cards.remove(at: cardIndex)
        card.addHistoryEntry("Marked as done")
        card.updatedAt = Date()
        board.completedCards.append(card)
        board.updatedAt = Date()
    }
    
    func getToDoColumnId() -> UUID? {
        return board.columns.first(where: { $0.title == "To Do" })?.id
    }
    
    // MARK: - Persistence
    
    private func saveWorkspace() {
        if let encoded = try? JSONEncoder().encode(workspace) {
            UserDefaults.standard.set(encoded, forKey: persistenceKey)
        }
    }
    
    private static func loadWorkspace() -> Workspace? {
        guard let data = UserDefaults.standard.data(forKey: "kanban_workspace_data"),
              let workspace = try? JSONDecoder().decode(Workspace.self, from: data) else {
            return nil
        }
        return workspace
    }
    
    private static func loadLegacyBoard() -> Board? {
        guard let data = UserDefaults.standard.data(forKey: "kanban_board_data"),
              let board = try? JSONDecoder().decode(Board.self, from: data) else {
            return nil
        }
        return board
    }
}
