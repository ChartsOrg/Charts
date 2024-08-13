//
//  HorizontalBarChartTests.swift
//  ChartsTests
//
//  Created by Xuan Liu on 2019/3/20.
//

@testable import DGCharts
import SnapshotTesting
import XCTest

class HorizontalBarChartTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Set to `true` to re-capture all snapshots
        isRecording = false
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: Prepare

    func setupCustomValuesDataEntries(values: [Double]) -> [ChartDataEntry] {
        var entries: [ChartDataEntry] = Array()
        for (i, value) in values.enumerated() {
            entries.append(BarChartDataEntry(x: Double(i), y: value, icon: UIImage(named: "icon", in: Bundle(for: classForCoder), compatibleWith: nil)))
        }
        return entries
    }

    func setupStackedvaluesDataEntries() -> [ChartDataEntry] {
        var entries: [ChartDataEntry] = Array()
        entries.append(BarChartDataEntry(x: 0, yValues: [28, 50, 60, 30, 42], icon: UIImage(named: "icon")))
        entries.append(BarChartDataEntry(x: 1, yValues: [-20, -36, -52, -40, -15], icon: UIImage(named: "icon")))
        entries.append(BarChartDataEntry(x: 2, yValues: [10, 30, 40, 90, 72], icon: UIImage(named: "icon")))
        entries.append(BarChartDataEntry(x: 3, yValues: [-40, -50, -30, -60, -20], icon: UIImage(named: "icon")))
        entries.append(BarChartDataEntry(x: 4, yValues: [10, 40, 60, 45, 62], icon: UIImage(named: "icon")))
        return entries
    }

    func setupDefaultValuesDataEntries() -> [ChartDataEntry] {
        let values: [Double] = [8, 104, -81, 93, 52, -44, 97, 101, -75, 28,
                                -76, 25, 20, -13, 52, 44, -57, 23, 45, -91,
                                99, 14, -84, 48, 40, -71, 106, 41, -45, 61]
        return setupCustomValuesDataEntries(values: values)
    }

    func setupDefaultDataSet(chartDataEntries: [ChartDataEntry]) -> BarChartDataSet {
        let dataSet = BarChartDataSet(entries: chartDataEntries, label: "Bar chart unit test data")
        dataSet.drawIconsEnabled = false
        dataSet.iconsOffset = CGPoint(x: 0, y: -10.0)
        return dataSet
    }

    func setupDefaultStackedDataSet(chartDataEntries: [ChartDataEntry]) -> BarChartDataSet {
        let dataSet = BarChartDataSet(entries: chartDataEntries, label: "Stacked bar chart unit test data")
        dataSet.drawIconsEnabled = false
        dataSet.iconsOffset = CGPoint(x: 0, y: -10.0)
        dataSet.colors = Array(arrayLiteral: NSUIColor(red: 46 / 255.0, green: 204 / 255.0, blue: 113 / 255.0, alpha: 1.0),
                               NSUIColor(red: 241 / 255.0, green: 196 / 255.0, blue: 15 / 255.0, alpha: 1.0),
                               NSUIColor(red: 231 / 255.0, green: 76 / 255.0, blue: 60 / 255.0, alpha: 1.0),
                               NSUIColor(red: 52 / 255.0, green: 152 / 255.0, blue: 219 / 255.0, alpha: 1.0))
        return dataSet
    }

    func setupDefaultChart(dataSets: [BarChartDataSet]) -> BarChartView {
        let data = BarChartData(dataSets: dataSets)
        data.barWidth = 0.85

        let chart = HorizontalBarChartView(frame: CGRect(x: 0, y: 0, width: 480, height: 350))
        chart.backgroundColor = NSUIColor.clear
        chart.data = data
        return chart
    }

    // MARK: Start Test

    func testDefaultValues() {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        assertChartSnapshot(matching: chart)
    }

    func testHidesValues() {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        dataSet.drawValuesEnabled = false
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testNotDrawValueAboveBars() {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.drawValueAboveBarEnabled = false
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testStackedDrawValues() {
        let dataEntries = setupStackedvaluesDataEntries()
        let dataSet = setupDefaultStackedDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testStackedNotDrawValues() {
        let dataEntries = setupStackedvaluesDataEntries()
        let dataSet = setupDefaultStackedDataSet(chartDataEntries: dataEntries)
        dataSet.drawValuesEnabled = false
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testStackedNotDrawValuesAboveBars() {
        let dataEntries = setupStackedvaluesDataEntries()
        let dataSet = setupDefaultStackedDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.drawValueAboveBarEnabled = false
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }
}
