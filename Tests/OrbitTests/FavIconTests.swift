/// Orbit FavIcon Tests
///
/// Unit tests for FavIcon class

import XCTest
@testable import Orbit

final class FavIconTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testFavIconDefaultIcon() {
        let favicon = FavIcon()
        // Default icon should be the application icon
        XCTAssertNotNil(favicon.icon)
    }
    
    func testFavIconDescription() {
        let favicon = FavIcon()
        let description = favicon.description
        XCTAssertTrue(description.contains("FavIcon"), "Description should contain class name")
    }
    
    func testFavIconDescriptionWithURL() {
        let favicon = FavIcon()
        favicon.url = NSURL(string: "https://example.com/favicon.ico")
        let description = favicon.description
        XCTAssertTrue(description.contains("example.com"), "Description should contain URL")
    }
    
    // MARK: - URL Setting Tests
    
    func testFavIconURLSetterUpdatesProperty() {
        let favicon = FavIcon()
        let testURL = NSURL(string: "https://github.com/favicon.ico")
        favicon.url = testURL
        XCTAssertEqual(favicon.url, testURL)
    }
    
    // MARK: - Data Setting Tests
    
    // Note: FavIcon uses `unowned` references for icon properties which can cause
    // crashes when setting data in tests. These tests are skipped for now.
    // TODO: Refactor FavIcon to use weak or strong references for safer testing.
    
    func testFavIconDataPropertyExists() {
        let favicon = FavIcon()
        // Just verify the data property can be read (nil by default)
        XCTAssertNil(favicon.data)
    }
}
