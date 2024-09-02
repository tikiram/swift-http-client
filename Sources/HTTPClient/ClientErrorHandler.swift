import Foundation
import HTTPTypes

public class ClientErrorHandler: Client.Middleware {

  public init() {
  }

  public func request(request: inout HTTPRequest, payloadData: Data?, next: Client.NextFn)
    async throws
    -> (Data, HTTPResponse)
  {

    let (data, response) = try await next(&request, payloadData)

    guard response.status.kind == .successful else {
      throw ClientError.badResponse(response: response, data: data)
    }

    return (data, response)
  }
}
