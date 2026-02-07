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

/// Supplies an authentication token for each request.
/// Used by `AuthPlugin` to set an HTTP header (e.g. `Authorization: Bearer <token>`).
public protocol TokenProvider: Sendable {
    func token() async -> String?
}

/// Plugin that adds an authentication header to every request using a `TokenProvider`.
///
/// Default header is `Authorization: Bearer <token>`. Override `headerField` and `prefix` for custom schemes.
/// If `token()` returns `nil` or empty, no header is set.
public struct AuthPlugin: NetworkPlugin {
    private let provider: TokenProvider
    private let headerField: String
    private let prefix: String

    public init(
        provider: TokenProvider,
        headerField: String = "Authorization",
        prefix: String = "Bearer"
    ) {
        self.provider = provider
        self.headerField = headerField
        self.prefix = prefix
    }

    public func prepare(_ request: URLRequest) async throws -> URLRequest {
        var req = request
        if let token = await provider.token(), !token.isEmpty {
            req.setValue("\(prefix) \(token)", forHTTPHeaderField: headerField)
        }
        return req
    }
}
