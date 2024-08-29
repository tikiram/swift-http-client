import Foundation
import HTTPTypes

public class ClientLogger: Client.Middleware {
  public func request(request: inout HTTPRequest, payloadData: Data?, next: Client.NextFn) async throws
    -> (Data, HTTPResponse)
  {

    print(">>> request: \(request.method) - \(request.path ?? "")")
    if let payloadData {
      let json = String(data: payloadData, encoding: .utf8)
      print(json ?? "(nil)")
    }

    do {
      let (data, response) = try await next(&request, payloadData)
      print("<<< response: \(response.status)")

      let json = String(data: data, encoding: .utf8)
      print(json ?? "(nil)")

      return (data, response)

    } catch {
      print("<<< Error:")
      print(error)
      throw error
    }
  }
}