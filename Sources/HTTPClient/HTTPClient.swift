import Foundation
import HTTPTypes
import HTTPTypesFoundation

public typealias NextFn = (_ request: inout HTTPRequest, _ data: Data?) async throws -> (
  Data, HTTPResponse
)

final public class HTTPClient: Sendable {

  public protocol Middleware: Sendable {
    func request(request: inout HTTPRequest, payloadData: Data?, next: NextFn) async throws -> (
      Data, HTTPResponse
    )
  }

  private let base: String
  private let middlewares: [Middleware]
  private let jsonEncoder: JSONEncoder
  private let jsonDecoder: JSONDecoder

  public init(
    base: String,
    middlewares: [Middleware],
    jsonEncoder: JSONEncoder = JSONEncoder(),
    jsonDecoder: JSONDecoder = JSONDecoder()
  ) {
    self.base = base
    self.middlewares = middlewares
    self.jsonEncoder = jsonEncoder
    self.jsonDecoder = jsonDecoder
  }

  public func request<T: Decodable>(
    _ method: HTTPRequest.Method,
    _ resourcePath: String,
    payload: Encodable? = nil,
    query: Encodable? = nil,
    payloadType: PayloadType = .json
  ) async throws -> T {
    let pathWithQueryString = query.map { resourcePath + "?" + toQueryString($0) }
    let path = pathWithQueryString ?? resourcePath
    let payloadData = try payload.map { try getPayloadData($0, payloadType: payloadType) }

    var request = HTTPRequest(method: method, scheme: "https", authority: base, path: path)
    request.headerFields[.contentType] = payloadType.getContentType()
    
    let (data, _) = try await performRequest(&request, with: payloadData)
    return try jsonDecoder.decode(T.self, from: data)
  }

  public func request(
    _ method: HTTPRequest.Method,
    _ resourcePath: String,
    payload: Encodable? = nil,
    query: Encodable? = nil,
    payloadType: PayloadType = .json
  ) async throws {
    let pathWithQueryString = query.map { resourcePath + "?" + toQueryString($0) }
    let path = pathWithQueryString ?? resourcePath
    let payloadData = try payload.map { try getPayloadData($0, payloadType: payloadType) }

    
//    let url = URL(string: "https://www.example.com/")
//    if var url {
//      let item = URLQueryItem(name: "q", value: "soccer")
//      url.append(queryItems: [])
//    }
    
    var request = HTTPRequest(method: method, scheme: "https", authority: base, path: path)
    request.headerFields[.contentType] = payloadType.getContentType()
    
    let _ = try await performRequest(&request, with: payloadData)
  }
  
  private func getPayloadData(_ payload: Encodable, payloadType: PayloadType) throws -> Data {
    switch payloadType {
    case .json:
      return try jsonEncoder.encode(payload)
    case .urlencoded:
      let string = toQueryString(payload)
      guard let data = string.data(using: .utf8) else {
        throw ClientError.payloadEncodingFailed
      }
      return data
    }
  }

  private func performRequest(_ request: inout HTTPRequest, with data: Data?) async throws
    -> (Data, HTTPResponse)
  {
    let fn = reduceMiddlewares(lastAction: lastAction)
    return try await fn(&request, data)
  }

  private func reduceMiddlewares(lastAction: @escaping NextFn) -> NextFn {
    let result = middlewares.reduce(
      lastAction,
      { nextFn, middleware in
        return { request, data in
          return try await middleware.request(request: &request, payloadData: data, next: nextFn)
        }
      })
    return result
  }

  private func lastAction(request: inout HTTPRequest, data: Data?) async throws -> (
    Data, HTTPResponse
  ) {
    if let data {
      return try await URLSession.shared.upload(for: request, from: data)
    }

    return try await URLSession.shared.data(for: request)
  }
}
