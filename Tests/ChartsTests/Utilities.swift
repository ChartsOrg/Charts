import Charts
import SnapshotTesting
import UIKit

private enum Snapshot {
    static let tolerance: Float = 0.001

    static func identifier(_ size: CGSize) -> String {
        #if os(tvOS)
            let identifier = "tvOS"
        #elseif os(iOS)
            let identifier = "iOS"
        #elseif os(OSX)
            let identifier = "macOS"
        #else
            let identifier = ""
        #endif

        return "\(identifier)_\(size.width)_\(size.height)"
    }
}

func assertChartSnapshot<Value: ChartViewBase>(
    matching value: @autoclosure () throws -> Value,
    record recording: Bool = false,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
) {
    assertSnapshot(
        matching: try value(),
        as: .image,
        record: recording,
        timeout: timeout,
        file: file,
        testName: testName + Snapshot.identifier(UIScreen.main.bounds.size),
        line: line
    )
}
