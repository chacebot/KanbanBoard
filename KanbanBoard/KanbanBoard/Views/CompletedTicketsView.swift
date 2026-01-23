//
//  CompletedTicketsView.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import SwiftUI

struct CompletedTicketsView: View {
    @EnvironmentObject var boardManager: BoardManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                if boardManager.board.completedCards.isEmpty {
                    ContentUnavailableView(
                        "No Completed Tickets",
                        systemImage: "checkmark.circle",
                        description: Text("Tickets you mark as done will appear here")
                    )
                } else {
                    ForEach(boardManager.board.completedCards.sorted(by: { $0.updatedAt > $1.updatedAt })) { card in
                        CompletedCardRow(card: card)
                    }
                }
            }
            .navigationTitle("Completed Tickets")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CompletedCardRow: View {
    let card: Card
    @State private var cardImages: [UIImage] = []
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack(alignment: .top, spacing: 12) {
            // Photo thumbnails if available
            if !cardImages.isEmpty {
                if cardImages.count == 1 {
                    Image(uiImage: cardImages[0])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: cardImages[0])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipped()
                            .cornerRadius(8)
                        
                        Text("+\(cardImages.count - 1)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                            .offset(x: 5, y: -5)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(card.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if !card.description.isEmpty {
                    Text(card.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text("Completed \(formatDate(card.updatedAt))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            CompletedCardDetailView(card: card)
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        cardImages = card.photoFileNames.compactMap { fileName in
            ImageStorage.shared.loadImage(fileName: fileName)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
}
