import XCTest
import FBSnapshotTestCase
@testable import Charts

class PieChartTests: FBSnapshotTestCase
{
    
    var chart: PieChartView!
    var dataSet: PieChartDataSet!
    
    override func setUp()
    {
        super.setUp()
        
        // Set to `true` to re-capture all snapshots
        self.recordMode = false
        
        // Sample data
        let values: [Double] = [11, 33, 81, 52, 97, 101, 75]
        
        var entries: [PieChartDataEntry] = Array()
        
        for value in values
        {
            entries.append(PieChartDataEntry(value: value, icon: UIImage(named: "icon", in: Bundle(for: self.classForCoder), compatibleWith: nil)))
        }
        
        dataSet = PieChartDataSet(entries: entries, label: "First unit test data")
        dataSet.drawIconsEnabled = false
        dataSet.iconsOffset = CGPoint(x: 0, y: 20.0)
        
        dataSet.colors = ChartColorTemplates.vordiplom()
            + ChartColorTemplates.joyful()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.liberty()
            + ChartColorTemplates.pastel()
            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        
        chart = PieChartView(frame: CGRect(x: 0, y: 0, width: 480, height: 350))
        chart.backgroundColor = NSUIColor.clear
        chart.centerText = "PieChart Unit Test"
        chart.data = PieChartData(dataSet: dataSet)
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDefaultValues()
    {
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    
    func testHidesValues()
    {
        dataSet.drawValuesEnabled = false
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    
    func testDrawIcons()
    {
        dataSet.drawIconsEnabled = true
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    
    func testHideCenterLabel()
    {
        chart.drawCenterTextEnabled = false
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
}
