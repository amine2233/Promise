//
//  FutureExtension.swift
//  Promise
//
//  Created by Amine Bensalah on 07/12/2018.
//

import XCTest
import Result

@testable import Promise

class FutureExtension: XCTestCase {

    enum TestError: Error {
        case empty
    }

    let futureWithValue = Future<Int, TestError>(value: 1)
    let futureWithError = Future<Int, TestError>(error: .empty)

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testFutureWithAndThenWithValue() {
        let expectation = self.expectation(description: "future has correct value")
        var expectedValue: String?

        futureWithValue.andThen { value -> Future<String, TestError> in
            return Future<String, TestError>(value: "\(value)")
        }.execute { result in
            expectedValue = result.value
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(expectedValue)
        XCTAssertEqual(expectedValue, "1", "future should have a correct value")
    }

    func testFutureWithAndThenWithFailure() {
        let expectation = self.expectation(description: "future should fail")
        var expectedError: TestError?

        futureWithError.andThen { _ -> Future<String, TestError> in
            return Future<String, TestError>(error: .empty)
        }.execute(onSuccess: { _ in }, onFailure: { error in
            expectedError = error
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(expectedError)
        XCTAssertEqual(expectedError, TestError.empty, "future should fail with an error")
    }

    func testFutureWithMapWithValue() {
        let expectation = self.expectation(description: "future has correct value")
        var expectedValue: String?

        futureWithValue.map { (value) in
            return "\(value)"
        }.execute(onSuccess: { (value) in
            expectedValue = value
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(expectedValue)
        XCTAssertEqual(expectedValue, "1", "future should have a correct value")
    }

    func testFutureWithMapWithFailure() {
        let expectation = self.expectation(description: "future should fail")
        var expectedError: TestError?

        futureWithError.map { _ in
            return ""
        }.execute(onSuccess: { _ in }, onFailure: { error in
            expectedError = error
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(expectedError)
        XCTAssertEqual(expectedError, TestError.empty, "future should fail with an error")
    }
}
