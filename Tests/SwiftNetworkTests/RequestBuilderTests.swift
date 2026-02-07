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
import Testing
@testable import SwiftNetwork

struct RequestBuilderTests {

    struct QueryEndpoint: Endpoint {
        let baseURL: URL
        let path: String
        let method: HTTPMethod = .get
        let headers: [String: String] = ["X-Test": "1"]
        let task: HTTPTask
        let timeout: TimeInterval = 10
    }

    struct JSONBody: Encodable, Decodable, Equatable {
        let name: String
        let age: Int
    }

    struct JSONEndpoint: Endpoint {
        let baseURL: URL
        let path: String
        let method: HTTPMethod = .post
        let headers: [String: String] = [:]
        let task: HTTPTask
        let timeout: TimeInterval = 10
    }

    @Test
    func buildAppendsQueryItemsAndHeaders() throws {
        let builder = RequestBuilder()

        let endpoint = QueryEndpoint(
            baseURL: URL(string: "https://example.com")!,
            path: "search",
            task: .requestQuery([
                .init(name: "q", value: "swift"),
                .init(name: "page", value: "1")
            ])
        )

        let request = try builder.build(endpoint)

        #expect(request.httpMethod == "GET")
        #expect(request.value(forHTTPHeaderField: "X-Test") == "1")

        let url = try #require(request.url)
        let comps = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let items = comps.queryItems ?? []

        #expect(items.contains(.init(name: "q", value: "swift")))
        #expect(items.contains(.init(name: "page", value: "1")))
    }

    @Test
    func buildSetsJSONBodyAndContentType() throws {
        let builder = RequestBuilder()

        let body = JSONBody(name: "Luis", age: 25)

        let endpoint = JSONEndpoint(
            baseURL: URL(string: "https://example.com")!,
            path: "users",
            task: .requestJSON(body)
        )

        let request = try builder.build(endpoint)

        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

        let data = try #require(request.httpBody)
        let decoded = try JSONDecoder().decode(JSONBody.self, from: data)

        #expect(decoded == body)
    }
}
