//
//  ComicRowView.swift
//  XKCDcomics
//
//  Created by Otto A Robsahm on 15/11/2025.
//

import SwiftUI

// Single comic row in list
struct ComicRowView: View {
    let comic: Comic
    let isFavorite: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            AsyncImage(url: URL(string: comic.img)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(comic.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("#\(comic.num)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let date = comic.date {
                    Text(date, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Favorite indicator
            if isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.title3)
            }
           
        }
        .padding(.vertical, 4)
    }
}
