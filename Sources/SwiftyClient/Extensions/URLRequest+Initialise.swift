//
//  URLRequest+Initialise.swift
//  SwiftyClient
//
//  Created by Tomas Basham on 17/08/2019.
//  Copyright © 2019 Tomas Basham. All rights reserved.
//

import Foundation

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension URLRequest {
  public init?(for endpoint: String, method: HTTPMethod) {
    self.init(for: endpoint, method: method, parameters: nil, body: NoContent())
  }

  public init?(for endpoint: String, method: HTTPMethod, parameters: [String: String]) {
    self.init(for: endpoint, method: method, parameters: parameters, body: NoContent())
  }

  public init?<SerializableType: Serializable>(for endpoint: String, method: HTTPMethod, body: SerializableType) {
    self.init(for: endpoint, method: method, parameters: nil, body: body)
  }

  public init?<SerializableType: Serializable>(for endpoint: String, method: HTTPMethod, parameters: [String: String]?, body: SerializableType?) {
    guard let url = URL(string: endpoint), var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
      fatalError("Invalid URL.")
    }

    let queryItems = parameters?.map { (key, value) in
      return URLQueryItem(name: key, value: value)
    }

    components.queryItems = queryItems
    guard let componentURL = components.url else {
      return nil
    }

    // At this point everything has been checked and is fine. Initialise the
    // URLRequest value using the componentURL from the URLComponents.
    self.init(url: componentURL)

    // Fetch the serializer from the `SerializableType` value type itself. This
    // method cannot be used with any type that does not conform to
    // `SerializableType` and therefore by extension `Resource` so it must
    // return a concrete serialization type.
    let serializer = SerializableType.serializer

    // Last set the HTTP method and, optionally, the HTTP body. The serializer
    // can return `nil` which is an acceptable value for the `httpBody`
    // property.
    self.httpMethod = method.rawValue
    self.httpBody = serializer.encode(from: body)
  }
}
