# SwiftNetwork

A production-oriented Swift library for HTTP networking with **async/await**, **Combine**, pluggable transport and plugins (auth, logging, retry), and mocks for testing. Distributed via **Swift Package Manager**.

**Author:** [Luis Gustavo Oliveira Silva](https://luisgustavob1.com/) · **b1 tech**

---

## Features

- **Async/await** – First-class `async throws` API on `NetworkClient`.
- **Combine** – Optional `SwiftNetworkCombine` product with `publisher(_:as:)` and `APIClient` protocol.
- **Endpoint-based** – Define requests with the `Endpoint` protocol (baseURL, path, method, headers, body, query).
- **Pluggable** – `NetworkPlugin` for request/response hooks (e.g. `AuthPlugin`, `LoggerPlugin`).
- **Retry** – `RetryTransport` with configurable backoff and status codes.
- **Testable** – `SwiftNetworkMocks` provides `MockTransport`, `MockTokenProvider`, `MockNetworkClient`, and `SequencedMockTransport`.
- **Configurable** – Inject `NetworkTransport`, `RequestBuilder`, `JSONDecoder`/`JSONEncoder`, and plugins.

---

## Requirements

- **Platforms:** iOS 15+, tvOS 15+, macOS 12+
- **Swift:** 6.x (or compatible 5.x)
- **Distribution:** Swift Package Manager (SPM)

---

## Installation

### Swift Package Manager

Add the package to your project’s `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/luisgustavoB1/SwiftNetwork.git", from: "1.0.0")
]
```

Or in **Xcode:** **File → Add Package Dependencies** and enter the repository URL.

**Products:**

| Product              | Description                                      |
|----------------------|--------------------------------------------------|
| `SwiftNetwork`       | Core client, endpoints, plugins, transport       |
| `SwiftNetworkCombine` | Combine `publisher` and `APIClient`           |
| `SwiftNetworkMocks`  | Mocks for unit tests                            |

---

## Quick Start

### 1. Define an endpoint

Conform to the `Endpoint` protocol: `baseURL`, `path`, `method`, and optionally `headers`, `task`, and `timeout`.

```swift
import SwiftNetwork

struct User: Decodable {
    let id: Int
    let name: String
}

enum API {
    struct GetUser: Endpoint {
        var baseURL: URL { URL(string: "https://api.example.com")! }
        var path: String { "/users/me" }
        var method: HTTPMethod { .get }
    }
}
```

The response type is **not** on the endpoint; you specify it when calling the client.

### 2. Perform the request (async/await)

```swift
let client = NetworkClient()

do {
    let user: User = try await client.request(API.GetUser())
    print(user.name)
} catch {
    print("Error:", error)
}
```

Use `request(_:as:)` when the type cannot be inferred (e.g. in Combine or when not assigned to a variable).

### 3. Combine usage

Add the `SwiftNetworkCombine` dependency and use the `publisher` extension:

```swift
import SwiftNetwork
import SwiftNetworkCombine
import Combine

let client = NetworkClient()

client.publisher(API.GetUser(), as: User.self)
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion { print(error) }
        },
        receiveValue: { user in print(user.name) }
    )
    .store(in: &cancellables)
```

Or use the `APIClient` protocol with `URLSessionAPIClient` (subscribes on a background queue):

```swift
import SwiftNetworkCombine

let apiClient: APIClient = URLSessionAPIClient()
apiClient.request(API.GetUser(), as: User.self)
    .receive(on: DispatchQueue.main)
    .sink(receiveCompletion: { _ in }, receiveValue: { user in print(user.name) })
    .store(in: &cancellables)
```

---

## Error handling

Errors are of type `NetworkError`:

| Case | When |
|------|------|
| `invalidResponse` | Response was not an `HTTPURLResponse` |
| `http(statusCode:payload:data)` | Status code outside 200–299 |
| `decoding(Error)` | Response body could not be decoded into the requested type |
| `transport(Error)` | Network or transport failure (e.g. no connection, timeout) |
| `invalidRequest(Error)` | Request building failed (e.g. `RequestBuilderError`) |
| `cancelled` | Request was cancelled (e.g. `URLError.cancelled`) |
| `unknown(Error)` | Other errors |

Convenience accessors on `NetworkError`:

- `statusCode: Int?` – HTTP status (for `.http` only).
- `backendMessage: String?` – Message from decoded error payload (e.g. `HTTPErrorPayload.message`).
- `backendCode: String?` – Backend error code from payload.

Example:

```swift
do {
    let user: User = try await client.request(API.GetUser())
} catch let error as NetworkError {
    switch error {
    case .http(let statusCode, let payload, _):
        print("HTTP \(statusCode)", payload?.message ?? "")
    case .decoding(let underlying):
        print("Decoding failed:", underlying)
    case .transport(let underlying):
        print("Transport failed:", underlying)
    case .cancelled:
        print("Request cancelled")
    default:
        print(error)
    }
}
```

---

## Testing with mocks

Use the **SwiftNetworkMocks** product in your test target.

### MockTransport

Register stubs for requests (no real network):

```swift
import SwiftNetwork
import SwiftNetworkMocks

var transport = MockTransport(rule: .methodAndURL)

let stubData = try JSONEncoder().encode(User(id: 1, name: "Test"))
transport.register(
    URLRequest(url: URL(string: "https://api.example.com/users/me")!),
    stub: .init(statusCode: 200, data: stubData)
)

let client = NetworkClient(transport: transport)
let user: User = try await client.request(API.GetUser())
```

- **`.url`** – Match by URL only.
- **`.methodAndURL`** – Match by method and URL (recommended).

Stub helpers: `MockTransport.Stub.success(data:statusCode:headers:)` and `.failure(statusCode:data:headers:)`.

### SequencedMockTransport

For retries or multiple sequential responses, use `SequencedMockTransport` and enqueue stubs in order.

### MockTokenProvider

Fixed token for tests:

```swift
let provider = MockTokenProvider(token: "fake-token")
let client = NetworkClient(plugins: [AuthPlugin(provider: provider)])
```

### MockNetworkClient

A client backed by `MockTransport` with the same async API:

```swift
var transport = MockTransport()
transport.register(someRequest, stub: .success(data: jsonData))
let mockClient = MockNetworkClient(transport: transport)
let response: MyResponse = try await mockClient.request(MyEndpoint(), as: MyResponse.self)
```

---

## Example app

A minimal demo app is under **SwiftNetworkExample/**.

1. Open the workspace from the repo root:
   ```bash
   open SwiftNetwork.xcworkspace
   ```
2. Select the **SwiftNetworkExample** scheme and run.

The app uses [JSONPlaceholder](https://jsonplaceholder.typicode.com) (no API key) for GET/POST and Combine. It also includes an optional Home section that uses the TMDB API; set `HomeNetworkConfig.apiKey` to your key (do not commit it). See [SwiftNetworkExample/README.md](SwiftNetworkExample/README.md) for details.

---

## Architecture

### Modules and responsibilities

| Module | Responsibility |
|--------|----------------|
| **SwiftNetwork** | Core: `Endpoint`, `NetworkClient`, `NetworkTransport`, `RequestBuilder`, `HTTPMethod`, `HTTPTask`, `NetworkError`, `HTTPErrorPayload`, plugins (`AuthPlugin`, `LoggerPlugin`), `RetryTransport`, `URLSessionTransport`, `NetworkConfig`, logging utilities. |
| **SwiftNetworkCombine** | Combine integration: `NetworkClient.publisher(_:as:)`, `APIClient` protocol, `URLSessionAPIClient`. |
| **SwiftNetworkMocks** | Testing: `MockTransport`, `MockTokenProvider`, `MockNetworkClient`, `SequencedMockTransport`. |

### Source layout (SwiftNetwork)

- **Core/** – `Endpoint`, `NetworkClient`, `NetworkConfig`, `NetworkTransport`
- **HTTP/** – `HTTPMethod`, `HTTPTask`, `HTTPErrorPayload`
- **Request/** – `RequestBuilder`, `RequestBuilderError`, `AnyEncodable`
- **Errors/** – `NetworkError`
- **Logging/** – `LoggerPlugin`, `DebugRedaction`
- **Plugins/** – `NetworkPlugin`, `AuthPlugin`, `RetryPlugin` (including `RetryTransport`)
- **Transport/** – `URLSessionTransport`, `URLSession+HTTPURLResponse`
- **Utils/** – `URLComponents+Query`

Dependencies are injectable: use `NetworkTransport` for the network layer and `NetworkPlugin` for cross-cutting behavior. No circular dependencies between modules.

---

## Code quality: SwiftLint

The project includes a [SwiftLint](https://github.com/realm/SwiftLint) configuration (`.swiftlint.yml`) and a script to run it.

**Install SwiftLint:**

```bash
brew install swiftlint
```

**Run lint:**

```bash
./Scripts/lint.sh
```

This lints `Sources/` and `Tests/`. The config sets line length, function/type body length, cyclomatic complexity, identifier rules, and treats `force_cast`/`force_try` as errors. The Example app is excluded from lint.

---

## Contributing

Contributions are welcome. Please keep the public API stable and avoid breaking changes without a clear migration path. Add tests for new behavior and ensure `swift build` and `swift test` pass.

---

## Author

**Luis Gustavo Oliveira Silva**  
- Website: [https://luisgustavob1.com/](https://luisgustavob1.com/)  
- Company/Brand: b1 tech  

---

## License

This project is licensed under the **Apache License 2.0**. See the [LICENSE](LICENSE) file for the full text.
