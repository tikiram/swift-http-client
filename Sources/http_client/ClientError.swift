import Foundation
import HTTPTypes

public enum ClientError: Error {
  case badResponse(response: HTTPResponse, data: Data)
}

public extension HTTPResponse {
  var isContentTypeJSON: Bool {
    let contentType = self.headerFields[.contentType]
    return contentType?.contains("application/json") ?? false
  }
}
