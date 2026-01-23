//
//  ColumnView.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import SwiftUI

struct ColumnView: View {
    let column: Column
    @EnvironmentObject var boardManager: BoardManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Column Header
            Text(column.title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
                .padding(.top)
            
            // Card Count
            Text("\(column.cards.count) cards")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // Cards List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(column.cards) { card in
                        CardView(card: card, columnId: column.id)
                            .environmentObject(boardManager)
                    }
                }
                .padding(.horizontal)
            }
            .dropDestination(for: String.self) { droppedCardIds, location in
                guard let cardIdString = droppedCardIds.first,
                      let cardId = UUID(uuidString: cardIdString) else {
                    return false
                }
                
                // Find source column
                for sourceColumn in boardManager.board.columns {
                    if let cardIndex = sourceColumn.cards.firstIndex(where: { $0.id == cardId }) {
                        let insertIndex = min(column.cards.count, max(0, Int(location.y / 100)))
                        boardManager.moveCard(cardId, from: sourceColumn.id, to: column.id, at: insertIndex)
                        return true
                    }
                }
                return false
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
