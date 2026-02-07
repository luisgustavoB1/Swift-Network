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

final class HomeViewModel: ObservableObject {
    @Published private(set) var sections: [(endpoint: HomeEndpoint, items: [TMDBMovie])] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: HomeServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(service: HomeServiceProtocol = HomeService()) {
        self.service = service
    }

    func loadAllSections() {
        isLoading = true
        errorMessage = nil
        sections = []

        let endpoints: [HomeEndpoint] = [
            .popular(page: 1),
            .topRated(page: 1),
            .upcoming(page: 1),
            .nowPlaying(page: 1)
        ]

        let publishers = endpoints.map { service.fetchMovies(endpointType: $0) }

        Publishers.MergeMany(publishers)
            .collect(publishers.count)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.displayMessage
                }
            } receiveValue: { [weak self] results in
                self?.isLoading = false
                self?.sections = results
                    .map { ($0.1, $0.0.results) }
                    .sorted { $0.endpoint.sectionName < $1.endpoint.sectionName }
            }
            .store(in: &cancellables)
    }

    func loadSection(_ endpoint: HomeEndpoint) {
        isLoading = true
        errorMessage = nil

        service.fetchMovies(endpointType: endpoint)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.displayMessage
                }
            } receiveValue: { [weak self] response, endpointType in
                self?.isLoading = false
                if let idx = self?.sections.firstIndex(where: { $0.endpoint == endpointType }) {
                    self?.sections[idx].items = response.results
                } else {
                    self?.sections.append((endpointType, response.results))
                }
            }
            .store(in: &cancellables)
    }
}
