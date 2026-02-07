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

private final class PromiseHolder<T>: @unchecked Sendable {
    let fulfill: (Result<T, Error>) -> Void
    init(_ fulfill: @escaping (Result<T, Error>) -> Void) {
        self.fulfill = fulfill
    }
}

public extension NetworkClient {
    /// Returns a Combine publisher that performs the request when subscribed (cold).
    ///
    /// Use with `sink`, `flatMap`, or other Combine operators. Switch to the main scheduler for UI updates.
    func publisher<E: Endpoint, T: Decodable>(_ endpoint: E, as type: T.Type) -> AnyPublisher<T, Error>
    where E: Sendable, T: Sendable {
        let client = self
        return Deferred {
            Future { promise in
                let holder = PromiseHolder<T>(promise)
                Task {
                    do {
                        let response = try await client.request(endpoint, as: type)
                        holder.fulfill(.success(response))
                    } catch {
                        holder.fulfill(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
