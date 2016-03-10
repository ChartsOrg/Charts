import XCTest
import FBSnapshotTestCase
@testable import Charts

class BarChartTests: FBSnapshotTestCase
{
    
    var chart: BarChartView!
    var dataSet: BarChartDataSet!
    
    override func setUp()
    {
        super.setUp()
        
        // Set to `true` to re-capture all snapshots
        self.recordMode = false
        
        // Sample data
        let values: [Double] = [8, 104, 81, 93, 52, 44, 97, 101, 75, 28,
            76, 25, 20, 13, 52, 44, 57, 23, 45, 91,
            99, 14, 84, 48, 40, 71, 106, 41, 45, 61]
        
        var entries: [ChartDataEntry] = Array()
        var xValues: [String] = Array()
        
        for (i, value) in values.enumerate()
        {
            entries.append(BarChartDataEntry.init(value: value, xIndex: i))
            xValues.append("\(i)")
        }
        
        dataSet = BarChartDataSet(yVals: entries, label: "Bar chart unit test data")
        
        chart = BarChartView(frame: CGRectMake(0, 0, 480, 350))
        chart.leftAxis.customAxisMin = 0.0
        chart.rightAxis.customAxisMin = 0.0
        chart.data = BarChartData(xVals: xValues, dataSet: dataSet)
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDefaultValues()
    {
        FBSnapshotVerifyView(chart)
    }
    
    func testHidesValues()
    {
        dataSet.drawValuesEnabled = false
        FBSnapshotVerifyView(chart)
    }
    
    func testHideLeftAxis()
    {
        chart.leftAxis.enabled = false
        FBSnapshotVerifyView(chart)
    }
    
    func testHideRightAxis()
    {
        chart.rightAxis.enabled = false
        FBSnapshotVerifyView(chart)
    }
    
    func testHideHorizontalGridlines()
    {
        chart.leftAxis.drawGridLinesEnabled = false
        chart.rightAxis.drawGridLinesEnabled = false
        FBSnapshotVerifyView(chart)
    }
    
    func testHideVerticalGridlines()
    {
        chart.xAxis.drawGridLinesEnabled = false
        FBSnapshotVerifyView(chart)
    }
}
