import XCTest
@testable import HTTPClient

struct Empty: Decodable {
  let url: String
}

final class http_clientTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
  
    func testRequest() async throws {
      let client = Client(
        base: "httpbin.org",
        middlewares: [ClientLogger()]
      )

      let request: Empty = try await client.request(.get, "/get")

      XCTAssertEqual(request.url, "https://httpbin.org/get")
    }
}
