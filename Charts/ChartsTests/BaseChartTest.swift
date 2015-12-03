import XCTest
import FBSnapshotTestCase
@testable import Charts

class BaseChartTest: FBSnapshotTestCase
{
    
    var values: [Double] = []
    var entries: [ChartDataEntry] = []
    var xValues: [String] = []
    
    override func setUp()
    {
        super.setUp()
        
        // Set to `true` to re-capture all snapshots
        self.recordMode = false
        
        // Sample data
        values = [8, 104, 81, 93, 52, 44, 97, 101, 75, 28,
            76, 25, 20, 13, 52, 44, 57, 23, 45, 91,
            99, 14, 84, 48, 40, 71, 106, 41, 45, 61]
        
        entries = Array()
        xValues = Array()
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
