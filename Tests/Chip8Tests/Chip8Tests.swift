import XCTest
@testable import Chip8

enum TestError: Error {
    case video_err(String)
}

final class Chip8Tests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
    
    func testVideo() throws {
        let emulator = Emulator(bytes: "\0")
        if emulator.video.count != 32 {
            throw TestError.video_err("Incorrect video load")
        }
    }
}
