//
//  SettingsView.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var boardManager: BoardManager
    @Environment(\.dismiss) var dismiss
    @State private var showingCreateBoard = false
    @State private var selectedBoard: Board?
    
    var currentBoard: Board {
        boardManager.board
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Boards List Section
                Section(header: Text("Boards")) {
                    ForEach(boardManager.workspace.boards) { board in
                        Button(action: {
                            boardManager.switchToBoard(board.id)
                        }) {
                            HStack {
                                Text(board.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                if board.id == currentBoard.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(action: {
                                selectedBoard = board
                            }) {
                                Label("Edit Board", systemImage: "pencil")
                            }
                            
                            if boardManager.workspace.boards.count > 1 {
                                Button(role: .destructive, action: {
                                    boardManager.deleteBoard(board.id)
                                }) {
                                    Label("Delete Board", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteBoards)
                    
                    Button(action: {
                        showingCreateBoard = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create New Board")
                        }
                        .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $showingCreateBoard) {
                        CreateBoardView()
                            .environmentObject(boardManager)
                    }
                }
                
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedBoard) { board in
                EditBoardView(board: board)
                    .environmentObject(boardManager)
            }
        }
    }
    
    private func deleteBoards(at offsets: IndexSet) {
        for index in offsets {
            let board = boardManager.workspace.boards[index]
            boardManager.deleteBoard(board.id)
        }
    }
}
