//
//  PhotoManagementView.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import SwiftUI
import PhotosUI
import UIKit

struct PhotoManagementView: View {
    @Binding var selectedImages: [UIImage]
    @Binding var selectedPhotos: [PhotosPickerItem]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Manage Photos")) {
                    PhotosPicker(selection: $selectedPhotos, matching: .images) {
                        Label("Add Photos", systemImage: "photo.on.rectangle")
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
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8)
                        ], spacing: 8) {
                            ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .aspectRatio(1, contentMode: .fit)
                                        .clipped()
                                        .cornerRadius(8)
                                    
                                    Button {
                                        // Remove from selectedPhotos first (if it exists), then from selectedImages
                                        if index < selectedPhotos.count {
                                            selectedPhotos.remove(at: index)
                                        }
                                        selectedImages.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Color.red)
                                            .clipShape(Circle())
                                            .font(.caption)
                                    }
                                    .offset(x: 4, y: -4)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Manage Photos")
            .navigationBarTitleDisplayMode(.inline)
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
