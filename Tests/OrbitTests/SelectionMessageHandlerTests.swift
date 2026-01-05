// Orbit AI Sidecar - Selection Message Handler Tests
//
// Tests for SelectionMessageHandler and selection monitoring functionality

import XCTest
@testable import Orbit

final class SelectionMessageHandlerTests: XCTestCase {
    
    // MARK: - Handler Name Tests
    
    func testHandlerNameIsCorrect() {
        XCTAssertEqual(SelectionMessageHandler.handlerName, "OrbitSelectionChange")
    }
    
    func testSharedInstanceExists() {
        let handler = SelectionMessageHandler.shared
        XCTAssertNotNil(handler)
    }
    
    func testSharedInstanceIsSingleton() {
        let handler1 = SelectionMessageHandler.shared
        let handler2 = SelectionMessageHandler.shared
        XCTAssertTrue(handler1 === handler2)
    }
    
    // MARK: - Notification Name Tests
    
    func testWebViewSelectionDidChangeNotificationNameExists() {
        let name = Notification.Name.webViewSelectionDidChange
        XCTAssertEqual(name.rawValue, "com.orbit.webViewSelectionDidChange")
    }
    
    func testWebViewNavigationNotificationNamesExist() {
        XCTAssertEqual(
            Notification.Name.webViewDidFinishNavigation.rawValue,
            "com.orbit.webViewDidFinishNavigation"
        )
        XCTAssertEqual(
            Notification.Name.webViewDidStartNavigation.rawValue,
            "com.orbit.webViewDidStartNavigation"
        )
    }
}
