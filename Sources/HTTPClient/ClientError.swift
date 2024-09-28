import Foundation
import HTTPTypes

public enum ClientError: Error {
  case badResponse(response: HTTPResponse, data: Data)
}

extension HTTPResponse {
  public var isContentTypeJSON: Bool {
    let contentType = self.headerFields[.contentType]
    return contentType?.contains("application/json") ?? false
  }
}

extension HTTPRequest {
  public var isContentTypeJSON: Bool {
    self.headerFields[.contentType]?.contains("application/json") ?? false
  }
}

