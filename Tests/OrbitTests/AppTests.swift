/// Orbit App Tests
///
/// Unit tests for MacPinApp and Safari version detection

import XCTest
@testable import Orbit

final class AppTests: XCTestCase {
    
    // MARK: - Version Detection Tests
    
    func testWebKitVersionTupleIsValid() {
        // WebKit version should have valid components
        XCTAssertGreaterThanOrEqual(WebKit_version.major, 0)
        XCTAssertGreaterThanOrEqual(WebKit_version.minor, 0)
        XCTAssertGreaterThanOrEqual(WebKit_version.tiny, 0)
    }
    
    func testJavaScriptCoreVersionTupleIsValid() {
        // JSC version should have valid components
        XCTAssertGreaterThanOrEqual(JavaScriptCore_version.major, 0)
        XCTAssertGreaterThanOrEqual(JavaScriptCore_version.minor, 0)
        XCTAssertGreaterThanOrEqual(JavaScriptCore_version.tiny, 0)
    }
    
    func testSafariVersionIsNotUnknown() {
        // Safari version should be detected on macOS
        #if os(macOS)
        // On modern macOS, we should detect a Safari version
        XCTAssertNotEqual(Safari_version, "???", "Safari version should be detected on macOS")
        #endif
    }
    
    func testSafariVersionFormat() {
        // Safari version should be in format X.Y or X.Y.Z
        let components = Safari_version.split(separator: ".")
        XCTAssertGreaterThanOrEqual(components.count, 1)
        XCTAssertLessThanOrEqual(components.count, 3)
        
        // Each component should be numeric (if not "???")
        if Safari_version != "???" {
            for component in components {
                XCTAssertNotNil(Int(component), "Version component '\(component)' should be numeric")
            }
        }
    }
}
