//
//  Untitled.swift
//  swift-http-client
//
//  Created by Tikiram Ruiz on 3/10/24.
//

import HTTPTypes

extension HTTPResponse {
  public var isContentTypeJSON: Bool {
    let contentType = self.headerFields[.contentType]
    return contentType?.contains("application/json") ?? false
  }
}


