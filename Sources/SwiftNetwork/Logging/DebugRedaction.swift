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

/// Utilities for redacting sensitive data in debug output (e.g. headers and body).
public enum DebugRedaction {
    public static let defaultSensitiveHeaders: Set<String> = [
        "Authorization",
        "Cookie",
        "Set-Cookie",
        "X-Api-Key",
        "X-API-Key",
        "Api-Key",
        "API-Key"
    ]

    public static func redactHeaders(
        _ headers: [String: String],
        sensitive: Set<String> = defaultSensitiveHeaders
    ) -> [String: String] {
        var result: [String: String] = [:]
        result.reserveCapacity(headers.count)
        for (key, value) in headers {
            result[key] = sensitive.contains(key) ? "<redacted>" : value
        }
        return result
    }

    public static func redactText(_ text: String) -> String {
        let patterns: [(pattern: String, replacement: String)] = [
            (#"(Authorization:\s*)(.+)"#, "$1<redacted>"),
            (#"(Bearer\s+)([A-Za-z0-9\-\._~\+\/]+=*)"#, "$1<redacted>"),
            (#"(token\"?\s*:\s*\")([^\"]+)(\")"#, "$1<redacted>$3")
        ]
        var redacted = text
        for item in patterns {
            if let regex = try? NSRegularExpression(pattern: item.pattern, options: [.caseInsensitive]) {
                let range = NSRange(redacted.startIndex..<redacted.endIndex, in: redacted)
                redacted = regex.stringByReplacingMatches(
                    in: redacted,
                    options: [],
                    range: range,
                    withTemplate: item.replacement
                )
            }
        }
        return redacted
    }

    public static func safeBodyString(_ data: Data, maxBytes: Int = 2_048) -> String {
        let clipped = data.prefix(maxBytes)
        if clipped.isEmpty { return "" }
        if let obj = try? JSONSerialization.jsonObject(with: Data(clipped), options: []),
           let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
           let text = String(data: pretty, encoding: .utf8) {
            return redactText(text)
        }
        if let text = String(data: Data(clipped), encoding: .utf8) {
            return redactText(text)
        }
        return "<\(clipped.count) bytes>"
    }
}
