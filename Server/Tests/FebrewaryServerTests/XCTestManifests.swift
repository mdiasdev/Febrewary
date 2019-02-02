import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ServerTests.allTests),
        testCase(RouterTests.allTests),
    ]
}
#endif
