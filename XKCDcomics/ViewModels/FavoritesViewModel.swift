//
//  FavoritesViewModel.swift
//  XKCDcomics
//
//  Created by Otto A Robsahm on 15/11/2025.
//

import Combine
import Foundation
import SwiftData
import UIKit

// Manages favorite comics
class FavoritesViewModel: ObservableObject {
    private var modelContext: ModelContext
    @Published var updateTrigger = false

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // Check if comic is favorited
    @MainActor
    func isFavorite(_ comic: Comic) -> Bool {
        let descriptor = FetchDescriptor<FavoriteComic>(
            predicate: #Predicate { $0.num == comic.num }
        )

        do {
            let count = try modelContext.fetchCount(descriptor)
            return count > 0
        } catch {
            print("Failed to check favorite: \(error)")
            return false
        }
    }

    // Add or remove favorite
    @MainActor
    func toggleFavorite(_ comic: Comic) {
        let descriptor = FetchDescriptor<FavoriteComic>(
            predicate: #Predicate { $0.num == comic.num }
        )

        do {
            let existing = try modelContext.fetch(descriptor).first
            if let existing {
                deleteFavorite(existing)
                updateTrigger.toggle()
            } else {
                Task {
                    await addFavorite(comic)
                }
            }
        } catch {
            print("Failed to toggle favorite: \(error)")
        }
    }

    // Save comic to favorites
    @MainActor
    func addFavorite(_ comic: Comic) async {
        print("Starting to add favorite: \(comic.title)")
        let imageData = await downloadImage(from: comic.img)
        
        if imageData != nil {
            print("Successfully downloaded image for: \(comic.title)")
        } else {
            print("Failed to download image for: \(comic.title)")
        }
        
        let favorite = FavoriteComic(from: comic, imageData: imageData)
        modelContext.insert(favorite)

        do {
            try modelContext.save()
            print("Successfully saved favorite: \(comic.title)")
            updateTrigger.toggle()
        } catch {
            print("Failed to save favorite: \(error)")
        }
    }

    // Remove comic from favorites
    @MainActor
    func deleteFavorite(_ favorite: FavoriteComic) {
        modelContext.delete(favorite)

        do {
            try modelContext.save()
        } catch {
            print("Failed to delete favorite: \(error)")
        }
    }
    
    // Download image data
    private func downloadImage(from urlString: String) async -> Data? {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Image download response code: \(httpResponse.statusCode) for URL: \(urlString)")
            }
            
            return data
        } catch {
            print("Failed to download image from \(urlString): \(error)")
            return nil
        }
    }
}