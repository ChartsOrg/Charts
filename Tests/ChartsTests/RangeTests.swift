//
//  RangeTests.swift
//  ChartsTests
//
//  Created by Berend Klein Haneveld on 02/03/2021.
//

@testable import Charts
import XCTest

class RangeTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testChartOutOfBoundsLower() throws {
        let dataset = ScatterChartDataSet(entries: [
            ChartDataEntry(x: 0.0, y: 2.0),
            ChartDataEntry(x: 1.0, y: 2.0),
            ChartDataEntry(x: 2.0, y: 2.0),
        ])

        let data = ScatterChartData(dataSet: dataset)

        let scatterView = ScatterChartView()
        scatterView.data = data
        scatterView.xAxis.axisMinimum = 2.0
        scatterView.xAxis.axisMaximum = 5.0

        let xrange = BarLineScatterCandleBubbleRenderer.XBounds(chart: scatterView, dataSet: dataset, animator: nil)
        print(xrange)
        XCTAssert(xrange.min == 2)
        XCTAssert(xrange.max == 2)
    }
}
