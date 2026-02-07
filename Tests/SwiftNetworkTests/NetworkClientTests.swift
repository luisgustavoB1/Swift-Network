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
import Testing
@testable import SwiftNetwork
import SwiftNetworkMocks

struct NetworkClientTests {

    struct MoviesResponse: Decodable {
        let page: Int
        let results: [Movie]
    }

    struct Movie: Decodable {
        let id: Int
        let title: String
    }

    enum TestEndpoint: Endpoint {
        case success
        case failure

        var baseURL: URL { URL(string: "https://example.com")! }

        var path: String {
            switch self {
            case .success: return "movies/success"
            case .failure: return "movies/failure"
            }
        }

        var method: HTTPMethod { .get }
        var headers: [String: String] { [:] }
        var task: HTTPTask { .requestPlain }
    }

    @Test
    func requestSuccessDecodesResponse() async throws {
        var mock = MockTransport()

        let url = URL(string: "https://example.com/movies/success")!
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        let data = try loadFixture("success.json")
        mock.register(req, stub: .init(statusCode: 200, data: data))

        let client = NetworkClient(transport: mock)

        let response: MoviesResponse = try await client.request(TestEndpoint.success)

        #expect(response.page == 1)
        #expect(response.results.count == 2)
        #expect(response.results.first?.id == 101)
    }

    @Test
    func requestFailureMapsHTTPErrorWithPayload() async throws {
        var mock = MockTransport()

        let url = URL(string: "https://example.com/movies/failure")!
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        let data = try loadFixture("error.json")
        mock.register(req, stub: .init(statusCode: 401, data: data))

        let client = NetworkClient(transport: mock)

        do {
            _ = try await client.request(TestEndpoint.failure, as: MoviesResponse.self)
            Issue.record("Expected error but request succeeded")
        } catch let error as NetworkError {
            switch error {
            case .http(let statusCode, let payload, _):
                #expect(statusCode == 401)
                #expect(payload?.message == "Invalid API key")
                #expect(payload?.code == "AUTH_INVALID")
            default:
                Issue.record("Expected http error, got \(error)")
            }
        }
    }

    private func loadFixture(_ name: String) throws -> Data {
        let url = try #require(Bundle.module.url(forResource: name, withExtension: nil))
        return try Data(contentsOf: url)
    }
}
