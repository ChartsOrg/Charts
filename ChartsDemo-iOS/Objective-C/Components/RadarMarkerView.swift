//
//  RadarMarkerView.swift
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Charts
import Foundation
#if canImport(UIKit)
    import UIKit
#endif

open class RadarMarkerView: MarkerView {
    @IBOutlet var label: UILabel?

    override open func awakeFromNib() {
        offset.x = -frame.size.width / 2.0
        offset.y = -frame.size.height - 7.0
    }

    override open func refreshContent(entry: ChartDataEntry, highlight _: Highlight) {
        label?.text = String(format: "%d %%", Int(round(entry.y)))
        layoutIfNeeded()
    }
}
