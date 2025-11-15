//
//  ComicListView.swift
//  XKCDcomics
//
//  Created by Otto A Robsahm on 15/11/2025.
//

import SwiftData
import SwiftUI

struct ComicListView: View {
    @StateObject private var viewModel = ComicListViewModel()

    var body: some View {
        NavigationStack {
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
                                ComicDetailView(comic: comic)
                            } label: {
                                ComicRowView(comic: comic)
                            }
                        }
                        // Pagination controls
                        if viewModel.currentPage > 0 {
                            Section {
                                PaginationControlsView(viewModel: viewModel)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                    }
                }
            }
            .refreshable {
                await viewModel.loadPage(viewModel.currentPage)
            }
        }
        .navigationTitle("XKCD Comics")
        .searchable(text: $viewModel.searchText, prompt: "Search for comics")
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
    }
}
