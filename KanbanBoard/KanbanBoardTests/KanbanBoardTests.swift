//
//  KanbanBoardTests.swift
//  KanbanBoardTests
//
//  Created by Chace Medeiros on 1/23/26.
//

import Testing
import Foundation
@testable import KanbanBoard

// MARK: - Card Tests

struct CardTests {

    @Test func cardInitialization() {
        let card = Card(title: "Test Card", description: "Test Description")

        #expect(card.title == "Test Card")
        #expect(card.description == "Test Description")
        #expect(card.photoFileNames.isEmpty)
        #expect(card.history.isEmpty)
    }

    @Test func cardWithPhotos() {
        let card = Card(
            title: "Card with Photos",
            description: "Description",
            photoFileNames: ["photo1.jpg", "photo2.jpg"]
        )

        #expect(card.photoFileNames.count == 2)
        #expect(card.photoFileNames.contains("photo1.jpg"))
        #expect(card.photoFileNames.contains("photo2.jpg"))
    }

    @Test func cardHistoryEntry() {
        var card = Card(title: "Test", description: "")
        card.addHistoryEntry("Card created")

        #expect(card.history.count == 1)
        #expect(card.history.first?.description == "Card created")
    }

    @Test func cardMultipleHistoryEntries() {
        var card = Card(title: "Test", description: "")
        card.addHistoryEntry("Created")
        card.addHistoryEntry("Moved to In Progress")
        card.addHistoryEntry("Updated description")

        #expect(card.history.count == 3)
    }

    @Test func cardUpdatedAtChanges() {
        var card = Card(title: "Test", description: "")
        let originalDate = card.updatedAt

        // Small delay to ensure time difference
        card.updatedAt = Date()

        #expect(card.updatedAt >= originalDate)
    }

    @Test func cardEquality() {
        let id = UUID()
        let date = Date()
        let card1 = Card(id: id, title: "Test", description: "Desc", createdAt: date, updatedAt: date)
        let card2 = Card(id: id, title: "Test", description: "Desc", createdAt: date, updatedAt: date)

        #expect(card1 == card2)
    }

    @Test func cardCodable() throws {
        let card = Card(
            title: "Codable Test",
            description: "Testing encoding/decoding",
            photoFileNames: ["test.jpg"]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(card)

        let decoder = JSONDecoder()
        let decodedCard = try decoder.decode(Card.self, from: data)

        #expect(decodedCard.title == card.title)
        #expect(decodedCard.description == card.description)
        #expect(decodedCard.photoFileNames == card.photoFileNames)
        #expect(decodedCard.id == card.id)
    }
}

// MARK: - Column Tests

struct ColumnTests {

    @Test func columnInitialization() {
        let column = Column(title: "To Do")

        #expect(column.title == "To Do")
        #expect(column.cards.isEmpty)
    }

    @Test func columnWithCards() {
        let card1 = Card(title: "Card 1", description: "")
        let card2 = Card(title: "Card 2", description: "")
        var column = Column(title: "In Progress")
        column.cards = [card1, card2]

        #expect(column.cards.count == 2)
    }

    @Test func columnEquality() {
        let id = UUID()
        let column1 = Column(id: id, title: "Test", cards: [], createdAt: Date())
        let column2 = Column(id: id, title: "Test", cards: [], createdAt: Date())

        #expect(column1 == column2)
    }

    @Test func columnCodable() throws {
        var column = Column(title: "Test Column")
        column.cards = [Card(title: "Test Card", description: "")]

        let encoder = JSONEncoder()
        let data = try encoder.encode(column)

        let decoder = JSONDecoder()
        let decodedColumn = try decoder.decode(Column.self, from: data)

        #expect(decodedColumn.title == column.title)
        #expect(decodedColumn.cards.count == 1)
    }
}

// MARK: - Board Tests

struct BoardTests {

    @Test func defaultBoardCreation() {
        let board = Board.defaultBoard

        #expect(board.name == "My Board")
        #expect(board.columns.count == 2)
        #expect(board.columns[0].title == "To Do")
        #expect(board.columns[1].title == "In Progress")
        #expect(board.completedCards.isEmpty)
    }

    @Test func boardInitialization() {
        let board = Board(
            name: "Project Board",
            columns: [Column(title: "Backlog")],
            ownerId: "user123"
        )

        #expect(board.name == "Project Board")
        #expect(board.columns.count == 1)
        #expect(board.ownerId == "user123")
        #expect(board.sharedWith.isEmpty)
    }

