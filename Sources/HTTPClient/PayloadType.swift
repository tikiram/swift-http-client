


public enum PayloadType {
  case json
  case urlencoded
  
  func getContentType() -> String {
    switch self {
    case .json:
      return "application/json"
    case .urlencoded:
      return "application/x-www-form-urlencoded"
    }
  }
}
