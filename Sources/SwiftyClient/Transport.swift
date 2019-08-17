//
//  Transport.swift
//  SwiftyClient
//
//  Created by Tomas Basham on 28/07/2019.
//  Copyright © 2019 Tomas Basham. All rights reserved.
//

import Foundation

/// RawResponse is a tuple representing both the raw data and HTTP response
/// from a request. This is not a value type because it does not form a
/// conceptual entity but is used instead for convenience when supplying a
/// single type to `Result`.
public typealias RawResponse = (Data, HTTPURLResponse)

/// Transportable is a protocol used to decouple the implementation of the
/// transport layer from the client. This is important allow other
/// implementations to be injected into the client to facilitate local
/// development and testing and negate the need for a local server running.
public protocol Transportable {
  func dataTask(with request: URLRequest, result: @escaping (Result<RawResponse, Error>) -> Void)
}

/// TransportableDelegate is a protocol to enable a type conforming to
/// `Transportable` to hand-off responsibility of lifecycle events. These can
/// be used to update UI elements whilst a request is in flight.
public protocol TransportableDelegate {
  func transportDidStart(_ transport: Transportable, withRequest request: URLRequest)
  func transportDidEnd(_ transport: Transportable, withRequest request: URLRequest)
}

/// URLSessionAdapter
public struct URLSessionAdapter: Transportable {
  let urlSession: URLSession

  public init(with urlSession: URLSession = URLSession.shared) {
    self.urlSession = urlSession
  }

  /// delegate allows a single consumer to subscribe to specific events
  /// described by `TransportableDelegate`.
  public var delegate: TransportableDelegate?

  /// dataTask performs a network request described by a specific `URLRequest`
  /// type sending the result through a callback defined by the consumer.
  ///
  /// - parameters:
  ///   - request: The `Booking` belonging to the user.
  ///   - result: The result of the network request as a callback function.
  ///   - response: Raw response from the network request
  ///
  /// The callback receives a value representing either a success or a failure,
  /// including an associated value in each case. In the case of success the
  /// callback parameter will be a `RawResponse` value encapsulating the raw
  /// response data alongside the http response. These may be used to further
  /// validate the response.
  ///
  ///     let adapter = URLSessionAdapter()
  ///     let request = URLRequest(url: URL(string: "http://worldclockapi.com/api/json/est/now"))
  ///
  ///     adapter.dataTask(with: request) { result in
  ///       result.flatMap(self.validateResponse)
  ///     }
  ///
  public func dataTask(with request: URLRequest, result: @escaping (_ response: Result<RawResponse, Error>) -> Void) {
    self.delegate?.transportDidStart(self, withRequest: request)
    self.urlSession.dataTask(with: request) { (data, response, error) in
      defer {
        DispatchQueue.main.async {
          self.delegate?.transportDidEnd(self, withRequest: request)
        }
      }

      if let error = error {
        return result(.failure(error))
      }

      guard let data = data, let httpResponse = response as? HTTPURLResponse else {
        let error = NSError(domain: "error", code: 0, userInfo: nil)
        return result(.failure(error))
      }

      result(.success((data, httpResponse)))
    }.resume()
  }
}
