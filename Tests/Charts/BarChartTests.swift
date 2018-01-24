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
        
        for (i, value) in values.enumerated()
        {
            entries.append(BarChartDataEntry(x: Double(i), y: value, icon: UIImage(named: "icon", in: Bundle(for: self.classForCoder), compatibleWith: nil)))
        }
        
        dataSet = BarChartDataSet(values: entries, label: "Bar chart unit test data")
        dataSet.drawIconsEnabled = false
        dataSet.iconsOffset = CGPoint(x: 0, y: -10.0)

        let data = BarChartData(dataSet: dataSet)
        data.barWidth = 0.85
        
        chart = BarChartView(frame: CGRect(x: 0, y: 0, width: 480, height: 350))
        chart.backgroundColor = NSUIColor.clear
        chart.leftAxis.axisMinimum = 0.0
        chart.rightAxis.axisMinimum = 0.0
        chart.data = data
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
    
    func testDrawIcons()
    {
        dataSet.drawIconsEnabled = true
        FBSnapshotVerifyView(chart)
    }
}
