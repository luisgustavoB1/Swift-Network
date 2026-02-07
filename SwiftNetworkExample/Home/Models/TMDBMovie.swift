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

struct TMDBMovieListResponse: Decodable, Sendable {
    let page: Int
    let results: [TMDBMovie]
    let totalPages: Int?
    let totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct TMDBMovie: Decodable, Sendable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double?

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }
}

extension TMDBMovie {
    /// Full poster URL using `HomeNetworkConfig.posterPathURL`.
    var fullPosterURL: URL? {
        guard let path = posterPath, !path.isEmpty else { return nil }
        let base = HomeNetworkConfig.posterPathURL.hasSuffix("/") ? HomeNetworkConfig.posterPathURL : HomeNetworkConfig.posterPathURL + "/"
        return URL(string: base + path)
    }

    /// Full backdrop URL using `HomeNetworkConfig.backdropPathURL`.
    var fullBackdropURL: URL? {
        guard let path = backdropPath, !path.isEmpty else { return nil }
        let base = HomeNetworkConfig.backdropPathURL.hasSuffix("/") ? HomeNetworkConfig.backdropPathURL : HomeNetworkConfig.backdropPathURL + "/"
        return URL(string: base + path)
    }
}
