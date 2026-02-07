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

/// Network configuration for the Home feature (TMDB API).
/// Uses SwiftNetwork's `NetworkConfig` for client settings and adds TMDB-specific image base URLs.
enum HomeNetworkConfig {
    static let baseURL = "https://api.themoviedb.org/3"
    static var backdropPathURL = "https://image.tmdb.org/t/p/original/"
    static var posterPathURL = "https://image.tmdb.org/t/p/w500/"

    /// TMDB API key (v3 auth). Get one at https://www.themoviedb.org/settings/api
    /// Read from Info.plist key `TMDB_API_KEY`. Do not commit real keys.
    static var apiKey: String? {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String, !key.isEmpty else {
            return nil
        }
        return key
    }

    /// Builds a `NetworkConfig` for the Home client: base URL, timeout, decoder.
    /// Auth is applied by `AuthPlugin(provider: MoviesProvider())` in `HomeNetworkClient`, not here.
    static var networkConfig: NetworkConfig {
        NetworkConfig(
            baseURL: URL(string: baseURL)
        )
    }
}
