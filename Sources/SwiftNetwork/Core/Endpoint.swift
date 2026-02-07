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

/// Describes an API endpoint: URL, method, optional headers, and body/query.
///
/// Conform your request types to this protocol and use them with `NetworkClient.request(_:)`
/// or `NetworkClient.publisher(_:)`. The response type is chosen at the call site.
///
/// Best practices: prefer value types; use `baseURL` + `path` without trailing slashes in `path`.
public protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var task: HTTPTask { get }
    var timeout: TimeInterval { get }
}

public extension Endpoint {
    var headers: [String: String] { [:] }
    var task: HTTPTask { .requestPlain }
    var timeout: TimeInterval { 30 }
}
