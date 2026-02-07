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

/// Errors thrown when building a `URLRequest` from an `Endpoint`.
public enum RequestBuilderError: Error, Sendable {
    case invalidURL
    case invalidBody
}

/// Builds a `URLRequest` from an `Endpoint`: URL (with optional query), method, headers, and body.
public struct RequestBuilder {
    private let jsonEncoder: JSONEncoder

    public init(jsonEncoder: JSONEncoder = JSONEncoder()) {
        self.jsonEncoder = jsonEncoder
    }

    public func build<E: Endpoint>(_ endpoint: E) throws -> URLRequest {
        var url = endpoint.baseURL.appendingPathComponent(endpoint.path)

        if case let .requestQuery(items) = endpoint.task {
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw RequestBuilderError.invalidURL
            }

            let current = components.queryItems ?? []
            components.queryItems = current + items

            guard let finalURL = components.url else {
                throw RequestBuilderError.invalidURL
            }

            url = finalURL
        }

        var request = URLRequest(url: url, timeoutInterval: endpoint.timeout)
        request.httpMethod = endpoint.method.rawValue

        endpoint.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        switch endpoint.task {
        case .requestPlain, .requestQuery:
            break

        case .requestData(let data):
            request.httpBody = data

        case .requestJSON(let encodable):
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try jsonEncoder.encode(AnyEncodable(encodable))
            } catch {
                throw RequestBuilderError.invalidBody
            }
        }

        return request
    }
}

extension RequestBuilder: Sendable {}
