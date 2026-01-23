//
//  CompletedCardDetailView.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import SwiftUI
import UIKit

struct CompletedCardDetailView: View {
    let card: Card
    @Environment(\.dismiss) var dismiss
    @State private var cardImages: [UIImage] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Card Details")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(card.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if !card.description.isEmpty {
                            Text(card.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                if !cardImages.isEmpty {
                    Section(header: Text("Photos")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(cardImages.enumerated()), id: \.offset) { index, image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 200)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Section(header: Text("Information")) {
                    HStack {
                        Text("Created")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(formatDate(card.createdAt))
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Text("Completed")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(formatDate(card.updatedAt))
                            .foregroundColor(.primary)
                    }
                }
                
                if !card.history.isEmpty {
                    Section(header: Text("History")) {
                        ForEach(card.history.sorted(by: { $0.timestamp > $1.timestamp })) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.description)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text(formatHistoryDate(entry.timestamp))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .navigationTitle("Ticket Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadImages()
            }
        }
    }
    
    private func loadImages() {
        cardImages = card.photoFileNames.compactMap { fileName in
            ImageStorage.shared.loadImage(fileName: fileName)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    private func formatHistoryDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
