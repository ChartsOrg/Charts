@testable import Charts
import SnapshotTesting
import XCTest

class LineChartTests: XCTestCase {
    private lazy var icon = UIImage(named: "icon", in: Bundle(for: classForCoder), compatibleWith: nil)!

    var chart: LineChartView!
    var dataSet: LineChartDataSet!

    override func setUp() {
        super.setUp()

        // Set to `true` to re-capture all snapshots
        isRecording = false

        // Sample data
        let values: [Double] = [8, 104, 81, 93, 52, 44, 97, 101, 75, 28,
                                76, 25, 20, 13, 52, 44, 57, 23, 45, 91,
                                99, 14, 84, 48, 40, 71, 106, 41, 45, 61]

        var entries: [ChartDataEntry] = Array()

        for (i, value) in values.enumerated() {
            entries.append(ChartDataEntry(x: Double(i), y: value, icon: icon))
        }

        dataSet = LineChartDataSet(entries: entries, label: "First unit test data")
        dataSet.drawIconsEnabled = false
        dataSet.iconsOffset = CGPoint(x: 0, y: 20.0)

        chart = LineChartView(frame: CGRect(x: 0, y: 0, width: 480, height: 350))
        chart.backgroundColor = NSUIColor.clear
        chart.leftAxis.axisMinimum = 0.0
        chart.rightAxis.axisMinimum = 0.0
        chart.data = LineChartData(dataSet: dataSet)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDefaultValues() {
        assertChartSnapshot(matching: chart)
    }

    func testHidesValues() {
        dataSet.drawValuesEnabled = false
        assertChartSnapshot(matching: chart)
    }

    func testDoesntDrawCircles() {
        dataSet.drawCirclesEnabled = false
        assertChartSnapshot(matching: chart)
    }

    func testIsCubic() {
        dataSet.mode = LineChartDataSet.Mode.cubicBezier
        assertChartSnapshot(matching: chart)
    }

    func testDoesntDrawCircleHole() {
        dataSet.drawCircleHoleEnabled = false
        assertChartSnapshot(matching: chart)
    }

    func testDrawIcons() {
        dataSet.drawIconsEnabled = true
        assertChartSnapshot(matching: chart)
    }
}
