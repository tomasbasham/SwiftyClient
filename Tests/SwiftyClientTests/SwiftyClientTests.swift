import XCTest
@testable import SwiftyClient

final class SwiftyClientTests: XCTestCase {
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    XCTAssertEqual(SwiftyClient().text, "Hello, World!")
  }

  static var allTests = [
    ("testExample", testExample),
  ]
}
