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

/// Errors produced by `NetworkClient` when a request fails.
///
/// Use `statusCode`, `backendMessage`, and `backendCode` for HTTP errors when your API returns
/// a structured error body.
public enum NetworkError: Error, Sendable {
    case invalidResponse
    case http(statusCode: Int, payload: HTTPErrorPayload?, data: Data)
    case decoding(Error)
    case transport(Error)
    case invalidRequest(Error)
    case cancelled
    case unknown(Error)
}

public extension NetworkError {
    var statusCode: Int? {
        switch self {
        case .http(let code, _, _): return code
        default: return nil
        }
    }

    var backendMessage: String? {
        switch self {
        case .http(_, let payload, _): return payload?.message
        default: return nil
        }
    }

    var backendCode: String? {
        switch self {
        case .http(_, let payload, _): return payload?.code
        default: return nil
        }
    }
}
