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

/// Configuration for retry behavior: how many retries, delay, and which status codes trigger a retry.
public struct RetryPolicy: Sendable {
    public let maxRetries: Int
    public let baseDelay: TimeInterval
    public let jitter: TimeInterval
    public let retryOnStatusCodes: Set<Int>

    public init(
        maxRetries: Int = 2,
        baseDelay: TimeInterval = 0.3,
        jitter: TimeInterval = 0.1,
        retryOnStatusCodes: Set<Int> = [408, 429, 500, 502, 503, 504]
    ) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.jitter = jitter
        self.retryOnStatusCodes = retryOnStatusCodes
    }
}

/// Wraps another transport and retries failed requests with exponential backoff.
///
/// Retries on transport errors and on HTTP status codes in `RetryPolicy.retryOnStatusCodes`.
public struct RetryTransport: NetworkTransport, @unchecked Sendable {
    private let base: NetworkTransport
    private let policy: RetryPolicy
    private let sleep: (UInt64) async -> Void

    public init(
        base: NetworkTransport,
        policy: RetryPolicy = RetryPolicy(),
        sleep: @escaping (UInt64) async -> Void = { ns in try? await Task.sleep(nanoseconds: ns) }
    ) {
        self.base = base
        self.policy = policy
        self.sleep = sleep
    }

    public func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        var attempt = 0

        while true {
            do {
                let (data, response) = try await base.data(for: request)

                if shouldRetry(statusCode: response.statusCode), attempt < policy.maxRetries {
                    attempt += 1
                    let delay = backoffDelay(attempt: attempt)
                    await sleep(UInt64(delay * 1_000_000_000))
                    continue
                }

                return (data, response)

            } catch {
                if attempt < policy.maxRetries {
                    attempt += 1
                    let delay = backoffDelay(attempt: attempt)
                    await sleep(UInt64(delay * 1_000_000_000))
                    continue
                }

                if let e = error as? NetworkError { throw e }
                throw NetworkError.transport(error)
            }
        }
    }

    private func shouldRetry(statusCode: Int) -> Bool {
        policy.retryOnStatusCodes.contains(statusCode)
    }

    private func backoffDelay(attempt: Int) -> TimeInterval {
        let exp = pow(2.0, Double(max(0, attempt - 1)))
        let base = policy.baseDelay * exp
        let jitter = Double.random(in: 0...policy.jitter)
        return base + jitter
    }
}
