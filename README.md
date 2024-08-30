
# Swift HTTP Client

## Install

Install dependency

```
dependencies: [
    .package(url: "https://github.com/tikiram/swift-http-client.git", from: "1.0.1")
]
```

Add the dependency to the target

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


### Middlewares

E.g.

```swift
class ClientAppAuth: Client.Middleware {

  private let appAuth: AppAuth

  init(_ appAuth: AppAuth) {
    self.appAuth = appAuth
  }

  func request(request: inout HTTPRequest, payloadData: Data?, next: Client.NextFn)
    async throws -> (Data, HTTPResponse)
  {
    let accessToken = try await appAuth.getAccessToken()
    let authorization = "Bearer \(accessToken)"
    request.headerFields[.authorization] = authorization
    return try await next(&request, payloadData)
  }
}
```