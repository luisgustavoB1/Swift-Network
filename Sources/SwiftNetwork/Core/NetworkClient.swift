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

/// HTTP client that builds requests from `Endpoint` values, runs them through plugins, and decodes JSON responses.
///
/// Use the default initializer for a standard setup. Inject a custom `NetworkTransport` for testing or retry behavior.
/// Add `NetworkPlugin` values (e.g. `AuthPlugin`, `LoggerPlugin`) to modify requests or observe results.
///
/// Thread safety: `NetworkClient` is `Sendable` and can be shared across concurrency domains.
public struct NetworkClient {
    private let transport: NetworkTransport
    private let builder: RequestBuilder
    private let decoder: JSONDecoder
    private let plugins: [NetworkPlugin]

    public init(
        transport: NetworkTransport = URLSessionTransport(),
        builder: RequestBuilder = RequestBuilder(),
        decoder: JSONDecoder = JSONDecoder(),
        plugins: [NetworkPlugin] = []
    ) {
        self.transport = transport
        self.builder = builder
        self.decoder = decoder
        self.plugins = plugins
    }

    public func request<E: Endpoint, T: Decodable>(_ endpoint: E) async throws -> T {
        try await request(endpoint, as: T.self)
    }

    public func request<E: Endpoint, T: Decodable>(_ endpoint: E, as type: T.Type) async throws -> T {
        let request: URLRequest
        do {
            request = try builder.build(endpoint)
        } catch {
            let invalidRequest = NetworkError.invalidRequest(error)
            await notifyPlugins(result: .failure(invalidRequest), request: URLRequest(url: endpoint.baseURL))
            throw invalidRequest
        }

        var mutableRequest = request
        for plugin in plugins {
            mutableRequest = try await plugin.prepare(mutableRequest)
        }

        do {
            let (data, response) = try await transport.data(for: mutableRequest)

            guard (200...299).contains(response.statusCode) else {
                let payload = try? decoder.decode(HTTPErrorPayload.self, from: data)
                let error = NetworkError.http(
                    statusCode: response.statusCode,
                    payload: payload,
                    data: data
                )
                await notifyPlugins(result: .failure(error), request: mutableRequest)
                throw error
            }

            do {
                let decoded = try decoder.decode(T.self, from: data)
                await notifyPlugins(result: .success((data, response)), request: mutableRequest)
                return decoded
            } catch {
                let decodingError = NetworkError.decoding(error)
                await notifyPlugins(result: .failure(decodingError), request: mutableRequest)
                throw decodingError
            }

        } catch let error as NetworkError {
            await notifyPlugins(result: .failure(error), request: mutableRequest)
            throw error
        } catch let error as URLError where error.code == .cancelled {
            let cancelledError = NetworkError.cancelled
            await notifyPlugins(result: .failure(cancelledError), request: mutableRequest)
            throw cancelledError
        } catch {
            let transportError = NetworkError.transport(error)
            await notifyPlugins(result: .failure(transportError), request: mutableRequest)
            throw transportError
        }
    }

    private func notifyPlugins(
        result: Result<(Data, HTTPURLResponse), Error>,
        request: URLRequest
    ) async {
        for plugin in plugins {
            await plugin.didReceive(result, for: request)
        }
    }
}

extension NetworkClient: Sendable {}
