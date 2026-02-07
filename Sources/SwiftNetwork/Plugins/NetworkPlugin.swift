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

/// Hook into the request lifecycle: modify the request before it is sent and observe the result after.
///
/// Plugins are applied in order. Use `prepare` to add headers (e.g. auth), log the request, or mutate the URL.
/// Use `didReceive` to log the response, report metrics, or refresh tokens on 401.
public protocol NetworkPlugin: Sendable {
    func prepare(_ request: URLRequest) async throws -> URLRequest
    func didReceive(
        _ result: Result<(Data, HTTPURLResponse), Error>,
        for request: URLRequest
    ) async
}

public extension NetworkPlugin {
    func prepare(_ request: URLRequest) async throws -> URLRequest { request }
    func didReceive(
        _ result: Result<(Data, HTTPURLResponse), Error>,
        for request: URLRequest
    ) async { }
}
