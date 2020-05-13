import XCTest

import DaggerTests

var tests = [XCTestCaseEntry]()
tests += DaggerTests.__allTests()

XCTMain(tests)
