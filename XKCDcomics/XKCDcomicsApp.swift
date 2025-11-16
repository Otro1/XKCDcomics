//
//  XKCDcomicsApp.swift
//  XKCDcomics
//
//  Created by Otto A Robsahm on 15/11/2025.
//

import SwiftUI
import SwiftData

@main
struct XKCDcomicsApp: App {
    // Database setup
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FavoriteComic.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            // App entry point
            ContentView(modelContext: sharedModelContainer.mainContext)
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}