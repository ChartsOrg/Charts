import XCTest
import FBSnapshotTestCase
@testable import Charts

class LineChartTests: FBSnapshotTestCase
{
    
    var chart: LineChartView!
    var dataSet: LineChartDataSet!
    
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
        
        for (i, value) in values.enumerate()
        {
            entries.append(ChartDataEntry(x: Double(i), y: value))
        }
        
        dataSet = LineChartDataSet(values: entries, label: "First unit test data")
        
        chart = LineChartView(frame: CGRectMake(0, 0, 480, 350))
        chart.leftAxis.axisMinimum = 0.0
        chart.rightAxis.axisMinimum = 0.0
        chart.data = LineChartData(dataSet: dataSet)
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
    
    func testDoesntDrawCircles()
    {
        dataSet.drawCirclesEnabled = false
        FBSnapshotVerifyView(chart)
    }
    
    func testIsCubic()
    {
        dataSet.mode = LineChartDataSet.Mode.CubicBezier
        FBSnapshotVerifyView(chart)
    }
    
    func testDoesntDrawCircleHole()
    {
        dataSet.drawCircleHoleEnabled = false
        FBSnapshotVerifyView(chart)
    }
}
