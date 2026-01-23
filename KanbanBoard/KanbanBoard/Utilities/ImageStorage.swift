//
//  ImageStorage.swift
//  KanbanBoard
//
//  Created on 2026-01-23.
//

import Foundation
import UIKit

class ImageStorage {
    static let shared = ImageStorage()
    
    private let imagesDirectory: URL
    
    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        imagesDirectory = documentsPath.appendingPathComponent("CardImages")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
    }
    
    func saveImage(_ image: UIImage, for cardId: UUID, index: Int = 0) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        let fileName = "\(cardId.uuidString)_\(index).jpg"
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            return fileName
        } catch {
            print("Failed to save image: \(error)")
            return nil
        }
    }
    
    func saveImages(_ images: [UIImage], for cardId: UUID) -> [String] {
        var savedFileNames: [String] = []
        for (index, image) in images.enumerated() {
            if let fileName = saveImage(image, for: cardId, index: index) {
                savedFileNames.append(fileName)
            }
        }
        return savedFileNames
    }
    
    func loadImage(fileName: String) -> UIImage? {
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        guard let imageData = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    func deleteImage(fileName: String) {
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    func deleteImages(fileNames: [String]) {
        for fileName in fileNames {
            deleteImage(fileName: fileName)
        }
    }
    
    func deleteAllImages(for cardId: UUID) {
        // Delete all images for a card (with any index)
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil)
            let cardFiles = files.filter { $0.lastPathComponent.hasPrefix("\(cardId.uuidString)_") }
            for file in cardFiles {
                try? fileManager.removeItem(at: file)
            }
        } catch {
            print("Failed to list images: \(error)")
        }
    }
}
