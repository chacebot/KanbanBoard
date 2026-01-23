//
//  KanbanBoardView.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import SwiftUI

struct KanbanBoardView: View {
    @EnvironmentObject var boardManager: BoardManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            if isLandscape {
                // Landscape: Show as columns (side by side)
                HStack(alignment: .top, spacing: 16) {
                    ForEach(boardManager.board.columns) { column in
                        ColumnView(column: column)
                            .environmentObject(boardManager)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Portrait: Show as rows (stacked)
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(boardManager.board.columns) { column in
                        ColumnView(column: column)
                            .environmentObject(boardManager)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
