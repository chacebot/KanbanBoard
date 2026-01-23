//
//  ShareBoardView.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import SwiftUI

struct ShareBoardView: View {
    let board: Board
    @EnvironmentObject var boardManager: BoardManager
    @Environment(\.dismiss) var dismiss
    @State private var userId = ""
    @State private var userName = ""
    @State private var accessLevel: BoardShare.ShareAccessLevel = .edit
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Information")) {
                    TextField("User ID", text: $userId)
                    TextField("User Name", text: $userName)
                }
                
                Section(header: Text("Access Level")) {
                    Picker("Access Level", selection: $accessLevel) {
                        Text("View Only").tag(BoardShare.ShareAccessLevel.view)
                        Text("Edit").tag(BoardShare.ShareAccessLevel.edit)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Share Board")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Share") {
                        if !userId.isEmpty && !userName.isEmpty {
                            boardManager.shareBoard(board.id, with: userId, userName: userName, accessLevel: accessLevel)
                        }
                        dismiss()
                    }
                    .disabled(userId.isEmpty || userName.isEmpty)
                }
            }
        }
    }
}
