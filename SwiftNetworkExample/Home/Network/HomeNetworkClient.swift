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
import SwiftNetwork
import SwiftNetworkCombine

/// Dedicated `NetworkClient` for the Home feature, built from `HomeNetworkConfig` (TMDB).
/// Uses `NetworkConfig` for base URL, headers, decoder; separate from the rest of the app.
enum HomeNetworkClient {
    static let shared: NetworkClient = {
        let config = HomeNetworkConfig.networkConfig
        let plugins: [NetworkPlugin] = [
            AuthPlugin(provider: MoviesProvider()),
            LoggerPlugin(level: .verbose)
        ]

        return NetworkClient(
            transport: URLSessionTransport(),
            builder: RequestBuilder(jsonEncoder: config.encoder),
            decoder: config.decoder,
            plugins: plugins
        )
    }()

    /// Combine client for Home (uses shared NetworkClient, subscribes on background).
    static let combine: URLSessionAPIClient = {
        URLSessionAPIClient(client: shared)
    }()
}
