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

/// Describes the request body or query for an endpoint.
///
/// Use with `Endpoint.task`. The builder sets `Content-Type: application/json` for `.requestJSON`.
public enum HTTPTask: @unchecked Sendable {
    case requestPlain
    case requestQuery([URLQueryItem])
    case requestData(Data)
    case requestJSON(Encodable)
}
