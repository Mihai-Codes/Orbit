/// Orbit WebView Configuration Tests
///
/// Unit tests for MPWebViewConfigOptions enum

import XCTest
@testable import Orbit

final class WebViewConfigTests: XCTestCase {
    
    // MARK: - MPWebViewConfigOptions RawValue Tests
    
    func testConfigOptionRawValueURL() {
        let option = MPWebViewConfigOptions.url("https://example.com")
        XCTAssertEqual(option.rawValue, "url")
    }
    
    func testConfigOptionRawValueAgent() {
        let option = MPWebViewConfigOptions.agent("Mozilla/5.0")
        XCTAssertEqual(option.rawValue, "agent")
    }
    
    func testConfigOptionRawValueTransparent() {
        let option = MPWebViewConfigOptions.transparent(true)
        XCTAssertEqual(option.rawValue, "transparent")
    }
    
    func testConfigOptionRawValueIsolated() {
        let option = MPWebViewConfigOptions.isolated(true)
        XCTAssertEqual(option.rawValue, "isolated")
    }
    
    func testConfigOptionRawValuePrivacy() {
        let option = MPWebViewConfigOptions.privacy(true)
        XCTAssertEqual(option.rawValue, "privacy")
    }
    
    // MARK: - Content Blocking Options
    
    func testConfigOptionBlockAds() {
        let option = MPWebViewConfigOptions.blockAds(true)
        XCTAssertEqual(option.rawValue, "blockAds")
    }
    
    func testConfigOptionBlockTrackers() {
        let option = MPWebViewConfigOptions.blockTrackers(true)
        XCTAssertEqual(option.rawValue, "blockTrackers")
    }
    
    func testConfigOptionHttpsUpgrade() {
        let option = MPWebViewConfigOptions.httpsUpgrade(true)
        XCTAssertEqual(option.rawValue, "httpsUpgrade")
    }
    
    // MARK: - Hashable Conformance
    
    func testConfigOptionsHashable() {
        let option1 = MPWebViewConfigOptions.url("https://example.com")
        let option2 = MPWebViewConfigOptions.url("https://other.com")
        let option3 = MPWebViewConfigOptions.agent("test")
        
        // Same type options should have same hash (based on rawValue)
        XCTAssertEqual(option1.hashValue, option2.hashValue)
        // Different type options should have different hash
        XCTAssertNotEqual(option1.hashValue, option3.hashValue)
    }
    
    // MARK: - Init from RawValue Tests
    
    func testInitFromRawValueWithBool() {
        let option = MPWebViewConfigOptions(rawValue: "transparent", value: true)
        XCTAssertNotNil(option)
        XCTAssertEqual(option?.rawValue, "transparent")
    }
    
    func testInitFromRawValueWithString() {
        let option = MPWebViewConfigOptions(rawValue: "url", value: "https://test.com")
        XCTAssertNotNil(option)
        XCTAssertEqual(option?.rawValue, "url")
    }
    
    func testInitFromRawValueWithInvalidKey() {
        let option = MPWebViewConfigOptions(rawValue: "invalidKey", value: true)
        XCTAssertNil(option)
    }
    
    func testInitFromRawValueWithStringArray() {
        let option = MPWebViewConfigOptions(rawValue: "preinject", value: ["script1.js", "script2.js"])
        XCTAssertNotNil(option)
        XCTAssertEqual(option?.rawValue, "preinject")
    }
}
