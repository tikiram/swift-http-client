import HTTPTypes

extension HTTPRequest {
  public var isContentTypeJSON: Bool {
    self.headerFields[.contentType]?.contains("application/json") ?? false
  }
}
