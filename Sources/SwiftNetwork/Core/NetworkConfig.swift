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

/// Central configuration for base URL, default headers, timeout, and JSON coding.
///
/// Use for shared settings (e.g. from environment). Endpoints can read from config for `baseURL` and `headers`.
/// The library does not automatically apply `NetworkConfig` to `NetworkClient`; it is provided for convenience.
public struct NetworkConfig: Sendable {
    public var baseURL: URL?
    public var defaultHeaders: [String: String]
    public var timeout: TimeInterval
    public var encoder: JSONEncoder
    public var decoder: JSONDecoder

    public init(
        baseURL: URL? = nil,
        defaultHeaders: [String: String] = [:],
        timeout: TimeInterval = 30,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.timeout = timeout
        self.encoder = encoder
        self.decoder = decoder
    }
}

public extension NetworkConfig {
    static var `default`: NetworkConfig { NetworkConfig() }
}
