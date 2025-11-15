//
//  FavoritesViewModel.swift
//  XKCDcomics
//
//  Created by Otto A Robsahm on 15/11/2025.
//

import Combine
import Foundation
import SwiftData

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
            } else {
                addFavorite(comic)
            }
            updateTrigger.toggle()
        } catch {
            print("Failed to toggle favorite: \(error)")
        }
    }

    // Save comic to favorites
    @MainActor
    func addFavorite(_ comic: Comic) {
        let favorite = FavoriteComic(from: comic)
        modelContext.insert(favorite)

        do {
            try modelContext.save()
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
}
