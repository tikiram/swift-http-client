import Foundation
import HTTPTypes

final public class ClientLogger: Client.Middleware {
  // TODO: check how to enable/disable these logs
  // it can be using a flag from the constructor
  // or it can be use an env variable (prod, dev, etc)


  public init() {
  }

  public func request(request: inout HTTPRequest, payloadData: Data?, next: Client.NextFn)
    async throws
    -> (Data, HTTPResponse)
  {

    print(">>> request: \(request.method) - \(request.path ?? "")")
    
    if let payloadData, request.isContentTypeJSON {
      let json = tryGetPrettyPrintedJSON(from: payloadData)
      print(json)
    }

    do {
      let (data, response) = try await next(&request, payloadData)
      print("<<< response: \(response.status)")
      
      if response.isContentTypeJSON {
        let json = tryGetPrettyPrintedJSON(from: data)
        print(json)
      }

      return (data, response)
    } catch {
      print("<<< Error:")
      print(error)
      throw error
    }
  }
}

private func tryGetPrettyPrintedJSON(from data: Data) -> String {
  if let json = getPrettyPrintedJSON(from: data) {
    return json
  }
  else {
    return String(data: data, encoding: .utf8) ?? "(nil)"
  }
}

private func getPrettyPrintedJSON(from data: Data) -> String? {
  if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
     let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
      return String(decoding: jsonData, as: UTF8.self)
  }
  return nil
}
