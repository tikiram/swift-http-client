import Foundation
import HTTPTypes
import HTTPTypesFoundation

final public class Client: Sendable {

  public typealias NextFn = (_ request: inout HTTPRequest, _ data: Data?) async throws -> (
    Data, HTTPResponse
  )

  public protocol Middleware: Sendable {
    func request(request: inout HTTPRequest, payloadData: Data?, next: NextFn) async throws -> (
      Data, HTTPResponse
    )
  }

  private let base: String
  private let middlewares: [Middleware]
  private let jsonEncoder: JSONEncoder
  private let jsonDecoder: JSONDecoder

  public init(base: String, middlewares: [Middleware]) {
    self.base = base
    self.middlewares = middlewares
    // TODO: get encoder/decoder from parameters
    self.jsonEncoder = JSONEncoder()
    self.jsonDecoder = JSONDecoder()

    self.jsonEncoder.dateEncodingStrategy = .millisecondsSince1970
    self.jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
  }

  public func request<T: Decodable>(
    _ method: HTTPRequest.Method,
    _ resourcePath: String,
    payload: Encodable? = nil,
    query: Encodable? = nil
  ) async throws -> T {
    let pathWithQueryString = query.map { resourcePath + "?" + toQueryString($0) }
    let path = pathWithQueryString ?? resourcePath
    let payloadData = try payload.map { try jsonEncoder.encode($0) }

    var request = HTTPRequest(method: method, scheme: "https", authority: base, path: path)
    let (data, _) = try await performRequest(&request, with: payloadData)
    return try jsonDecoder.decode(T.self, from: data)
  }

  public func request(
    _ method: HTTPRequest.Method,
    _ resourcePath: String,
    payload: Encodable? = nil,
    query: Encodable? = nil
  ) async throws {
    let pathWithQueryString = query.map { resourcePath + "?" + toQueryString($0) }
    let path = pathWithQueryString ?? resourcePath
    let payloadData = try payload.map { try jsonEncoder.encode($0) }

    var request = HTTPRequest(method: method, scheme: "https", authority: base, path: path)
    let _ = try await performRequest(&request, with: payloadData)
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
      request.headerFields[.contentType] = "application/json"
      return try await URLSession.shared.upload(for: request, from: data)
    }

    return try await URLSession.shared.data(for: request)
  }
}
