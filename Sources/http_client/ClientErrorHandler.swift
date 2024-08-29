import Foundation
import HTTPTypes

class ClientErrorHandler: Client.Middleware {
  func request(request: inout HTTPRequest, payloadData: Data?, next: Client.NextFn) async throws
    -> (Data, HTTPResponse)
  {

    let (data, response) = try await next(&request, payloadData)

    guard [200, 204].contains(response.status) else {
      if let contentType = response.headerFields[.contentType],
        contentType.contains("application/json")
      {
        // TODO: charset is ignored here
        throw ClientError.badJsonResponse(
          response: response,
          data: data
        )
      }

      let body = String(data: data, encoding: .utf8) ?? "(nil)"
      throw ClientError.badResponse(response: response, body: body)
    }

    return (data, response)
  }
}
