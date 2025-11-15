//
//  PaginationControlsView.swift
//  XKCDcomics
//
//  Created by Otto A Robsahm on 15/11/2025.
//

import SwiftUI

// Page navigation controls
struct PaginationControlsView: View {
    @ObservedObject var viewModel: ComicListViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Divider()
            
            // Page range text
            Text(viewModel.pageRangeText)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 20) {
                // Previous button
                Button {
                    Task {
                        await viewModel.loadPreviousPage()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.canGoToPreviousPage || viewModel.isLoading)
                
                // Page indicator
                Text("Page \(viewModel.currentPage) of \(viewModel.totalPages)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 120)
                
                // Next button
                Button {
                    Task {
                        await viewModel.loadNextPage()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.canGoToNextPage || viewModel.isLoading)
            }
            .padding(.horizontal)
            
            // Loading indicator
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 12)
    }
}
