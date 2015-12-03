@testable import Charts

class LineChartTests: BaseChartTest
{
    
    var chart: LineChartView!
    var dataSet: LineChartDataSet!
    
    override func setUp()
    {
        super.setUp()
        
        for (i, value) in values.enumerate()
        {
            entries.append(ChartDataEntry.init(value: value, xIndex: i))
            xValues.append("\(i)")
        }
        
        dataSet = LineChartDataSet(yVals: entries, label: "First unit test data")
        
        chart = LineChartView(frame: CGRectMake(0, 0, 480, 350))
        chart.data = LineChartData(xVals: xValues, dataSet: dataSet)
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
        dataSet.drawCubicEnabled = true
        FBSnapshotVerifyView(chart)
    }
    
    func testDoesntDrawCircleHole()
    {
        dataSet.drawCircleHoleEnabled = false
        FBSnapshotVerifyView(chart)
    }
}
