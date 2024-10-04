
# Swift HTTP Client

## Install

Install the dependency

```
dependencies: [
    .package(url: "https://github.com/tikiram/swift-http-client.git", from: "1.0.1")
]
```

Add the dependency to the target

```
.target(
    name: "EquanimousoftAuth", dependencies: [
      .product(name: "HTTPClient", package: "swift-http-client"),
    ]),
```

## Usage

```swift
import HTTPClient

let client = HTTPClient(
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
import HTTPClient

class ClientAppAuth: HTTPClient.Middleware {

  private let appAuth: AppAuth

  init(_ appAuth: AppAuth) {
    self.appAuth = appAuth
  }

  func request(request: inout HTTPRequest, payloadData: Data?, next: NextFn)
    async throws -> (Data, HTTPResponse)
  {
    let accessToken = try await appAuth.getAccessToken()
    let authorization = "Bearer \(accessToken)"
    request.headerFields[.authorization] = authorization
    return try await next(&request, payloadData)
  }
}
```
