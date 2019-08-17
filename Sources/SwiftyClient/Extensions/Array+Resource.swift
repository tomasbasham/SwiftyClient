//
//  Array+Resource.swift
//  SwiftyClient
//
//  Created by Tomas Basham on 17/08/2019.
//  Copyright © 2019 Tomas Basham. All rights reserved.
//

import Foundation

/// An array of codeable elements should conform to the `Resource` protocol to
/// allow the array and it's elements to be serialized to and from a wire
/// format into concrete value types.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Array: Resource where Element: Codable {
  public static var serializer: some Serialization {
    JSONSerializer()
  }
}

