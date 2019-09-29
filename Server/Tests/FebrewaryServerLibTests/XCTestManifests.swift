import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ArrayExtensionTests.allTests),
        testCase(StringExtensionTests.allTests),
        testCase(HTTPRequestExtensionTests.allTests),
        testCase(RouterTests.allTests),
    ]
}
#endif
