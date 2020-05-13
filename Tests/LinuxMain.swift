import XCTest

import DaggerTests

var tests = [XCTestCaseEntry]()
tests += DaggerTests.allTests()
XCTMain(tests)
