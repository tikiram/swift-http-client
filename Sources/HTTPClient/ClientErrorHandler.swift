import Foundation
import HTTPTypes

public class ClientErrorHandler: Client.Middleware {

  public typealias ProduceSubreason = (HTTPResponse, Data) -> String?
  
  private let produceSubreason: ProduceSubreason?
  
  public init(produceSubreason: ProduceSubreason? = nil ) {
    self.produceSubreason = produceSubreason
  }

  public func request(request: inout HTTPRequest, payloadData: Data?, next: Client.NextFn)
    async throws
    -> (Data, HTTPResponse)
  {
    let (data, response) = try await next(&request, payloadData)

    guard response.status.kind == .successful else {
      let subreason = produceSubreason?(response, data)
      let extra = ClientError.Extra(subreason: subreason)
      throw ClientError.badResponse(response: response, data: data, extra: extra)
    }

    return (data, response)
  }
}
