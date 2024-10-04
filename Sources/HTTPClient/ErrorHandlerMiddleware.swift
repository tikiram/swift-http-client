import Foundation
import HTTPTypes

final public class ErrorHandlerMiddleware: HTTPClient.Middleware {

  public init() {
  }

  public func request(request: inout HTTPRequest, payloadData: Data?, next: NextFn)
    async throws -> (Data, HTTPResponse)
  {

    let (data, response) = try await next(&request, payloadData)

    guard response.status.kind == .successful else {
      throw ClientError.badResponse(response: response, data: data)
    }

    return (data, response)
  }
}
