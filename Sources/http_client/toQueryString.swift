import Foundation

// TODO: create custom encoder instead (?)
func toQueryString(_ payload: Encodable) -> String {
  let mirror = Mirror(reflecting: payload)

  let queryString = mirror.children
    .filter {
      $0.label != nil
    }.map {
      if let date = $0.value as? Date {
        let value = date.timeIntervalSince1970.magnitude * 1000
        return ($0.label!, String(value))
      }
      return ($0.label!, "\($0.value)")
    }.map {
      "\($0.0)=\($0.1)"
    }.joined(separator: "&")

  return queryString
}