    @Test func boardSharing() {
        var board = Board(name: "Shared Board", columns: [], ownerId: "owner")
        let share = BoardShare(
            userId: "user2",
            userName: "John",
            accessLevel: .edit,
            sharedAt: Date()
        )
        board.sharedWith.append(share)

        #expect(board.sharedWith.count == 1)
        #expect(board.sharedWith.first?.userName == "John")
        #expect(board.sharedWith.first?.accessLevel == .edit)
    }

    @Test func boardCodable() throws {
        let board = Board(
            name: "Codable Board",
            columns: [Column(title: "Test")],
            ownerId: "owner"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(board)

        let decoder = JSONDecoder()
        let decodedBoard = try decoder.decode(Board.self, from: data)

        #expect(decodedBoard.name == board.name)
        #expect(decodedBoard.columns.count == board.columns.count)
    }
}

// MARK: - Workspace Tests

struct WorkspaceTests {

    @Test func workspaceInitialization() {
        let board = Board.defaultBoard
        let workspace = Workspace(
            boards: [board],
            currentBoardId: board.id,
            userId: "user123"
        )

        #expect(workspace.boards.count == 1)
        #expect(workspace.currentBoardId == board.id)
        #expect(workspace.userId == "user123")
    }

    @Test func workspaceMultipleBoards() {
        let board1 = Board(name: "Board 1", columns: [], ownerId: "user")
        let board2 = Board(name: "Board 2", columns: [], ownerId: "user")
        let workspace = Workspace(
            boards: [board1, board2],
            currentBoardId: board1.id,
            userId: "user"
        )

        #expect(workspace.boards.count == 2)
    }

    @Test func workspaceCodable() throws {
        let board = Board.defaultBoard
        let workspace = Workspace(
            boards: [board],
            currentBoardId: board.id,
            userId: "user"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(workspace)

        let decoder = JSONDecoder()
        let decodedWorkspace = try decoder.decode(Workspace.self, from: data)

        #expect(decodedWorkspace.boards.count == workspace.boards.count)
        #expect(decodedWorkspace.userId == workspace.userId)
    }
}

// MARK: - BoardManager Tests

struct BoardManagerTests {

    @Test func boardManagerInitialization() {
        let manager = BoardManager()

        #expect(!manager.workspace.boards.isEmpty)
        #expect(manager.board.columns.count >= 2)
    }

    @Test func createBoard() {
        let manager = BoardManager()
        let initialCount = manager.workspace.boards.count

        let newBoard = manager.createBoard(name: "New Board")

        #expect(manager.workspace.boards.count == initialCount + 1)
        #expect(newBoard.name == "New Board")
        #expect(manager.workspace.currentBoardId == newBoard.id)
    }

    @Test func createBoardWithEmptyName() {
        let manager = BoardManager()
        let newBoard = manager.createBoard(name: "")

        #expect(newBoard.name == "New Board")
    }

    @Test func switchBoard() {
        let manager = BoardManager()
        let board1 = manager.createBoard(name: "Board 1")
        let board2 = manager.createBoard(name: "Board 2")

        manager.switchToBoard(board1.id)
        #expect(manager.workspace.currentBoardId == board1.id)

        manager.switchToBoard(board2.id)
        #expect(manager.workspace.currentBoardId == board2.id)
    }

    @Test func renameBoard() {
        let manager = BoardManager()
        let board = manager.createBoard(name: "Original Name")

        manager.renameBoard(board.id, newName: "New Name")

        let renamedBoard = manager.workspace.boards.first { $0.id == board.id }
        #expect(renamedBoard?.name == "New Name")
    }

    @Test func deleteBoardPreventsLastBoardDeletion() {
        let manager = BoardManager()
        // Clear all boards and create just one
        manager.workspace.boards.removeAll()
        let singleBoard = manager.createBoard(name: "Only Board")

        manager.deleteBoard(singleBoard.id)

        // Should still have one board (deletion prevented)
        #expect(manager.workspace.boards.count == 1)
    }

    @Test func deleteBoardWithMultiple() {
        let manager = BoardManager()
        let board1 = manager.createBoard(name: "Board 1")
        let board2 = manager.createBoard(name: "Board 2")
        let countBefore = manager.workspace.boards.count

        manager.deleteBoard(board1.id)

        #expect(manager.workspace.boards.count == countBefore - 1)
        #expect(!manager.workspace.boards.contains { $0.id == board1.id })
    }

