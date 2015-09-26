//
//  LineChartViewSpec.swift
//  ChartsDemo
//
//  Created by Victor Ilyukevich on 9/26/15.
//  Copyright © 2015 dcg. All rights reserved.
//

import Quick
import Nimble
import Nimble_Snapshots
import UIKit
import Charts

class LineChartViewSpec: QuickSpec {
  override func spec() {
    describe("line chart", {
      context("with positive values", {
        var chartView: LineChartView!

        beforeEach({
          // Sample data
          let values: [Double] = [8, 104, 81, 93, 52, 44, 97, 101, 75, 28,
                                  76, 25, 20, 13, 52, 44, 57, 23, 45, 91,
                                  99, 14, 84, 48, 40, 71, 106, 41, 45, 61]

          var entries: [ChartDataEntry] = Array()
          var xValues: [String] = Array()

          for (i, value) in values.enumerate() {
            entries.append(ChartDataEntry.init(value: value, xIndex: i))
            xValues.append("\(i)")
          }

          let dataSet = LineChartDataSet.init(yVals: entries, label: "First unit test data")
          let data = LineChartData.init(xVals: xValues, dataSet: dataSet)

          chartView = LineChartView.init(frame: CGRectMake(0, 0, 480, 350))
          chartView.data = data
        })

        it("is with default values") {
          expect(chartView).to(haveValidSnapshot())
        }

        it("hides values") {
          chartView.data?.dataSets.first?.drawValuesEnabled = false
          expect(chartView).to(haveValidSnapshot())
        }

        it("is filled") {
          chartView.data?.dataSets.first?.drawValuesEnabled = true
          expect(chartView).to(haveValidSnapshot())
        }

        it("does not draw circles") {
          (chartView.data?.dataSets.first as! LineChartDataSet).drawCirclesEnabled = false
          expect(chartView).to(haveValidSnapshot())
        }

        it("is cubic") {
          (chartView.data?.dataSets.first as! LineChartDataSet).drawCubicEnabled = true
          expect(chartView).to(haveValidSnapshot())
        }

      })
    });
  }
}