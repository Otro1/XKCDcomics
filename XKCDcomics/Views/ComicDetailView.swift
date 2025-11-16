//
//  ComicDetailView.swift
//  XKCDcomics
//
//  Created by Otto A Robsahm on 15/11/2025.
//

import SafariServices
import SwiftUI

// Full comic detail view
struct ComicDetailView: View {
    let comic: Comic
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @State private var showExplanation = false
    let cachedImageData: Data?

    init(
        comic: Comic,
        favoritesViewModel: FavoritesViewModel,
        cachedImageData: Data? = nil
    ) {
        self.comic = comic
        self.favoritesViewModel = favoritesViewModel
        self.cachedImageData = cachedImageData
    }

    var comicURL: URL? {
        URL(string: "https://xkcd.com/\(comic.num)")
    }

    var explainURL: URL? {
        URL(string: "https://www.explainxkcd.com/wiki/index.php/\(comic.num)")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Text(comic.title)
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.center)
                        Spacer()
                    }

                    HStack {
                        Text("Comic #\(comic.num)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    HStack {
                        if let date = comic.date {
                            HStack {
                                Text("Posting date: \(date, style: .date)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                        }
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

                VStack {
                    // Comic image
                    if let imageData = cachedImageData,
                        let uiImage = UIImage(data: imageData)
                    {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 500)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                            )
                            .padding(.horizontal)
                    } else {
                        AsyncImage(url: URL(string: comic.img)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxHeight: 500)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        )
                        .padding(.horizontal)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        // description text
                        VStack(alignment: .leading, spacing: 8) {
                            Text(comic.alt)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()

                        // Buttons
                        HStack(spacing: 8) {

                            // Explain button
                            Button {
                                showExplanation = true
                            } label: {
                                Label(
                                    "Explain this comic",
                                    systemImage: "link"
                                )
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color("BackgroundColor"))
                        }
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

            }
            .foregroundColor(.black)
            .padding(.vertical)
        }
        .background(Color("BackgroundColor").ignoresSafeArea())  // Background
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showExplanation) {
            if let url = explainURL {
                SafariView(url: url)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        favoritesViewModel.toggleFavorite(comic)
                    } label: {
                        Image(
                            systemName: favoritesViewModel.isFavorite(comic)
                                ? "star.fill" : "star"
                        )
                        .foregroundColor(
                            favoritesViewModel.isFavorite(comic)
                                ? .yellow : .blue
                        )
                    }

                    if let url = comicURL {
                        ShareLink(
                            item: url,
                            subject: Text(comic.title),
                            message: Text(
                                "Check out this xkcd comic: \(comic.title)"
                            )
                        ) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
    }
}

// Safari web view wrapper
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: Context
    ) {
    }
}
