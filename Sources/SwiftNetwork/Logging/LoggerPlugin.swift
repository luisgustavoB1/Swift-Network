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

/// Protocol for logging request/response data. Default implementation is no-op.
public protocol NetworkLogger: Sendable {
    func logRequest(_ request: URLRequest, body: Data?)
    func logResponse(_ request: URLRequest, statusCode: Int, data: Data?, error: Error?)
}

/// No-op logger. Use as default when no logging is needed.
public struct NoOpLogger: NetworkLogger {
    public init() {}
    public func logRequest(_ request: URLRequest, body: Data?) {}
    public func logResponse(_ request: URLRequest, statusCode: Int, data: Data?, error: Error?) {}
}

/// Plugin that logs requests and responses. Useful for debugging; disable or use `.none` in production.
///
/// Sensitive headers (e.g. `Authorization`) are redacted. Response and request bodies are truncated to `maxBodyBytes`.
public struct LoggerPlugin: NetworkPlugin {
    public enum Level: Sendable {
        case none
        case basic
        case verbose
    }

    private let level: Level
    private let redactHeaders: Set<String>
    private let maxBodyBytes: Int

    public init(
        level: Level = .basic,
        redactHeaders: Set<String> = ["Authorization", "Cookie", "Set-Cookie"],
        maxBodyBytes: Int = 2_048
    ) {
        self.level = level
        self.redactHeaders = redactHeaders
        self.maxBodyBytes = maxBodyBytes
    }

    public func prepare(_ request: URLRequest) async throws -> URLRequest {
        guard level != .none else { return request }

        if level == .basic || level == .verbose {
            let method = request.httpMethod ?? "?"
            let url = request.url?.absoluteString ?? "?"
            print("[SwiftNetwork] ➡️ \(method) \(url)")
        }

        if level == .verbose {
            if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
                print("[SwiftNetwork] Headers:")
                for (k, v) in headers {
                    let safeValue = redactHeaders.contains(k) ? "<redacted>" : v
                    print("  \(k): \(safeValue)")
                }
            }
            if let body = request.httpBody, !body.isEmpty {
                print("[SwiftNetwork] Body (\(min(body.count, maxBodyBytes)) bytes): \(prettyBody(body))")
            }
        }

        return request
    }

    public func didReceive(
        _ result: Result<(Data, HTTPURLResponse), Error>,
        for request: URLRequest
    ) async {
        guard level != .none else { return }

        let method = request.httpMethod ?? "?"
        let url = request.url?.absoluteString ?? "?"

        switch result {
        case .success(let (data, response)):
            print("[SwiftNetwork] ✅ \(method) \(url) -> \(response.statusCode) (\(data.count) bytes)")
            if level == .verbose, !data.isEmpty {
                print("[SwiftNetwork] Response (\(min(data.count, maxBodyBytes)) bytes): \(prettyBody(data))")
            }
        case .failure(let error):
            print("[SwiftNetwork] ❌ \(method) \(url) -> \(String(describing: error))")
        }
    }

    private func prettyBody(_ data: Data) -> String {
        let clipped = data.prefix(maxBodyBytes)
        if let json = try? JSONSerialization.jsonObject(with: Data(clipped), options: []),
           let pretty = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
           let text = String(data: pretty, encoding: .utf8) {
            return text
        }
        if let text = String(data: Data(clipped), encoding: .utf8) {
            return text
        }
        return "<\(clipped.count) bytes>"
    }
}
