//
//  ComicService.swift
//  XKCDcomics
//
//  Created by Otto A Robsahm on 15/11/2025.
//

import Foundation

// Error types
enum ComicServiceError: Error {
    case invalidURL
    case networkError
    case decodingError
}

// Service to fetch comics
class ComicService {
    private let baseURL = "https://xkcd.com"

    // Fetch by ID or latest if no ID
    func fetchComic(id: Int? = nil) async throws -> Comic {
        let urlString: String
        if let id = id {
            urlString = "\(baseURL)/\(id)/info.0.json"
        } else {
            urlString = "\(baseURL)/info.0.json"
        }

        guard let url = URL(string: urlString) else {
            throw ComicServiceError.invalidURL
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let comic = try JSONDecoder().decode(Comic.self, from: data)
            return comic
        } catch is DecodingError {
            throw ComicServiceError.decodingError
        } catch {
            throw ComicServiceError.networkError
        }
    }
}