    @Test func addCard() {
        let manager = BoardManager()
        let columnId = manager.board.columns.first!.id
        let cardsBefore = manager.board.columns.first!.cards.count

        manager.addCard(to: columnId, title: "New Card", description: "Description")

        let cardsAfter = manager.board.columns.first!.cards.count
        #expect(cardsAfter == cardsBefore + 1)
    }

    @Test func addCardWithPhotos() {
        let manager = BoardManager()
        let columnId = manager.board.columns.first!.id

        manager.addCard(
            to: columnId,
            title: "Card with Photos",
            description: "",
            photoFileNames: ["photo1.jpg", "photo2.jpg"]
        )

        let card = manager.board.columns.first!.cards.last!
        #expect(card.photoFileNames.count == 2)
    }

    @Test func addCardCreatesHistoryEntry() {
        let manager = BoardManager()
        let columnId = manager.board.columns.first!.id

        manager.addCard(to: columnId, title: "Test Card", description: "")

        let card = manager.board.columns.first!.cards.last!
        #expect(card.history.count == 1)
        #expect(card.history.first!.description.contains("created"))
    }

    @Test func deleteCard() {
        let manager = BoardManager()
        let columnId = manager.board.columns.first!.id
        manager.addCard(to: columnId, title: "Card to Delete", description: "")

        let card = manager.board.columns.first!.cards.last!
        let cardsBefore = manager.board.columns.first!.cards.count

        manager.deleteCard(card.id, from: columnId)

        let cardsAfter = manager.board.columns.first!.cards.count
        #expect(cardsAfter == cardsBefore - 1)
    }

    @Test func updateCard() {
        let manager = BoardManager()
        let columnId = manager.board.columns.first!.id
        manager.addCard(to: columnId, title: "Original Title", description: "Original Description")

        var card = manager.board.columns.first!.cards.last!
        card.title = "Updated Title"
        card.description = "Updated Description"

        manager.updateCard(card, in: columnId)

        let updatedCard = manager.board.columns.first!.cards.last!
        #expect(updatedCard.title == "Updated Title")
        #expect(updatedCard.description == "Updated Description")
    }

    @Test func updateCardTracksChanges() {
        let manager = BoardManager()
        let columnId = manager.board.columns.first!.id
        manager.addCard(to: columnId, title: "Original", description: "Original")

        var card = manager.board.columns.first!.cards.last!
        let historyCountBefore = card.history.count
        card.title = "Changed"

        manager.updateCard(card, in: columnId)

        let updatedCard = manager.board.columns.first!.cards.last!
        #expect(updatedCard.history.count == historyCountBefore + 1)
    }

    @Test func moveCardBetweenColumns() {
        let manager = BoardManager()
        let sourceColumnId = manager.board.columns[0].id
        let destColumnId = manager.board.columns[1].id

        manager.addCard(to: sourceColumnId, title: "Card to Move", description: "")
        let card = manager.board.columns[0].cards.last!
        let sourceCountBefore = manager.board.columns[0].cards.count
        let destCountBefore = manager.board.columns[1].cards.count

        manager.moveCard(card.id, from: sourceColumnId, to: destColumnId, at: 0)

        #expect(manager.board.columns[0].cards.count == sourceCountBefore - 1)
        #expect(manager.board.columns[1].cards.count == destCountBefore + 1)
    }

    @Test func moveCardAddsHistoryEntry() {
        let manager = BoardManager()
        let sourceColumnId = manager.board.columns[0].id
        let destColumnId = manager.board.columns[1].id

        manager.addCard(to: sourceColumnId, title: "Card to Move", description: "")
        let card = manager.board.columns[0].cards.last!
        let historyCountBefore = card.history.count

        manager.moveCard(card.id, from: sourceColumnId, to: destColumnId, at: 0)

        let movedCard = manager.board.columns[1].cards.first!
        #expect(movedCard.history.count == historyCountBefore + 1)
        #expect(movedCard.history.last!.description.contains("Moved"))
    }

