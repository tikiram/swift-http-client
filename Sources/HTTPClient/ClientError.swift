import Foundation
import HTTPTypes

public enum ClientError: Error {
  case badResponse(response: HTTPResponse, data: Data)
}
