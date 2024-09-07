import Foundation
import HTTPTypes

public enum ClientError: Error {
  
  public struct Extra {
    public let subreason: String?
  }
  
  case badResponse(response: HTTPResponse, data: Data, extra: Extra)
}



extension HTTPResponse {
  public var isContentTypeJSON: Bool {
    let contentType = self.headerFields[.contentType]
    return contentType?.contains("application/json") ?? false
  }
}
