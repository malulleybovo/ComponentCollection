//
//  SampleServiceTests.swift
//  ComponentCollectionTests
//
//  Created by malulleybovo on 13/03/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import XCTest
@testable import ComponentCollection

class SampleServiceRequestTests: XCTestCase {

    func testApiCall() throws {
        let expectation = XCTestExpectation()
        NetworkLayer().execute(request: SampleServiceRequest(body: SampleServiceBody(someId: 1))) { statusCode, responseModel, message in
            if statusCode == 200 {
                XCTAssertNotNil(responseModel, "Response was not parsed correctly")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

}
