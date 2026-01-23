//
//  KanbanBoardApp.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import SwiftUI

@main
struct KanbanBoardApp: App {
    @StateObject private var boardManager = BoardManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(boardManager)
        }
    }
}
