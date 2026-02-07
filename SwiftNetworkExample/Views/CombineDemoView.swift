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
import SwiftNetworkCombine
import Combine

/// Fetches a single post using Combine (publisher).
struct CombineDemoView: View {
    @State private var post: Post?
    @State private var loading = false
    @State private var errorMessage: String?
    @State private var postId = 1
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Stepper("Post ID: \(postId)", value: $postId, in: 1...100)
                    .onChange(of: postId) { _ in loadPost() }
            }
            .padding(.horizontal)
            if loading {
                ProgressView("Loading…")
            } else if let error = errorMessage {
                Text(error).font(.caption).foregroundStyle(.red).padding()
            } else if let post {
                VStack(alignment: .leading, spacing: 8) {
                    Text(post.title).font(.headline)
                    Text(post.body).font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            Spacer()
        }
        .navigationTitle("Combine demo")
        .onAppear { loadPost() }
    }

    private func loadPost() {
        loading = true
        errorMessage = nil
        post = nil
        APIService.combineClient
            .request(JSONPlaceholderAPI.GetPost(id: postId), as: Post.self)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [self] completion in
                    loading = false
                    if case .failure(let error) = completion {
                        errorMessage = error.displayMessage
                    }
                },
                receiveValue: { [self] value in
                    post = value
                }
            )
            .store(in: &cancellables)
    }
}
