//
//  EditBoardView.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import SwiftUI

struct EditBoardView: View {
    let board: Board
    @EnvironmentObject var boardManager: BoardManager
    @Environment(\.dismiss) var dismiss
    @State private var boardName: String
    @State private var showingShareSheet = false
    @State private var showingDeleteAlert = false
    
    init(board: Board) {
        self.board = board
        _boardName = State(initialValue: board.name)
    }
    
    var isCurrentBoard: Bool {
        boardManager.workspace.currentBoardId == board.id
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Board Name")) {
                    TextField("Board Name", text: $boardName)
                }
                
                Section {
                    Button(action: {
                        if !boardName.isEmpty && boardName != board.name {
                            boardManager.renameBoard(board.id, newName: boardName)
                        }
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Changes")
                        }
                        .foregroundColor(.blue)
                    }
                    .disabled(boardName.isEmpty)
                }
                
                Section(header: Text("Status")) {
                    HStack {
                        if isCurrentBoard {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                            Text("Current Board")
                                .foregroundColor(.primary)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.secondary)
                            Text("Not Current")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Actions")) {
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Share Board")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // Sharing Section
                if !board.sharedWith.isEmpty {
                    Section(header: Text("Shared With")) {
                        ForEach(board.sharedWith, id: \.userId) { share in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(share.userName)
                                        .font(.body)
                                    Text(share.accessLevel.rawValue.capitalized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(action: {
                                    boardManager.removeShare(board.id, userId: share.userId)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                
                // Danger Zone
                Section {
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Board")
                        }
                    }
                    .disabled(boardManager.workspace.boards.count <= 1)
                }
            }
            .navigationTitle("Edit Board")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareBoardView(board: board)
                    .environmentObject(boardManager)
            }
            .alert("Delete Board", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    boardManager.deleteBoard(board.id)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete \"\(board.name)\"? This action cannot be undone.")
            }
        }
    }
}
