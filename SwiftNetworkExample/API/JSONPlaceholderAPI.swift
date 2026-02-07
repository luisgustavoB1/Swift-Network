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

import Foundation
import SwiftNetwork

// MARK: - Models (match JSONPlaceholder response shape)

struct Post: Decodable, Sendable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

struct User: Decodable, Sendable {
    let id: Int
    let name: String
    let username: String
    let email: String
}

struct CreatePostBody: Encodable, Sendable {
    let title: String
    let body: String
    let userId: Int
}

struct CreatePostResponse: Decodable, Sendable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}

// MARK: - Endpoints (real API: https://jsonplaceholder.typicode.com)

enum JSONPlaceholderAPI {
    private static let baseURL = URL(string: "https://jsonplaceholder.typicode.com")!

    /// GET /posts — list all posts
    struct GetPosts: Endpoint {
        var baseURL: URL { JSONPlaceholderAPI.baseURL }
        var path: String { "/posts" }
        var method: HTTPMethod { .get }
    }

    /// GET /posts/:id — single post
    struct GetPost: Endpoint {
        let id: Int
        var baseURL: URL { JSONPlaceholderAPI.baseURL }
        var path: String { "/posts/\(id)" }
        var method: HTTPMethod { .get }
    }

    /// GET /users — list all users
    struct GetUsers: Endpoint {
        var baseURL: URL { JSONPlaceholderAPI.baseURL }
        var path: String { "/users" }
        var method: HTTPMethod { .get }
    }

    /// POST /posts — create a post (API returns 201 and echoes the body with an id)
    struct CreatePost: Endpoint {
        let title: String
        let body: String
        let userId: Int
        var baseURL: URL { JSONPlaceholderAPI.baseURL }
        var path: String { "/posts" }
        var method: HTTPMethod { .post }
        var task: HTTPTask { .requestJSON(CreatePostBody(title: title, body: body, userId: userId)) }
    }
}
