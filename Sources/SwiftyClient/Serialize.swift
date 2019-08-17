//
//  Serialize.swift
//  SwiftyClient
//
//  Created by Tomas Basham on 28/07/2019.
//  Copyright © 2019 Tomas Basham. All rights reserved.
//

import Foundation

/// Serializable is a protocol used to describe how values should be serialized
/// to and from a wire format into concrete value types.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol Serialization {
  func decode<DecodableType: Decodable>(from data: Data) -> DecodableType?
  func decode<DecodableType: Decodable>(_ string: String, using encoding: String.Encoding) -> DecodableType?
  func decode<DecodableType: Decodable>(fromURL url: URL) -> DecodableType?

  func encode<EncodableType: Encodable>(from value: EncodableType) -> Data?
  func encode<EncodableType: Encodable>(_ value: EncodableType, using encoding: String.Encoding) -> String?
}

/// NilSerializer performs no operation on data it receives in any of its
/// method implementations and always returns nil. This is used internally to
/// as the serializer for the `NoContent` value.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
struct NilSerializer: Serialization {
  func decode<DecodableType: Decodable>(from data: Data) -> DecodableType? {
    return nil
  }

  func decode<DecodableType: Decodable>(_ string: String, using encoding: String.Encoding) -> DecodableType? {
    return nil
  }

  func decode<DecodableType: Decodable>(fromURL url: URL) -> DecodableType? {
    return nil
  }

  func encode<EncodableType: Encodable>(from value: EncodableType) -> Data? {
    return nil
  }

  func encode<EncodableType: Encodable>(_ value: EncodableType, using encoding: String.Encoding) -> String? {
    return nil
  }
}

/// JSONSerializer decodes and encodes JSON data to and from concrete Swift
/// value types. By default it assumes all JSON received will contain keys
/// formatted in snake case, and that all dates will be in ISO8601 format.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct JSONSerializer: Serialization {
  public init() {}

  private var decoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }

  public func decode<DecodableType: Decodable>(from data: Data) -> DecodableType? {
    guard let decoded = try? decoder.decode(DecodableType.self, from: data) else {
      return nil
    }

    return decoded
  }

  public func decode<DecodableType: Decodable>(_ string: String, using encoding: String.Encoding = .utf8) -> DecodableType? {
    guard let data = string.data(using: encoding) else {
      return nil
    }

    return decode(from: data)
  }

  public func decode<DecodableType: Decodable>(fromURL url: URL) -> DecodableType? {
    guard let data = try? Data(contentsOf: url) else {
      return nil
    }

    return decode(from: data)
  }

  private var encoder: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
  }

  public func encode<EncodableType: Encodable>(from value: EncodableType) -> Data? {
    guard let data = try? encoder.encode(value) else {
      return nil
    }

    return data
  }

  public func encode<EncodableType: Encodable>(_ value: EncodableType, using encoding: String.Encoding) -> String? {
    guard let data = encode(from: value) else {
      return nil
    }

    return String(data: data, encoding: encoding)
  }
}
