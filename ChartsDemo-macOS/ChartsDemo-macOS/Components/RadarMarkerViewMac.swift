//
//  RadarMarkerViewMac.swift
//  ChartsDemo-OSX
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import Charts
#if canImport(AppKit)
    import AppKit
#endif

public class RadarMarkerViewMac: MarkerView {
    @IBOutlet var label: NSTextField!
    
    public override func awakeFromNib() {
        self.offset.x = -self.frame.size.width / 2.0
        self.offset.y = -self.frame.size.height - 7.0
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        label.stringValue = String.init(format: "%.1f %%", (entry.y * 100))
        needsLayout = true
    }
}
