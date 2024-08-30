
# Swift HTTP Client

## Install

Install dependency

```
dependencies: [
    .package(url: "https://github.com/tikiram/swift-http-client.git", from: "1.0.1")
]
```

Add the dependency to target

```
dependencies: [
  .product(name: "HTTPClient", package: "swift-http-client"),
]
```

## Usage

```swift
let client = Client(
      base: "api.example.com",
      middlewares: [
        ClientLogger(),
        ClientErrorHandler(),
      ]
    )

try await client.request(.get, "/users")

```