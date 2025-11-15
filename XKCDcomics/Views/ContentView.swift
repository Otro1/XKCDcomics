//
//  ContentView.swift
//  XKCDcomics
//
//  Created by Otto A Robsahm on 15/11/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var favoritesViewModel: FavoritesViewModel

    init(modelContext: ModelContext) {
        _favoritesViewModel = StateObject(wrappedValue: FavoritesViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        TabView {
            // Browse comics tab
            ComicListView(favoritesViewModel: favoritesViewModel)
                .tabItem {
                    Label("Browse", systemImage: "book.fill")
                }
            
            // Favorites tab
            FavoritesView(favoritesViewModel: favoritesViewModel)
                .tabItem {
                    Label("Favorites", systemImage: "star.fill")
                }
        }
    }
}
