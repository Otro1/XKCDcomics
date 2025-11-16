//
//  ComicListView.swift
//  XKCDcomics
//
//  Created by Otto A Robsahm on 15/11/2025.
//

import SwiftData
import SwiftUI

// Browse comics with pagination
struct ComicListView: View {
    @StateObject private var viewModel = ComicListViewModel()
    @ObservedObject var favoritesViewModel: FavoritesViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Text("XKCD Comics")
                            .font(.title)
                            .bold()
                        Spacer()
                    }

                    HStack {
                        Text("Browse and search comics")
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
                        //Loading state
                        if viewModel.isLoading && viewModel.comics.isEmpty {
                            ProgressView()
                            // Empty state
                        } else if viewModel.comics.isEmpty {
                            ContentUnavailableView(
                                "No Comics",
                                systemImage: "book.closed",
                                description: Text("Search for a comic")
                            )
                            // Comics list
                        } else {
                            List {
                                ForEach(viewModel.comics) { comic in
                                    NavigationLink {
                                        ComicDetailView(
                                            comic: comic,
                                            favoritesViewModel:
                                                favoritesViewModel
                                        )
                                    } label: {
                                        ComicRowView(
                                            comic: comic,
                                            isFavorite:
                                                favoritesViewModel.isFavorite(
                                                    comic
                                                )
                                        )
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
                                        // Favorite action
                                        Button {
                                            favoritesViewModel.toggleFavorite(
                                                comic
                                            )
                                        } label: {
                                            Label(
                                                favoritesViewModel.isFavorite(
                                                    comic
                                                )
                                                    ? "Unfavorite" : "Favorite",
                                                systemImage:
                                                    favoritesViewModel
                                                    .isFavorite(comic)
                                                    ? "star.slash" : "star.fill"
                                            )
                                        }
                                        .tint(
                                            favoritesViewModel.isFavorite(comic)
                                                ? .gray : .yellow
                                        )

                                        // Share action
                                        if let url = URL(
                                            string:
                                                "https://xkcd.com/\(comic.num)"
                                        ) {
                                            ShareLink(
                                                item: url,
                                                subject: Text(comic.title),
                                                message: Text(
                                                    "Check out this xkcd comic: \(comic.title)"
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

                                // Pagination controls
                                if viewModel.currentPage > 0 {
                                    Section {
                                        PaginationControlsView(
                                            viewModel: viewModel
                                        )
                                    }
                                    .listRowInsets(
                                        EdgeInsets(
                                            top: 0,
                                            leading: 0,
                                            bottom: 0,
                                            trailing: 0
                                        )
                                    )
                                    .listRowBackground(Color.clear)
                                }

                                // Error message
                                if let error = viewModel.errorMessage {
                                    Text(error)
                                        .foregroundStyle(.red)
                                        .padding()
                                        .listRowInsets(
                                            EdgeInsets(
                                                top: 8,
                                                leading: 12,
                                                bottom: 8,
                                                trailing: 12
                                            )
                                        )
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .listRowBackground(Color.clear)
                            .refreshable {
                                await viewModel.loadPage(viewModel.currentPage)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            .searchable(
                text: $viewModel.searchText,
                prompt: "Search for comics"
            )

            .onSubmit(of: .search) {
                Task {
                    await viewModel.searchComic()
                }
            }
            .onChange(of: viewModel.searchText) { oldValue, newValue in
                if newValue.isEmpty && !oldValue.isEmpty
                    && viewModel.isShowingSearchResults
                {
                    Task {
                        await viewModel.clearSearch()
                    }
                }
            }
            .task {
                if viewModel.comics.isEmpty {
                    await viewModel.loadLatestComic()
                }
            }
            .background(Color("BackgroundColor").ignoresSafeArea())
        }

    }
}
