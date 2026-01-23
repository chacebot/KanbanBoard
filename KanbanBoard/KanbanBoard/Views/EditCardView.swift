//
//  EditCardView.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import SwiftUI
import PhotosUI
import UIKit

struct EditCardView: View {
    let card: Card
    let columnId: UUID
    @EnvironmentObject var boardManager: BoardManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var showingPhotoViewer = false
    @State private var selectedPhotoIndex = 0
    @State private var showingPhotoManagement = false
    
    init(card: Card, columnId: UUID) {
        self.card = card
        self.columnId = columnId
        _title = State(initialValue: card.title)
        _description = State(initialValue: card.description)
        
        // Load existing images if available
        let existingImages = card.photoFileNames.compactMap { fileName in
            ImageStorage.shared.loadImage(fileName: fileName)
        }
        _selectedImages = State(initialValue: existingImages)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Card Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    HStack {
                        Text("Photos")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            showingPhotoManagement = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "pencil")
                                Text("Edit Photos")
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if !selectedImages.isEmpty {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8)
                        ], spacing: 8) {
                            ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                Button(action: {
                                    selectedPhotoIndex = index
                                    showingPhotoViewer = true
                                }) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .aspectRatio(1, contentMode: .fit)
                                        .clipped()
                                        .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        Text("No photos")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    }
                } header: {
                    Text("Photos")
                }
                
                Section {
                    Button {
                        boardManager.markCardAsDone(card.id, from: columnId)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Mark as Done")
                        }
                        .foregroundColor(.green)
                    }
                }
                
                if !card.history.isEmpty {
                    Section(header: Text("History")) {
                        ForEach(card.history.sorted(by: { $0.timestamp > $1.timestamp })) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.description)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text(formatDate(entry.timestamp))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .navigationTitle("Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showingPhotoViewer) {
                PhotoViewer(images: selectedImages, selectedIndex: $selectedPhotoIndex)
            }
            .sheet(isPresented: $showingPhotoManagement) {
                PhotoManagementView(selectedImages: $selectedImages, selectedPhotos: $selectedPhotos)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedCard = card
                        updatedCard.title = title
                        updatedCard.description = description
                        
                        // Handle photo update
                        // Delete old photos
                        ImageStorage.shared.deleteImages(fileNames: card.photoFileNames)
                        
                        // Save new photos
                        updatedCard.photoFileNames = ImageStorage.shared.saveImages(selectedImages, for: card.id)
                        
                        boardManager.updateCard(updatedCard, in: columnId)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
