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

/// Home screen list endpoints (TMDB API). Uses `HomeNetworkConfig` for base URL and auth.
enum HomeEndpoint: Hashable, Sendable {
    case nowPlaying(page: Int)
    case upcoming(page: Int)
    case popular(page: Int)
    case topRated(page: Int)
}

extension HomeEndpoint: Endpoint {
    var baseURL: URL {
        guard let url = URL(string: HomeNetworkConfig.baseURL) else {
            fatalError("Base URL isn't valid.")
        }
        return url
    }

    var path: String {
        switch self {
        case .popular:
            return "/movie/popular"
        case .topRated:
            return "/movie/top_rated"
        case .upcoming:
            return "/movie/upcoming"
        case .nowPlaying:
            return "/movie/now_playing"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var task: HTTPTask {
        let page: Int
        switch self {
        case .nowPlaying(let p), .upcoming(let p), .popular(let p), .topRated(let p):
            page = p
        }
        var items = [URLQueryItem(name: "page", value: String(page))]
        if #available(iOS 16, *) {
            if let languageCode = Locale.current.language.languageCode?.identifier {
                items.append(URLQueryItem(name: "language", value: languageCode))
            }
        } else {
            // Fallback on earlier versions
        }
        return .requestQuery(items)
    }

    /// Localized section title for UI.
    var sectionName: String {
        switch self {
        case .popular:
            return NSLocalizedString("Popular", comment: "Home section")
        case .topRated:
            return NSLocalizedString("Top Rated", comment: "Home section")
        case .upcoming:
            return NSLocalizedString("Upcoming", comment: "Home section")
        case .nowPlaying:
            return NSLocalizedString("Now Playing", comment: "Home section")
        }
    }
}
