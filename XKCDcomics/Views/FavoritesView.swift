//
//  FavoritesView.swift
//  XKCDcomics
//
//  Created by Otto A Robsahm on 15/11/2025.
//

import SwiftData
import SwiftUI

// Favorites list view
struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @Query(sort: \FavoriteComic.savedDate, order: .reverse) private
        var favorites: [FavoriteComic]

    var body: some View {
        NavigationStack {
            Group {
                // Empty state
                if favorites.isEmpty {
                    ContentUnavailableView(
                        "No Favorites",
                        systemImage: "star.slash",
                        description: Text(
                            "Comics you favorite will appear here"
                        )
                    )
                    // Favorites list
                } else {
                    List {
                        ForEach(favorites) { favorite in
                            NavigationLink {
                                ComicDetailView(
                                    comic: favorite.toComic(),
                                    favoritesViewModel: favoritesViewModel
                                )
                            } label: {
                                HStack(spacing: 12) {
                                    // Thumbnail
                                    AsyncImage(url: URL(string: favorite.img)) {
                                        image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 60, height: 60)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 8)
                                    )

                                    // Info
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(favorite.title)
                                            .font(.headline)
                                            .lineLimit(2)

                                        Text("#\(favorite.num)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .swipeActions(edge: .trailing) {
                                // Share action
                                if let url = URL(
                                    string: "https://xkcd.com/\(favorite.num)"
                                ) {
                                    ShareLink(
                                        item: url,
                                        subject: Text(favorite.title),
                                        message: Text(
                                            "Check out this xkcd comic: \(favorite.title)"
                                        )
                                    ) {
                                        Label(
                                            "Share",
                                            systemImage: "square.and.arrow.up"
                                        )
                                    }
                                    .tint(.blue)
                                }
                            }
                            swipeActions(edge: .trailing) {
                                // Share action
                                if let url = URL(string: "https://xkcd.com/\(favorite.num)") {
                                    ShareLink(item: url, subject: Text(favorite.title), message: Text("Check out this xkcd comic: \(favorite.title)")) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                        .onDelete(perform: deleteFavorites)
                    }
                }
            }
            .navigationTitle("Favorites")
            .toolbar {
                if !favorites.isEmpty {
                    EditButton()
                }
            }
        }
    }

    // Delete favorite
    private func deleteFavorites(at offsets: IndexSet) {
        for index in offsets {
            let favorite = favorites[index]
            modelContext.delete(favorite)
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to delete favorite: \(error)")
        }
    }
}
