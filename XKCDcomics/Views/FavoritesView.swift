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
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Text("Favorites")
                            .font(.title)
                            .bold()
                        Spacer()

                        if !favorites.isEmpty {
                            EditButton()
                        }
                    }

                    HStack {
                        Text(
                            "\(favorites.count) saved comic\(favorites.count == 1 ? "" : "s")"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.black, lineWidth: 0.6)
                )
                .padding(.horizontal)
                .padding(.top)

                VStack {
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
                                            favoritesViewModel:
                                                favoritesViewModel,
                                            cachedImageData: favorite.imageData
                                        )
                                    } label: {
                                        VStack(alignment: .leading, spacing: 8)
                                        {
                                            HStack(spacing: 12) {
                                                // Thumbnail
                                                if let imageData = favorite
                                                    .imageData,
                                                    let uiImage = UIImage(
                                                        data: imageData
                                                    )
                                                {
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .aspectRatio(
                                                            contentMode: .fill
                                                        )
                                                        .frame(
                                                            width: 80,
                                                            height: 80
                                                        )
                                                        .clipShape(
                                                            RoundedRectangle(
                                                                cornerRadius: 8
                                                            )
                                                        )
                                                } else {
                                                    AsyncImage(
                                                        url: URL(
                                                            string: favorite.img
                                                        )
                                                    ) {
                                                        image in
                                                        image
                                                            .resizable()
                                                            .aspectRatio(
                                                                contentMode:
                                                                    .fill
                                                            )
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                    .frame(
                                                        width: 80,
                                                        height: 80
                                                    )
                                                    .clipShape(
                                                        RoundedRectangle(
                                                            cornerRadius: 8
                                                        )
                                                    )
                                                }

                                                // Info
                                                VStack(
                                                    alignment: .leading,
                                                    spacing: 4
                                                ) {
                                                    Text(favorite.title)
                                                        .font(.headline)
                                                        .lineLimit(2)

                                                    Text("#\(favorite.num)")
                                                        .font(.caption)
                                                        .foregroundStyle(
                                                            .secondary
                                                        )

                                                    if favorite.imageData == nil
                                                    {
                                                        Text("Image not cached")
                                                            .font(.caption2)
                                                            .foregroundStyle(
                                                                .orange
                                                            )
                                                    }
                                                }

                                                Spacer()
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                    .listRowInsets(
                                        EdgeInsets(
                                            top: 8,
                                            leading: 12,
                                            bottom: 8,
                                            trailing: 12
                                        )
                                    )
                                    .swipeActions(edge: .trailing) {
                                        // Share action
                                        if let url = URL(
                                            string:
                                                "https://xkcd.com/\(favorite.num)"
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
                                                    systemImage:
                                                        "square.and.arrow.up"
                                                )
                                            }
                                            .tint(.blue)
                                        }
                                    }
                                }
                                .onDelete(perform: deleteFavorites)
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.black, lineWidth: 0.6)
                )
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("BackgroundColor").ignoresSafeArea())
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
