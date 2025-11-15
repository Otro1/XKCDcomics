//
//  ComicListViewModel.swift
//  XKCDcomics
//
//  Created by Otto A Robsahm on 15/11/2025.
//

import Combine
import Foundation

@MainActor
class ComicListViewModel: ObservableObject {
    @Published var comics: [Comic] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var currentPage = 1
    @Published var loadingProgress: String?
    @Published var isShowingSearchResults = false

    private let service = ComicService()
    private var latestComicNumber: Int?
    private let comicsPerPage = 20
    private var comicCache: [Int: Comic] = [:]

    // Calculate total pages
    var totalPages: Int {
        guard let latest = latestComicNumber else { return 0 }
        return (latest + comicsPerPage - 1) / comicsPerPage
    }

    // Check if previous page exists
    var canGoToPreviousPage: Bool {
        currentPage > 1
    }

    // Check if next page exists
    var canGoToNextPage: Bool {
        currentPage < totalPages
    }

    // Display text for current range
    var pageRangeText: String {
        guard let latest = latestComicNumber else { return "" }
        let startNum = latest - (currentPage - 1) * comicsPerPage
        let endNum = max(1, startNum - comicsPerPage + 1)
        return "Comics #\(endNum) - #\(startNum)"
    }

    // Load latest comic number and first page
    func loadLatestComic() async {
        do {
            let latestComic = try await service.fetchComic()
            latestComicNumber = latestComic.num
            await loadPage(1)
        } catch {
            errorMessage =
                "Failed to load latest comic. Please try again later."
            isLoading = false
        }
    }

    // Load specific page of comics
    func loadPage(_ page: Int) async {
        guard let latest = latestComicNumber else { return }

        isLoading = true
        errorMessage = nil
        currentPage = page

        let startNum = latest - (page - 1) * comicsPerPage
        let endNum = max(1, startNum - comicsPerPage + 1)

        var loadedComics: [Comic] = []
        for num in stride(from: startNum, through: endNum, by: -1) {
            if let comic = try? await service.fetchComic(id: num) {
                loadedComics.append(comic)
                comicCache[comic.num] = comic
            }
        }

        comics = loadedComics
        isLoading = false
    }

    // Navigate to next page
    func loadNextPage() async {
        guard canGoToNextPage else { return }
        await loadPage(currentPage + 1)
    }

    // Navigate to previous page
    func loadPreviousPage() async {
        guard canGoToPreviousPage else { return }
        await loadPage(currentPage - 1)
    }

    // Search for comic by number or title
    func searchComic() async {
        guard !searchText.isEmpty else {
            errorMessage = "Please enter a comic number or title"
            return
        }

        let searchTerm = searchText
        isLoading = true
        errorMessage = nil
        currentPage = 0
        isShowingSearchResults = true

        // Try searching by number first
        if let comicNumber = Int(searchTerm),
            comicNumber > 0,
            let latest = latestComicNumber,
            comicNumber <= latest
        {
            do {
                let comic = try await service.fetchComic(id: comicNumber)
                comicCache[comic.num] = comic
                comics = [comic]
                isLoading = false
                return
            } catch {
                errorMessage = "Failed to find comic #\(comicNumber)"
                isLoading = false
                return
            }
        }

        // Search by title with progressive loading
        guard let latest = latestComicNumber else {
            isLoading = false
            return
        }

        comics = []

        let searchLower = searchTerm.lowercased()
        let batchSize = 100
        var processedCount = 0

        for batchStart in stride(from: latest, through: 1, by: -batchSize) {
            let batchEnd = max(1, batchStart - batchSize + 1)

            await withTaskGroup(of: Comic?.self) { group in
                for num in stride(from: batchStart, through: batchEnd, by: -1) {
                    if let cached = comicCache[num] {
                        if cached.title.lowercased().contains(searchLower) {
                            comics.append(cached)
                        }
                        continue
                    }

                    group.addTask {
                        try? await self.service.fetchComic(id: num)
                    }
                }

                for await comic in group {
                    if let comic = comic {
                        comicCache[comic.num] = comic
                        if comic.title.lowercased().contains(searchLower) {
                            comics.append(comic)
                            comics.sort { $0.num > $1.num }
                        }
                    }
                }
            }

            processedCount += batchSize
            loadingProgress =
                "Searched \(min(processedCount, latest)) of \(latest) comics..."
        }

        if comics.isEmpty {
            errorMessage = "No comics found matching '\(searchTerm)'"
        }

        isLoading = false
        loadingProgress = nil
    }

    // Clear search and return to browse mode
    func clearSearch() async {
        isShowingSearchResults = false
        searchText = ""
        await loadPage(1)
    }
}
