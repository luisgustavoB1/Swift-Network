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
import Combine
import SwiftNetwork

/// Default `APIClient` implementation using `NetworkClient` and your `Endpoint` types.
///
/// Subscribes on a background queue so decoding does not block the main thread.
/// Use `.receive(on: DispatchQueue.main)` before updating UI.
public final class URLSessionAPIClient: APIClient, Sendable {
    private let client: NetworkClient

    public init(client: NetworkClient = NetworkClient()) {
        self.client = client
    }

    public func request<E: Endpoint, T: Decodable>(_ endpoint: E, as type: T.Type) -> AnyPublisher<T, Error>
    where E: Sendable, T: Sendable {
        client
            .publisher(endpoint, as: type)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
}
