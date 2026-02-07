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

/// Transport that returns predefined responses without hitting the network. Use in unit tests.
///
/// Register stubs with `register(_:stub:)` for specific requests. Match by URL or method+URL.
/// If no stub matches, the transport throws. Thread-safe for concurrent requests.
public struct MockTransport: NetworkTransport, @unchecked Sendable {
    public struct Stub: Sendable {
        public let statusCode: Int
        public let headers: [String: String]
        public let data: Data

        public init(statusCode: Int, headers: [String: String] = [:], data: Data) {
            self.statusCode = statusCode
            self.headers = headers
            self.data = data
        }

        /// Success stub with optional JSON data.
        public static func success(
            data: Data = Data(),
            statusCode: Int = 200,
            headers: [String: String] = [:]
        ) -> Stub {
            Stub(statusCode: statusCode, headers: headers, data: data)
        }

        /// Failure stub (non-2xx). For transport-level failures use a sequenced transport or throw in a custom transport.
        public static func failure(
            statusCode: Int,
            data: Data = Data(),
            headers: [String: String] = [:]
        ) -> Stub {
            Stub(statusCode: statusCode, headers: headers, data: data)
        }
    }

    public enum MatchRule: Sendable {
        case url
        case methodAndURL
    }

    private let rule: MatchRule
    private var stubs: [String: Stub]
    private let queue = DispatchQueue(label: "SwiftNetworkMocks.MockTransport.lock")

    public init(rule: MatchRule = .methodAndURL, stubs: [String: Stub] = [:]) {
        self.rule = rule
        self.stubs = stubs
    }

    public mutating func register(_ request: URLRequest, stub: Stub) {
        let key = makeKey(for: request)
        queue.sync { stubs[key] = stub }
    }

    public func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let key = makeKey(for: request)
        let stub: Stub? = queue.sync { stubs[key] }

        guard let stub else {
            throw NetworkError.transport(NSError(
                domain: "SwiftNetworkMocks",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No stub registered for request: \(key)"]
            ))
        }

        guard let url = request.url else {
            throw NetworkError.invalidResponse
        }

        let response = HTTPURLResponse(
            url: url,
            statusCode: stub.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: stub.headers
        )!

        return (stub.data, response)
    }

    private func makeKey(for request: URLRequest) -> String {
        let urlString = request.url?.absoluteString ?? "<nil-url>"
        switch rule {
        case .url: return urlString
        case .methodAndURL:
            let method = request.httpMethod ?? "<nil-method>"
            return "\(method) \(urlString)"
        }
    }
}
