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
import SwiftNetwork
import SwiftNetworkMocks

struct RetryPluginTests {

    @Test
    func retryTransportRetriesOnRetryableStatusThenSucceeds() async throws {
        let recorder = AttemptRecorder()

        let base = SequencedTransport { attempt in
            recorder.record(attempt)
            if attempt == 1 {
                return .init(statusCode: 503, data: Data())
            } else {
                let ok = #"{"ok":true}"#.data(using: .utf8)!
                return .init(statusCode: 200, data: ok)
            }
        }

        let retry = RetryTransport(
            base: base,
            policy: .init(maxRetries: 2, baseDelay: 0, jitter: 0, retryOnStatusCodes: [503]),
            sleep: { _ in }
        )

        let client = NetworkClient(transport: retry)

        struct OkResponse: Decodable { let ok: Bool }

        struct OkEndpoint: Endpoint {
            var baseURL: URL { URL(string: "https://example.com")! }
            var path: String { "health" }
            var method: HTTPMethod { .get }
        }

        let response: OkResponse = try await client.request(OkEndpoint())

        #expect(response.ok == true)
        #expect(recorder.attempts == [1, 2])
    }
}

// MARK: - Helpers

private final class AttemptRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private(set) var attempts: [Int] = []

    func record(_ attempt: Int) {
        lock.lock()
        attempts.append(attempt)
        lock.unlock()
    }
}

private struct TransportStub {
    let statusCode: Int
    let data: Data
}

private final class SequencedTransport: NetworkTransport, @unchecked Sendable {
    private let lock = NSLock()
    private var attempt = 0
    private let handler: @Sendable (Int) -> TransportStub

    init(handler: @escaping @Sendable (Int) -> TransportStub) {
        self.handler = handler
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let currentAttempt = nextAttempt()
        let stub = handler(currentAttempt)
        let url = request.url ?? URL(string: "https://example.com")!

        let response = HTTPURLResponse(
            url: url,
            statusCode: stub.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: [:]
        )!

        return (stub.data, response)
    }

    private func nextAttempt() -> Int {
        lock.lock()
        attempt += 1
        let value = attempt
        lock.unlock()
        return value
    }
}
