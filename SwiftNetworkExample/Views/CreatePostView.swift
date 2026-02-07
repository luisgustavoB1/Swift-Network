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

/// POST example: creates a post via JSONPlaceholder (async/await).
struct CreatePostView: View {
    @State private var title = ""
    @State private var bodyText = ""
    @State private var submitting = false
    @State private var result: String?
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("New post") {
                TextField("Title", text: $title)
                TextField("Body", text: $bodyText)
                    .lineLimit(6)
            }
            Section {
                Button("Create post") {
                    Task { await createPost() }
                }
                .disabled(title.isEmpty || bodyText.isEmpty || submitting)
            }
            if let result {
                Section("Result") {
                    Text(result).font(.caption)
                }
            }
            if let error = errorMessage {
                Section("Error") {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("POST /posts")
        .onTapGesture { hideKeyboard() }
    }

    private func createPost() async {
        submitting = true
        result = nil
        errorMessage = nil
        defer { submitting = false }
        do {
            let response: CreatePostResponse = try await APIService.shared.request(
                JSONPlaceholderAPI.CreatePost(title: title, body: bodyText, userId: 1)
            )
            result = "Created post id: \(response.id)"
        } catch {
            errorMessage = error.displayMessage
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
