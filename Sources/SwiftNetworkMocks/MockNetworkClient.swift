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

/// A `NetworkClient` backed by `MockTransport` for testing. Exposes the same async API so you can swap the real client.
///
/// Build with `MockNetworkClient(transport: mockTransport)` and register stubs on the transport.
public struct MockNetworkClient {
    private let client: NetworkClient

    public init(
        transport: MockTransport,
        builder: RequestBuilder = RequestBuilder(),
        decoder: JSONDecoder = JSONDecoder(),
        plugins: [NetworkPlugin] = []
    ) {
        self.client = NetworkClient(
            transport: transport,
            builder: builder,
            decoder: decoder,
            plugins: plugins
        )
    }

    public func request<E: Endpoint, T: Decodable>(_ endpoint: E) async throws -> T {
        try await client.request(endpoint, as: T.self)
    }

    public func request<E: Endpoint, T: Decodable>(_ endpoint: E, as type: T.Type) async throws -> T {
        try await client.request(endpoint, as: type)
    }
}
