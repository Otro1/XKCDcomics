//
//  ComicDetailView.swift
//  XKCDcomics
//
//  Created by Otto A Robsahm on 15/11/2025.
//

import SwiftUI

// Full comic detail view
struct ComicDetailView: View {
    let comic: Comic
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    
    var comicURL: URL? {
        URL(string: "https://xkcd.com/\(comic.num)")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text(comic.title)
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text("#\(comic.num)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let date = comic.date {
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                // Comic image
                AsyncImage(url: URL(string: comic.img)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(maxHeight: 500)
                .padding()

                
                // description text
                VStack(alignment: .leading, spacing: 8) {
                    Text(comic.alt)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Favorite button
                Button {
                    favoritesViewModel.toggleFavorite(comic)
                } label: {
                    Label(
                        favoritesViewModel.isFavorite(comic) ? "Unfavorite" : "Add to Favorites",
                        systemImage: favoritesViewModel.isFavorite(comic) ? "star.fill" : "star"
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.bordered)
                .tint(favoritesViewModel.isFavorite(comic) ? .yellow : .blue)
                .padding(.horizontal)

            }
            .padding(.vertical)
        }
        .navigationTitle("Comic #\(comic.num)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

