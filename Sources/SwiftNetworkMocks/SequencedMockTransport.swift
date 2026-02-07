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

/// Transport that returns responses from a queue in order. Use for testing retries or multiple sequential requests.
///
/// Register stubs in order; each request consumes the next stub. If the queue is empty, throws.
public final class SequencedMockTransport: NetworkTransport, @unchecked Sendable {
    private let lock = NSLock()
    private var queue: [MockTransport.Stub] = []

    public init(stubs: [MockTransport.Stub] = []) {
        self.queue = stubs
    }

    public func enqueue(_ stub: MockTransport.Stub) {
        lock.lock()
        queue.append(stub)
        lock.unlock()
    }

    public func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let stub: MockTransport.Stub? = lock.withLock {
            guard !queue.isEmpty else { return nil }
            return queue.removeFirst()
        }

        guard let stub else {
            throw NetworkError.transport(NSError(
                domain: "SwiftNetworkMocks",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No stub in queue for request"]
            ))
        }

        let url = request.url ?? URL(string: "https://example.com")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: stub.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: stub.headers
        )!
        return (stub.data, response)
    }
}

private extension NSLock {
    func withLock<T>(_ body: () -> T) -> T {
        lock()
        defer { unlock() }
        return body()
    }
}
