@testable import Charts
import SnapshotTesting
import XCTest

class BarChartTests: XCTestCase {
    private lazy var icon = UIImage(named: "icon", in: Bundle(for: classForCoder), compatibleWith: nil)!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: Prepare

    func setupCustomValuesDataEntries(values: [Double]) -> [ChartDataEntry] {
        var entries: [ChartDataEntry] = Array()
        for (i, value) in values.enumerated() {
            entries.append(BarChartDataEntry(x: Double(i), y: value, icon: icon))
        }
        return entries
    }

    func setupDefaultValuesDataEntries() -> [ChartDataEntry] {
        let values: [Double] = [8, 104, -81, 93, 52, -44, 97, 101, -75, 28,
                                -76, 25, 20, -13, 52, 44, -57, 23, 45, -91,
                                99, 14, -84, 48, 40, -71, 106, 41, -45, 61]
        return setupCustomValuesDataEntries(values: values)
    }

    func setupPositiveValuesDataEntries() -> [ChartDataEntry] {
        let values: [Double] = [8, 104, 81, 93, 52, 44, 97, 101, 75, 28,
                                76, 25, 20, 13, 52, 44, 57, 23, 45, 91,
                                99, 14, 84, 48, 40, 71, 106, 41, 45, 61]
        return setupCustomValuesDataEntries(values: values)
    }

    func setupNegativeValuesDataEntries() -> [ChartDataEntry] {
        let values: [Double] = [-8, -104, -81, -93, -52, -44, -97, -101, -75, -28,
                                -76, -25, -20, -13, -52, -44, -57, -23, -45, -91,
                                -99, -14, -84, -48, -40, -71, -106, -41, -45, -61]
        return setupCustomValuesDataEntries(values: values)
    }

    func setupZeroValuesDataEntries() -> [ChartDataEntry] {
        let values = [Double](repeating: 0.0, count: 30)
        return setupCustomValuesDataEntries(values: values)
    }

    func setupStackedValuesDataEntries() -> [ChartDataEntry] {
        var entries: [ChartDataEntry] = Array()
        entries.append(BarChartDataEntry(x: 0, yValues: [28, 50, 60, 30, 42], icon: icon))
        entries.append(BarChartDataEntry(x: 1, yValues: [-20, -36, -52, -40, -15], icon: icon))
        entries.append(BarChartDataEntry(x: 2, yValues: [10, 30, 40, 90, 72], icon: icon))
        entries.append(BarChartDataEntry(x: 3, yValues: [-40, -50, -30, -60, -20], icon: icon))
        entries.append(BarChartDataEntry(x: 4, yValues: [10, 40, 60, 45, 62], icon: icon))
        return entries
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

    func setupDefaultDataSet(chartDataEntries: [ChartDataEntry]) -> BarChartDataSet {
        let dataSet = BarChartDataSet(entries: chartDataEntries, label: "Bar chart unit test data")
        dataSet.drawIconsEnabled = false
        dataSet.iconsOffset = CGPoint(x: 0, y: -10.0)
        return dataSet
    }

    func setupDefaultChart(dataSets: [BarChartDataSet]) -> BarChartView {
        let data = BarChartData(dataSets: dataSets)
        data.barWidth = 0.85

        let chart = BarChartView(frame: CGRect(x: 0, y: 0, width: 480, height: 350))
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

    func testDefaultBarDataSetLabels() {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = BarChartDataSet(entries: dataEntries)
        dataSet.drawIconsEnabled = false
        let chart = setupDefaultChart(dataSets: [dataSet])
        assertChartSnapshot(matching: chart)
    }

    func testZeroValues() {
        let dataEntries = setupZeroValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        assertChartSnapshot(matching: chart)
    }

    func testPositiveValues() {
        let dataEntries = setupPositiveValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        assertChartSnapshot(matching: chart)
    }

    func testPositiveValuesWithCustomAxisMaximum() {
        let dataEntries = setupPositiveValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMaximum = 50
        chart.clipValuesToContentEnabled = true
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testPositiveValuesWithCustomAxisMaximum2() {
        let dataEntries = setupPositiveValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMaximum = -10
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testPositiveValuesWithCustomAxisMinimum() {
        let dataEntries = setupPositiveValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMinimum = 50
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testPositiveValuesWithCustomAxisMinimum2() {
        let dataEntries = setupPositiveValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMinimum = 110
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testPositiveValuesWithCustomAxisMaximumAndCustomAxisMaximum() {
        let dataEntries = setupPositiveValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        // If min is greater than max, then min and max will be exchanged.
        chart.leftAxis.axisMaximum = 200
        chart.leftAxis.axisMinimum = -10
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testNegativeValues() {
        let dataEntries = setupNegativeValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        assertChartSnapshot(matching: chart)
    }

    func testNegativeValuesWithCustomAxisMaximum() {
        let dataEntries = setupNegativeValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMaximum = 10
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testNegativeValuesWithCustomAxisMaximum2() {
        let dataEntries = setupNegativeValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMaximum = -150
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testNegativeValuesWithCustomAxisMinimum() {
        let dataEntries = setupNegativeValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMinimum = -200
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testNegativeValuesWithCustomAxisMinimum2() {
        let dataEntries = setupNegativeValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMinimum = 10
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testNegativeValuesWithCustomAxisMaximumAndCustomAxisMaximum() {
        let dataEntries = setupNegativeValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        // If min is greater than max, then min and max will be exchanged.
        chart.leftAxis.axisMaximum = 10
        chart.leftAxis.axisMinimum = -200
        chart.notifyDataSetChanged()
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
        let dataEntries = setupStackedValuesDataEntries()
        let dataSet = setupDefaultStackedDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testStackedNotDrawValues() {
        let dataEntries = setupStackedValuesDataEntries()
        let dataSet = setupDefaultStackedDataSet(chartDataEntries: dataEntries)
        dataSet.drawValuesEnabled = false
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testStackedNotDrawValuesAboveBars() {
        let dataEntries = setupStackedValuesDataEntries()
        let dataSet = setupDefaultStackedDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.drawValueAboveBarEnabled = false
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testHideLeftAxis() {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.enabled = false
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testHideRightAxis() {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.rightAxis.enabled = false
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testInvertedLeftAxis() {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.inverted = true
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testInvertedLeftAxisWithNegativeValues() {
        let dataEntries = setupNegativeValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.inverted = true
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testInvertedLeftAxisWithPositiveValues() {
        let dataEntries = setupPositiveValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.inverted = true
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testInvertedRightAxis() {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        dataSet.axisDependency = .right
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.rightAxis.inverted = true
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testInvertedRightAxisWithNegativeValues() {
        let dataEntries = setupNegativeValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        dataSet.axisDependency = .right
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.rightAxis.inverted = true
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testInvertedRightAxisWithPositiveValues() {
        let dataEntries = setupPositiveValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        dataSet.axisDependency = .right
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.rightAxis.inverted = true
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testHideHorizontalGridlines() {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.drawGridLinesEnabled = false
        chart.rightAxis.drawGridLinesEnabled = false
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testHideVerticalGridlines() {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.xAxis.drawGridLinesEnabled = false
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }

    func testDrawIcons() {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        dataSet.drawIconsEnabled = true
        chart.notifyDataSetChanged()
        assertChartSnapshot(matching: chart)
    }
}
