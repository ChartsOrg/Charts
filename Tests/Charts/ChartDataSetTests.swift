//
//  ChartDataSetTests.swift
//  ChartsTests
//
//  Created by Jacob Christie on 2019-01-08.
//

import XCTest
@testable import Charts

class ChartDataSetTests: XCTestCase {

    let set = ChartDataSet(values: [
        ChartDataEntry(x: 0, y: 1),
        ChartDataEntry(x: 0, y: 1),
        ChartDataEntry(x: 1, y: 1),
        ChartDataEntry(x: 1, y: 1),
        ChartDataEntry(x: 1, y: 1),
        ChartDataEntry(x: 1, y: 2),
        ChartDataEntry(x: 1, y: 16),
        ChartDataEntry(x: 2, y: 1),
        ChartDataEntry(x: 3, y: 1),
        ChartDataEntry(x: 3, y: 1),
        ChartDataEntry(x: 4, y: 4),
        ChartDataEntry(x: 4, y: 6)
    ])

    func testEntriesForXValue() {
        let filteredEntries = set.entriesForXValue(1)
        let expected = [
            ChartDataEntry(x: 1, y: 1),
            ChartDataEntry(x: 1, y: 1),
            ChartDataEntry(x: 1, y: 1),
            ChartDataEntry(x: 1, y: 2),
            ChartDataEntry(x: 1, y: 16)
        ]
        XCTAssertTrue(filteredEntries == expected, "\(expected), \(filteredEntries)")
    }

    func testEntriesForXValueClosestToYRounding() {
        let index = set.entryIndex(x: 5, closestToY: 5, rounding: .up)
        let expected = 11
        XCTAssertTrue(index == expected, "\(expected), \(index)")
    }
}
