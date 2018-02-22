//
//  TestDoubleExt.swift
//  ChartsTests
//
//  Created by Azamat Kalmurzayev on 2/22/18.
//

import XCTest
@testable import Charts

class TestDoubleExt: XCTestCase {
    func testAdjustingToBounds() {
        XCTAssertEqual((-100000.0).adjustTo(minVal: 120, maxVal: 500), 120)
        XCTAssertEqual(0.adjustTo(minVal: 120, maxVal: 500), 120)
        XCTAssertEqual(120.adjustTo(minVal: 120, maxVal: 500), 120)
        XCTAssertEqual(200.adjustTo(minVal: 120, maxVal: 500), 200)
        XCTAssertEqual(500.adjustTo(minVal: 120, maxVal: 500), 500)
        XCTAssertEqual(501.adjustTo(minVal: 120, maxVal: 500), 500)
        XCTAssertEqual(5000.adjustTo(minVal: 120, maxVal: 500), 500)
    }
}

