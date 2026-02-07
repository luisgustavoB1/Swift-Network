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
import SwiftNetworkCombine

/// Shared client configured with logging. Use for async/await or Combine.
final class APIService: Sendable {
    /// Client with LoggerPlugin (basic) so we see requests in the console.
    static let shared: NetworkClient = {
        NetworkClient(
            transport: URLSessionTransport(),
            builder: RequestBuilder(),
            decoder: JSONDecoder(),
            plugins: [LoggerPlugin(level: .basic)]
        )
    }()

    /// Combine-based client (background queue). Use for reactive flows.
    static let combineClient: URLSessionAPIClient = {
        URLSessionAPIClient(client: shared)
    }()
}
