// swift-tools-version: 6.2
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
//  Author: Luis Gustavo Oliveira Silva — https://luisgustavob1.com/ — b1 tech
//

import PackageDescription

let package = Package(
    name: "SwiftNetwork",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "SwiftNetwork", targets: ["SwiftNetwork"]),
        .library(name: "SwiftNetworkCombine", targets: ["SwiftNetworkCombine"]),
        .library(name: "SwiftNetworkMocks", targets: ["SwiftNetworkMocks"])
    ],
    targets: [
        .target(
            name: "SwiftNetwork",
            path: "Sources/SwiftNetwork",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "SwiftNetworkCombine",
            dependencies: ["SwiftNetwork"],
            path: "Sources/SwiftNetworkCombine"
        ),
        .target(
            name: "SwiftNetworkMocks",
            dependencies: ["SwiftNetwork"],
            path: "Sources/SwiftNetworkMocks"
        ),
        .testTarget(
            name: "SwiftNetworkTests",
            dependencies: ["SwiftNetwork", "SwiftNetworkMocks", "SwiftNetworkCombine"],
            path: "Tests/SwiftNetworkTests",
            resources: [.process("Fixtures")]
        )
    ]
)
