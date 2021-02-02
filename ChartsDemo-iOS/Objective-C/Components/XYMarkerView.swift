//
//  XYMarkerView.swift
//  ChartsDemo
//  Copyright © 2016 dcg. All rights reserved.
//

import Charts
import Foundation
#if canImport(UIKit)
    import UIKit
#endif

open class XYMarkerView: BalloonMarker {
    open var xAxisValueFormatter: AxisValueFormatter?
    fileprivate var yFormatter = NumberFormatter()

    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets,
                xAxisValueFormatter: AxisValueFormatter)
    {
        super.init(color: color, font: font, textColor: textColor, insets: insets)
        self.xAxisValueFormatter = xAxisValueFormatter
        yFormatter.minimumFractionDigits = 1
        yFormatter.maximumFractionDigits = 1
    }

    override open func refreshContent(entry: ChartDataEntry, highlight _: Highlight) {
        setLabel("x: " + xAxisValueFormatter!.stringForValue(entry.x, axis: nil) + ", y: " + yFormatter.string(from: NSNumber(floatLiteral: entry.y))!)
    }
}
