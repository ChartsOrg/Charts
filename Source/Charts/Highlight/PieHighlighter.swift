//
//  PieHighlighter.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import CoreGraphics
import Foundation

open class PieHighlighter: PieRadarHighlighter {
    override open func closestHighlight(index: Int, x: CGFloat, y: CGFloat) -> Highlight? {
        guard let set = chart?.data?[0] else { return nil }
        let entry = set[index]
        
        return Highlight(x: Double(index), y: entry.y, xPx: x, yPx: y, dataSetIndex: 0, axis: set.axisDependency)
    }
}
