import Foundation
import HTTPTypes

public enum ClientError: Error {
  case badJsonResponse(response: HTTPResponse, data: Data)
  case badResponse(response: HTTPResponse, body: String)
}
