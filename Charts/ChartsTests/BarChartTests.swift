@testable import Charts

class BarChartTests: BaseChartTest
{
    
    var chart: BarChartView!
    var dataSet: BarChartDataSet!
    
    override func setUp()
    {
        super.setUp()
        
        for (i, value) in values.enumerate()
        {
            entries.append(BarChartDataEntry.init(value: value, xIndex: i))
            xValues.append("\(i)")
        }
        
        dataSet = BarChartDataSet(yVals: entries, label: "Bar chart unit test data")
        
        chart = BarChartView(frame: CGRectMake(0, 0, 480, 350))
        chart.data = BarChartData(xVals: xValues, dataSet: dataSet)
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
        chart.leftAxis.drawAxisLineEnabled = false
        FBSnapshotVerifyView(chart)
    }
    
    func testHideRightAxis()
    {
        chart.rightAxis.drawAxisLineEnabled = false
        FBSnapshotVerifyView(chart)
    }
    
    func testHideLeftAxisGridlines()
    {
        chart.leftAxis.drawGridLinesEnabled = false
        FBSnapshotVerifyView(chart)
    }
    
    func testHideRightAxisGridlines()
    {
        chart.rightAxis.drawGridLinesEnabled = false
        FBSnapshotVerifyView(chart)
    }
}
