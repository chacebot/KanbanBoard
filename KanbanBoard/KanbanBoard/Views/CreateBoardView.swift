//
//  CreateBoardView.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import SwiftUI

struct CreateBoardView: View {
    @EnvironmentObject var boardManager: BoardManager
    @Environment(\.dismiss) var dismiss
    @State private var boardName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Board Name")) {
                    TextField("Enter board name", text: $boardName)
                }
            }
            .navigationTitle("Create Board")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        if !boardName.isEmpty {
                            boardManager.createBoard(name: boardName)
                        }
                        dismiss()
                    }
                    .disabled(boardName.isEmpty)
                }
            }
        }
    }
}
