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
import Combine
import SwiftNetwork
import SwiftNetworkCombine
import SwiftNetworkMocks

struct NetworkClientCombineTests {

    struct OkResponse: Decodable {
        let ok: Bool
    }

    struct OkEndpoint: Endpoint {
        var baseURL: URL { URL(string: "https://example.com")! }
        var path: String { "ok" }
        var method: HTTPMethod { .get }
    }

    @Test
    func publisherEmitsValue() async throws {
        var cancellables = Set<AnyCancellable>()
        var mock = MockTransport()

        let url = URL(string: "https://example.com/ok")!
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        let data = #"{"ok":true}"#.data(using: .utf8)!
        mock.register(req, stub: .init(statusCode: 200, data: data))

        let client = NetworkClient(transport: mock)

        let stream = AsyncThrowingStream<OkResponse, Error> { continuation in
            client.publisher(OkEndpoint(), as: OkResponse.self)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.finish(throwing: error)
                        }
                    },
                    receiveValue: { value in
                        continuation.yield(value)
                        continuation.finish()
                    }
                )
                .store(in: &cancellables)
        }

        var received: OkResponse?
        for try await value in stream {
            received = value
        }
        #expect(received?.ok == true)
    }
}
