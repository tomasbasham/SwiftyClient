//
//  Resource.swift
//  SwiftyClient
//
//  Created by Tomas Basham on 11/08/2019.
//  Copyright © 2019 Tomas Basham. All rights reserved.
//

import Foundation

/// Resource is a protocol used to delegate the responsibility of serialization
/// to another value type. This type must conform to the `Serializable`
/// protocol.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol Resource {

  /// The type of serializer representing the delegate of this type.
  ///
  /// When you implement this protocol, Swift infers this type from your
  /// implementation of the required `serializer` property.
  associatedtype Serializer: Serialization

  /// Declares the serializer of this type.
  static var serializer: Self.Serializer { get }
}

/// Default implementation for the `Resource` protocol.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Resource {
  public static var serializer: some Serialization {
    JSONSerializer()
  }
}
