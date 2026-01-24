//
//  ContentView.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var boardManager: BoardManager
    @State private var showingAddCard = false
    @State private var showingCompletedTickets = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            KanbanBoardView()
                .navigationTitle(boardManager.board.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button(action: {
                                showingCompletedTickets = true
                            }) {
                                Label("Completed Tickets", systemImage: "checkmark.circle")
                            }
                            
                            Button(action: {
                                showingSettings = true
                            }) {
                                Label("Settings", systemImage: "gearshape")
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddCard = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddCard) {
                    if let toDoColumnId = boardManager.getToDoColumnId() {
                        AddCardView(columnId: toDoColumnId)
                            .environmentObject(boardManager)
                    }
                }
                .sheet(isPresented: $showingCompletedTickets) {
                    CompletedTicketsView()
                        .environmentObject(boardManager)
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                        .environmentObject(boardManager)
                }
        }
    }
}
