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

struct NetworkErrorTests {

    @Test
    func httpErrorConvenienceAccessors() {
        let payload = HTTPErrorPayload(message: "Bad request", code: "ERR_400")
        let error = NetworkError.http(statusCode: 400, payload: payload, data: Data())

        #expect(error.statusCode == 400)
        #expect(error.backendMessage == "Bad request")
        #expect(error.backendCode == "ERR_400")
    }

    @Test
    func nonHTTPErrorReturnsNilAccessors() {
        let error = NetworkError.transport(NSError(domain: "test", code: -1, userInfo: nil))

        #expect(error.statusCode == nil)
        #expect(error.backendMessage == nil)
        #expect(error.backendCode == nil)
    }
}
