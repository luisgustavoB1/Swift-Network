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

/// Type-erased wrapper for an `Encodable` value.
///
/// Used internally by `RequestBuilder` to store different `Encodable` body types from `HTTPTask.requestJSON`.
public struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    public init(_ value: Encodable) {
        self._encode = value.encode
    }

    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
