//
//  SwiftyClient.swift
//  SwiftyClient
//
//  Created by Tomas Basham on 28/07/2019.
//  Copyright © 2019 Tomas Basham. All rights reserved.
//

import Foundation

// TODO: remove this type. It should not be necessary and enforces the response
// to have this shape.
public struct APIResponse<Data: Decodable>: Decodable {
  let message: String?
  let data: Data?
}

/// NoContent represents an empty HTTP response body whilst maintaining
/// compatability with `APIResponse`.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct NoContent: Codable, Resource {
  public static var serializer: some Serialization {
    NilSerializer()
  }
}

/// Serializable composes both the `Codeable` and `Resource` protocols to
/// represent a concreate value type that can be both encoded to a wire format
/// from raw data and decoded from a wire format to raw data.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias Serializable = Codable & Resource

/// HTTPMethod describes the acceptable HTTP verbs to be used with this API.
public enum HTTPMethod: String, CaseIterable {
  case get = "GET"
  case head = "HEAD"
  case post = "POST"
  case put = "PUT"
  case patch = "PATCH"
  case delete = "DELETE"
  case options = "OPTIONS"
}

/// ClientError describes error types that may be returned from the client.
public enum ClientError: Error {
  case badResponse
  case decoding
  case encoding
  case missing
  case serialisation
  case server(status: Int, message: String)
}

/// Client
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct Client {
  let transport: Transportable

  public init(with transport: Transportable = URLSessionAdapter()) {
    self.transport = transport
  }

  /// dataTask delegates data tasks to the underlying transport type sending
  /// the result through a callback defined by the consumer.
  ///
  /// - parameters:
  ///   - request: The `Booking` belonging to the user.
  ///   - result: The result of the network request as a callback function.
  ///   - response: Response from the data task.
  ///
  /// The callback receives a value representing either a success or a failure,
  /// including an associated value in each case. In the case of success the
  /// callback parameter will be a `Deserializabale` value that may be consumed
  /// by an application.
  ///
  ///     let client = Client()
  ///     let request = URLRequest(url: URL(string: "http://worldclockapi.com/api/json/est/now"))
  ///
  ///     client.dataTask(with: request) { (response: Result<Time, Error>) in
  ///       self.currentTime = response.map { $0.currentDateTime }
  ///     }
  ///
  public func dataTask<SerializableType: Serializable>(with request: URLRequest, result: @escaping (_ response: Result<SerializableType, Error>) -> Void) {
    self.transport.dataTask(with: request) { response in
      switch response {
      case .success(let (data, httpResponse)):
        let serializer = SerializableType.serializer

        // The type of `data` needs to be reified as this information is lost
        // when returned from `dataTask(with:)` as `Data`.
        guard let apiResponse: APIResponse<SerializableType> = serializer.decode(from: data) else {
          return result(.failure(ClientError.decoding))
        }

        // Check the status code indicates success.
        guard 200..<299 ~= httpResponse.statusCode else {
          let error = ClientError.server(status: httpResponse.statusCode, message: apiResponse.message!)
          return result(.failure(error))
        }

        guard let data = apiResponse.data else {
          return result(.failure(ClientError.missing))
        }

        result(.success(data))
      case .failure(let error):
        result(.failure(error))
      }
    }
  }
}
