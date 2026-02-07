//
//  Copyright 2025 Luis Gustavo
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI
import SwiftNetwork

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.sections.isEmpty {
                ProgressView("Loading…")
            } else if let error = viewModel.errorMessage, viewModel.sections.isEmpty {
                VStack(spacing: 12) {
                    Text("Error").font(.headline)
                    Text(error).font(.caption).multilineTextAlignment(.center)
                    if HomeNetworkConfig.apiKey == nil || (HomeNetworkConfig.apiKey?.isEmpty == true) {
                        Text("Set HomeNetworkConfig.apiKey for TMDB.").font(.caption2).foregroundStyle(.secondary)
                    }
                }
                .padding()
            } else {
                List {
                    ForEach(viewModel.sections, id: \.endpoint) { section in
                        Section(header: Text(section.endpoint.sectionName)) {
                            ForEach(section.items, id: \.id) { movie in
                                MovieRow(movie: movie)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Home (TMDB)")
        .onAppear { viewModel.loadAllSections() }
    }
}

private struct MovieRow: View {
    let movie: TMDBMovie

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let url = movie.fullPosterURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    case .failure:
                        Color.gray.opacity(0.3)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(width: 60, height: 90)
                .clipped()
                .cornerRadius(6)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title).font(.headline).lineLimit(2)
                if let overview = movie.overview, !overview.isEmpty {
                    Text(overview).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                }
                if let date = movie.releaseDate {
                    Text(date).font(.caption2).foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
