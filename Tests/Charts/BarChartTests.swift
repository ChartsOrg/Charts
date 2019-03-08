import XCTest
import FBSnapshotTestCase
@testable import Charts

class BarChartTests: FBSnapshotTestCase
{
    override func setUp()
    {
        super.setUp()
        
        // Set to `true` to re-capture all snapshots
        self.recordMode = false
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //MARK: Prepare
    func setupCustomValuesDataEntries(values: [Double]) -> [ChartDataEntry]
    {
        var entries: [ChartDataEntry] = Array()
        for (i, value) in values.enumerated()
        {
            entries.append(BarChartDataEntry(x: Double(i), y: value, icon: UIImage(named: "icon", in: Bundle(for: self.classForCoder), compatibleWith: nil)))
        }
        return entries
    }

    func setupDefaultValuesDataEntries() -> [ChartDataEntry]
    {
        let values: [Double] = [8, 104, -81, 93, 52, -44, 97, 101, -75, 28,
                                -76, 25, 20, -13, 52, 44, -57, 23, 45, -91,
                                99, 14, -84, 48, 40, -71, 106, 41, -45, 61]
        return setupCustomValuesDataEntries(values: values)
    }

    func setupPositiveValuesDataEntries() -> [ChartDataEntry]
    {
        let values: [Double] = [8, 104, 81, 93, 52, 44, 97, 101, 75, 28,
                                76, 25, 20, 13, 52, 44, 57, 23, 45, 91,
                                99, 14, 84, 48, 40, 71, 106, 41, 45, 61]
        return setupCustomValuesDataEntries(values: values)
    }

    func setupNegativeValuesDataEntries() -> [ChartDataEntry]
    {
        let values: [Double] = [-8, -104, -81, -93, -52, -44, -97, -101, -75, -28,
                                -76, -25, -20, -13, -52, -44, -57, -23, -45, -91,
                                -99, -14, -84, -48, -40, -71, -106, -41, -45, -61]
        return setupCustomValuesDataEntries(values: values)
    }

    func setupZeroValuesDataEntries() -> [ChartDataEntry]
    {
        let values = [Double](repeating: 0.0, count: 30)
        return setupCustomValuesDataEntries(values: values)
    }

    func setupDefaultDataSet(chartDataEntries: [ChartDataEntry]) -> BarChartDataSet
    {
        let dataSet = BarChartDataSet(entries: chartDataEntries, label: "Bar chart unit test data")
        dataSet.drawIconsEnabled = false
        dataSet.iconsOffset = CGPoint(x: 0, y: -10.0)
        return dataSet
    }

    func setupDefaultChart(dataSets: [BarChartDataSet]) -> BarChartView
    {
        let data = BarChartData(dataSets: dataSets)
        data.barWidth = 0.85
        
        let chart = BarChartView(frame: CGRect(x: 0, y: 0, width: 480, height: 350))
        chart.backgroundColor = NSUIColor.clear
        chart.data = data
        return chart
    }
    
    //MARK: Start Test
    func testDefaultValues()
    {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testZeroValues()
    {
        let dataEntries = setupZeroValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testPositiveValues()
    {
        let dataEntries = setupPositiveValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testPositiveValuesWithCustomAxisMaximum()
    {
        let dataEntries = setupPositiveValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMaximum = 50
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testPositiveValuesWithCustomAxisMaximum2()
    {
        let dataEntries = setupPositiveValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMaximum = -10
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testPositiveValuesWithCustomAxisMinimum()
    {
        let dataEntries = setupPositiveValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMinimum = 50
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testPositiveValuesWithCustomAxisMinimum2()
    {
        let dataEntries = setupPositiveValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMinimum = 110
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testPositiveValuesWithCustomAxisMaximumAndCustomAxisMaximum()
    {
        let dataEntries = setupPositiveValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        //If min is greater than max, then min and max will be exchanged.
        chart.leftAxis.axisMaximum = 200
        chart.leftAxis.axisMinimum = -10
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testNegativeValues()
    {
        let dataEntries = setupNegativeValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testNegativeValuesWithCustomAxisMaximum()
    {
        let dataEntries = setupNegativeValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMaximum = 10
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testNegativeValuesWithCustomAxisMaximum2()
    {
        let dataEntries = setupNegativeValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMaximum = -150
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }


    func testNegativeValuesWithCustomAxisMinimum()
    {
        let dataEntries = setupNegativeValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMinimum = -200
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testNegativeValuesWithCustomAxisMinimum2()
    {
        let dataEntries = setupNegativeValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMinimum = 10
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testNegativeValuesWithCustomAxisMaximumAndCustomAxisMaximum()
    {
        let dataEntries = setupNegativeValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        //If min is greater than max, then min and max will be exchanged.
        chart.leftAxis.axisMaximum = 10
        chart.leftAxis.axisMinimum = -200
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testHidesValues()
    {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        dataSet.drawValuesEnabled = false
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    
    func testHideLeftAxis()
    {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.enabled = false
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    
    func testHideRightAxis()
    {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.rightAxis.enabled = false
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testInvertedLeftAxis()
    {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.inverted = true
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testInvertedLeftAxisWithNegativeValues()
    {
        let dataEntries = setupNegativeValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.inverted = true
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testInvertedLeftAxisWithPositiveValues()
    {
        let dataEntries = setupPositiveValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.inverted = true
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testInvertedRightAxis()
    {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        dataSet.axisDependency = .right
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.rightAxis.inverted = true
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testInvertedRightAxisWithNegativeValues()
    {
        let dataEntries = setupNegativeValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        dataSet.axisDependency = .right
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.rightAxis.inverted = true
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }

    func testInvertedRightAxisWithPositiveValues()
    {
        let dataEntries = setupPositiveValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        dataSet.axisDependency = .right
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.rightAxis.inverted = true
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    
    func testHideHorizontalGridlines()
    {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.leftAxis.drawGridLinesEnabled = false
        chart.rightAxis.drawGridLinesEnabled = false
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    
    func testHideVerticalGridlines()
    {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        chart.xAxis.drawGridLinesEnabled = false
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    
    func testDrawIcons()
    {
        let dataEntries = setupDefaultValuesDataEntries()
        let dataSet = setupDefaultDataSet(chartDataEntries: dataEntries)
        let chart = setupDefaultChart(dataSets: [dataSet])
        dataSet.drawIconsEnabled = true
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
}
