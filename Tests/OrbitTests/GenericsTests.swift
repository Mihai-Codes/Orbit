/// Orbit Generics Tests
///
/// Unit tests for utility functions in Generics.swift

import XCTest
@testable import Orbit

final class GenericsTests: XCTestCase {
    
    // MARK: - TimeInterval.stopwatch() Tests
    
    func testStopwatchZeroSeconds() {
        let interval: TimeInterval = 0
        let result = interval.stopwatch()
        // The format is MM:SS.mmm - check the minutes and seconds are 00:00
        XCTAssertTrue(result.hasPrefix("00:00"), "Expected 00:00.xxx but got \(result)")
    }
    
    func testStopwatchOneMinute() {
        let interval: TimeInterval = 60
        let result = interval.stopwatch()
        // Check that we get 01:00.xxx (milliseconds may vary due to floating point)
        XCTAssertTrue(result.hasPrefix("01:00"), "Expected 01:00.xxx but got \(result)")
    }
    
    func testStopwatchMixedTime() {
        let interval: TimeInterval = 125.5 // 2 min 5.5 sec
        let result = interval.stopwatch()
        XCTAssertTrue(result.hasPrefix("02:05"), "Expected 02:05.xxx but got \(result)")
    }
    
    func testStopwatchInverted() {
        let interval: TimeInterval = -60
        let result = interval.stopwatch(invert: true)
        // Inverted -60 becomes 60, which is 01:00
        XCTAssertTrue(result.hasPrefix("01:00"), "Expected 01:00.xxx but got \(result)")
    }
    
    // MARK: - FileHandle TextOutputStream Tests
    
    func testFileHandleWriteDoesNotCrash() {
        // Test that writing to stderr doesn't crash
        // This is mainly a smoke test
        let handle = FileHandle.standardError
        handle.write("Test message from OrbitTests\n")
        // If we get here without crashing, the test passes
        XCTAssertTrue(true)
    }
}
