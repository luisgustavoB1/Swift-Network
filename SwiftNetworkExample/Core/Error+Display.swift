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

extension Error {
    /// User-friendly message for UI: uses `NetworkError` (status, backend message) when available.
    var displayMessage: String {
        if let networkError = self as? NetworkError {
            return networkError.displayMessage
        }
        return localizedDescription
    }
}

extension NetworkError {
    /// Short message suitable for alerts and error labels.
    var displayMessage: String {
        switch self {
        case .invalidResponse:
            return "Invalid response from server."
        case .http(let statusCode, let payload, _):
            if let message = payload?.message, !message.isEmpty {
                return message
            }
            return "Request failed (HTTP \(statusCode))."
        case .decoding:
            return "Invalid data from server."
        case .transport:
            return "Network error. Check your connection."
        case .invalidRequest(_):
            return "Invalid request"
        case .cancelled:
            return "cancelled"
        default:
            return "An unexpected error occurred."
        }
    }
}

