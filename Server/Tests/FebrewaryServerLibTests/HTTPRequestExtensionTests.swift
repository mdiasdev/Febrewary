//
//  HTTPRequestExtensionTests.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 7/6/19.
//

import XCTest
import PerfectHTTP
import PerfectNet
import PerfectCrypto

@testable import FebrewaryServerLib

class HTTPRequestExtensionTests: XCTestCase {
    
    var sut: FakeRequest!

    static var allTests = [
        ("test_queryParamsAsDictionary_returnsParams_ifPresent", test_queryParamsAsDictionary_returnsParams_ifPresent),
        ("test_queryParamsAsDictionary_returnsEmptyDictionary_ifNoParams", test_queryParamsAsDictionary_returnsEmptyDictionary_ifNoParams),
        ("test_hasValidToken_returnsTrue_ifAuthTokenIsValid", test_hasValidToken_returnsTrue_ifAuthTokenIsValid),
        ("test_hasValidToken_returnsFalse_ifAuthTokenIsInvalid", test_hasValidToken_returnsFalse_ifAuthTokenIsInvalid),
        ("test_hasValidToken_returnsFalse_ifAuthTokenIsMissing", test_hasValidToken_returnsFalse_ifAuthTokenIsMissing),
        ("test_hasValidToken_returnsFalse_ifAuthTokenIsExpired", test_hasValidToken_returnsFalse_ifAuthTokenIsExpired),
        ("test_emailFromAuthToken_returnsString_ifAuthTokenIsValid", test_emailFromAuthToken_returnsString_ifAuthTokenIsValid),
        ("test_emailFromAuthToken_returnsNil_ifAuthTokenIsInvalid", test_emailFromAuthToken_returnsNil_ifAuthTokenIsInvalid),
        ("test_emailFromAuthToken_returnsNil_ifAuthTokenIsMissing", test_emailFromAuthToken_returnsNil_ifAuthTokenIsMissing),
    ]
    
    override func setUp() {
        super.setUp()
        
        sut = FakeRequest()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func test_queryParamsAsDictionary_returnsParams_ifPresent() {
        sut.queryParams = [("someKey", "someValue")]
        
        let actualParams = sut.queryParamsAsDictionary()
        
        XCTAssertFalse(actualParams.isEmpty)
        XCTAssertEqual(actualParams["someKey"], "someValue")
    }
    
    func test_queryParamsAsDictionary_returnsEmptyDictionary_ifNoParams() {
        let actualParams = sut.queryParamsAsDictionary()
        
        XCTAssertTrue(actualParams.isEmpty)
    }

    func test_hasValidToken_returnsTrue_ifAuthTokenIsValid() {
        let fakeToken = try! validAuthToken()
        sut.headers = AnyIterator([(HTTPRequestHeader.Name.authorization, fakeToken)].makeIterator())
        
        let isValid = sut.hasValidToken()
        
        XCTAssertTrue(isValid)
    }
    
    func test_hasValidToken_returnsFalse_ifAuthTokenIsInvalid() {
        let fakeToken = try! invalidAuthToken()
        sut.headers = AnyIterator([(HTTPRequestHeader.Name.authorization, fakeToken)].makeIterator())
        
        let isValid = sut.hasValidToken()
        
        XCTAssertFalse(isValid)
    }
    
    func test_hasValidToken_returnsFalse_ifAuthTokenIsMissing() {
        
        let isValid = sut.hasValidToken()
        
        XCTAssertFalse(isValid)
    }
    
    func test_hasValidToken_returnsFalse_ifAuthTokenIsExpired() {
        let fakeToken = try! expiredAuthToken()
        sut.headers = AnyIterator([(HTTPRequestHeader.Name.authorization, fakeToken)].makeIterator())
        
        let isValid = sut.hasValidToken()
        
        XCTAssertFalse(isValid)
    }
    
    func test_emailFromAuthToken_returnsString_ifAuthTokenIsValid() {
        let fakeToken = try! validAuthToken()
        sut.headers = AnyIterator([(HTTPRequestHeader.Name.authorization, fakeToken)].makeIterator())
        
        let email = sut.emailFromAuthToken()
        
        XCTAssertNotNil(email)
        XCTAssertEqual(email, "helloStream@me.net")
    }
    
    func test_emailFromAuthToken_returnsNil_ifAuthTokenIsInvalid() {
        let fakeToken = try! invalidAuthToken()
        sut.headers = AnyIterator([(HTTPRequestHeader.Name.authorization, fakeToken)].makeIterator())
        
        let email = sut.emailFromAuthToken()
        
        XCTAssertNil(email)
    }
    
    func test_emailFromAuthToken_returnsNil_ifAuthTokenIsMissing() {
        let email = sut.emailFromAuthToken()
        
        XCTAssertNil(email)
    }
}

class FakeRequest: HTTPRequest {
    var method: HTTPMethod = .get
    var path: String = "somewhereOutThere"
    var pathComponents: [String] = []
    var queryParams: [(String, String)] = []
    var protocolVersion: (Int, Int) = (42, 42)
    var remoteAddress: (host: String, port: UInt16) = ("localhost", 8080)
    var serverAddress: (host: String, port: UInt16) = ("localhost", 8080)
    var serverName: String = "test fake"
    var documentRoot: String = ""
    var connection: NetTCP = NetTCP(fd: -42)
    var urlVariables: [String: String] = [:]
    var scratchPad: [String: Any] = [:]
    var headers: AnyIterator<(HTTPRequestHeader.Name, String)> = AnyIterator([].makeIterator())
    var postParams: [(String, String)] = []
    var postBodyBytes: [UInt8]?
    var postBodyString: String?
    var postFileUploads: [MimeReader.BodySpec]?
    
    func header(_ named: HTTPRequestHeader.Name) -> String? {
        return headers.first(where: { (header) -> Bool in
            return header.0 == named
        })?.1
    }
    func addHeader(_ named: HTTPRequestHeader.Name, value: String) { }
    func setHeader(_ named: HTTPRequestHeader.Name, value: String) { }
}

func validAuthToken() throws -> String {
    
    let payload: [String : Any] = [
        "email": "helloStream@me.net",
        "issuedAt": Date().timeIntervalSince1970,
        "expiration": Date().addingTimeInterval(36000).timeIntervalSince1970
    ]
    
    guard let jwt = JWTCreator(payload: payload) else {
        throw PrepareTokenError()
    }
    
    let token = try jwt.sign(alg: .hs256, key: Configuration.salt)
    
    return token
}

func expiredAuthToken() throws -> String {
    
    let payload: [String : Any] = [
        "email": "helloStream@me.net",
        "issuedAt": Date().timeIntervalSince1970,
        "expiration": Date().addingTimeInterval(-36000).timeIntervalSince1970
    ]
    
    guard let jwt = JWTCreator(payload: payload) else {
        throw PrepareTokenError()
    }
    
    let token = try jwt.sign(alg: .hs256, key: Configuration.salt)
    
    return token
}

func invalidAuthToken() throws -> String {
    
    let payload: [String : Any] = [
        "issuedAt": Date().timeIntervalSince1970,
        "expiration": Date().addingTimeInterval(36000).timeIntervalSince1970
    ]
    
    guard let jwt = JWTCreator(payload: payload) else {
        throw PrepareTokenError()
    }
    
    let token = try jwt.sign(alg: .hs256, key: Configuration.salt)
    
    return token
}
