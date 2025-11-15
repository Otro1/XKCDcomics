//
//  ContentView.swift
//  XKCDcomics
//
//  Created by Otto A Robsahm on 15/11/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    var body: some View {
        TabView {
            // Browse comics tab
            ComicListView()
                .tabItem {
                    Label("Browse", systemImage: "book.fill")
                }
        }
    }
}