    @Test func markCardAsDone() {
        let manager = BoardManager()
        let columnId = manager.board.columns.first!.id
        manager.addCard(to: columnId, title: "Card to Complete", description: "")

        let card = manager.board.columns.first!.cards.last!
        let completedBefore = manager.board.completedCards.count
        let columnCardsBefore = manager.board.columns.first!.cards.count

        manager.markCardAsDone(card.id, from: columnId)

        #expect(manager.board.completedCards.count == completedBefore + 1)
        #expect(manager.board.columns.first!.cards.count == columnCardsBefore - 1)
    }

    @Test func markCardAsDoneAddsHistoryEntry() {
        let manager = BoardManager()
        let columnId = manager.board.columns.first!.id
        manager.addCard(to: columnId, title: "Card to Complete", description: "")

        let card = manager.board.columns.first!.cards.last!

        manager.markCardAsDone(card.id, from: columnId)

        let completedCard = manager.board.completedCards.last!
        #expect(completedCard.history.last!.description.contains("done"))
    }

    @Test func getToDoColumnId() {
        let manager = BoardManager()
        let toDoId = manager.getToDoColumnId()

        #expect(toDoId != nil)

        let toDoColumn = manager.board.columns.first { $0.id == toDoId }
        #expect(toDoColumn?.title == "To Do")
    }

    @Test func shareBoard() {
        let manager = BoardManager()
        let boardId = manager.board.id

        manager.shareBoard(boardId, with: "user2", userName: "John Doe", accessLevel: .view)

        let board = manager.workspace.boards.first { $0.id == boardId }
        #expect(board?.sharedWith.count == 1)
        #expect(board?.sharedWith.first?.userName == "John Doe")
        #expect(board?.sharedWith.first?.accessLevel == .view)
    }

    @Test func shareBoardUpdatesExistingShare() {
        let manager = BoardManager()
        let boardId = manager.board.id

        manager.shareBoard(boardId, with: "user2", userName: "John", accessLevel: .view)
        manager.shareBoard(boardId, with: "user2", userName: "John Updated", accessLevel: .edit)

        let board = manager.workspace.boards.first { $0.id == boardId }
        #expect(board?.sharedWith.count == 1)
        #expect(board?.sharedWith.first?.accessLevel == .edit)
    }

    @Test func removeShare() {
        let manager = BoardManager()
        let boardId = manager.board.id

        manager.shareBoard(boardId, with: "user2", userName: "John", accessLevel: .view)
        manager.removeShare(boardId, userId: "user2")

        let board = manager.workspace.boards.first { $0.id == boardId }
        #expect(board?.sharedWith.isEmpty == true)
    }
}

// MARK: - CardHistoryEntry Tests

struct CardHistoryEntryTests {

    @Test func historyEntryInitialization() {
        let entry = CardHistoryEntry(description: "Test entry")

        #expect(entry.description == "Test entry")
        #expect(entry.timestamp <= Date())
    }

    @Test func historyEntryCodable() throws {
        let entry = CardHistoryEntry(description: "Codable test")

        let encoder = JSONEncoder()
        let data = try encoder.encode(entry)

        let decoder = JSONDecoder()
        let decodedEntry = try decoder.decode(CardHistoryEntry.self, from: data)

        #expect(decodedEntry.description == entry.description)
        #expect(decodedEntry.id == entry.id)
    }
}

// MARK: - BoardShare Tests

struct BoardShareTests {

    @Test func boardShareInitialization() {
        let share = BoardShare(
            userId: "user123",
            userName: "Test User",
            accessLevel: .edit,
            sharedAt: Date()
        )

        #expect(share.userId == "user123")
        #expect(share.userName == "Test User")
        #expect(share.accessLevel == .edit)
    }

    @Test func boardShareAccessLevels() {
        let viewShare = BoardShare(userId: "1", userName: "Viewer", accessLevel: .view, sharedAt: Date())
        let editShare = BoardShare(userId: "2", userName: "Editor", accessLevel: .edit, sharedAt: Date())

        #expect(viewShare.accessLevel == .view)
        #expect(editShare.accessLevel == .edit)
    }

    @Test func boardShareCodable() throws {
        let share = BoardShare(
            userId: "user",
            userName: "Name",
            accessLevel: .edit,
            sharedAt: Date()
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(share)

        let decoder = JSONDecoder()
        let decodedShare = try decoder.decode(BoardShare.self, from: data)

        #expect(decodedShare.userId == share.userId)
        #expect(decodedShare.accessLevel == share.accessLevel)
    }
}
