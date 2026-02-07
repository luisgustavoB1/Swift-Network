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

/// Fetches and displays posts from JSONPlaceholder using async/await.
struct PostsView: View {
    @State private var posts: [Post] = []
    @State private var loading = false
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if loading {
                ProgressView("Loading posts…")
            } else if let error = errorMessage {
                VStack(spacing: 12) {
                    Text("Error").font(.headline)
                    Text(error).font(.caption).multilineTextAlignment(.center)
                }
                .padding()
            } else {
                List(posts, id: \.id) { post in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.title).font(.headline).lineLimit(2)
                        Text(post.body).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                    }
                }
            }
        }
        .navigationTitle("Posts (async/await)")
        .task { await loadPosts() }
    }

    private func loadPosts() async {
        loading = true
        errorMessage = nil
        defer { loading = false }
        do {
            posts = try await APIService.shared.request(JSONPlaceholderAPI.GetPosts())
        } catch {
            errorMessage = error.displayMessage
        }
    }
}
