//
//  CardView.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import SwiftUI
import UIKit

struct CardView: View {
    let card: Card
    let columnId: UUID
    @EnvironmentObject var boardManager: BoardManager
    @State private var showingEditCard = false
    @State private var cardImages: [UIImage] = [] // Keep for drag preview only
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(card.title)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)

            if !card.description.isEmpty {
                Text(card.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }

            HStack {
                Spacer()
                Text(formatDate(card.createdAt))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            showingEditCard = true
        }
        .draggable(card.id.uuidString) {
            // Drag preview
            VStack(alignment: .leading, spacing: 8) {
                if let firstImage = cardImages.first {
                    Image(uiImage: firstImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 100)
                        .clipped()
                        .cornerRadius(8)
                }
                Text(card.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                if !card.description.isEmpty {
                    Text(card.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding()
            .frame(width: 250)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(radius: 4)
        }
        .sheet(isPresented: $showingEditCard) {
            EditCardView(card: card, columnId: columnId)
                .environmentObject(boardManager)
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
