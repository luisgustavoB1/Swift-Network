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

/// Fetches and displays users from JSONPlaceholder (async/await).
struct UsersView: View {
    @State private var users: [User] = []
    @State private var loading = false
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if loading {
                ProgressView("Loading users…")
            } else if let error = errorMessage {
                VStack(spacing: 12) {
                    Text("Error").font(.headline)
                    Text(error).font(.caption).multilineTextAlignment(.center)
                }
                .padding()
            } else {
                List(users, id: \.id) { user in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.name).font(.headline)
                        Text(user.email).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Users")
        .task { await loadUsers() }
    }

    private func loadUsers() async {
        loading = true
        errorMessage = nil
        defer { loading = false }
        do {
            users = try await APIService.shared.request(JSONPlaceholderAPI.GetUsers())
        } catch {
            errorMessage = error.displayMessage
        }
    }
}
