//
//  AddCardView.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import SwiftUI
import PhotosUI
import UIKit

struct AddCardView: View {
    let columnId: UUID
    @EnvironmentObject var boardManager: BoardManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Card Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Photos")) {
                    PhotosPicker(selection: $selectedPhotos, matching: .images) {
                        Label("Select Photos (\(selectedImages.count))", systemImage: "photo.on.rectangle")
                    }
                    .onChange(of: selectedPhotos) { oldValue, newValue in
                        Task {
                            var images: [UIImage] = []
                            for item in newValue {
                                do {
                                    if let data = try await item.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        images.append(image)
                                    }
                                } catch {
                                    print("Failed to load image: \(error)")
                                }
                            }
                            await MainActor.run {
                                selectedImages = images
                            }
                        }
                    }
                    
                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 100)
                                            .cornerRadius(8)
                                        
                                        Button {
                                            // Remove from selectedPhotos first (if it exists), then from selectedImages
                                            // This keeps indices aligned
                                            if index < selectedPhotos.count {
                                                selectedPhotos.remove(at: index)
                                            }
                                            selectedImages.remove(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                        }
                                        .offset(x: 5, y: -5)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("New Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let cardId = UUID()
                        let photoFileNames = ImageStorage.shared.saveImages(selectedImages, for: cardId)
                        
                        boardManager.addCard(to: columnId, title: title, description: description, photoFileNames: photoFileNames, cardId: cardId)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
