//
//  RadarChartDataSet.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics


public class RadarChartDataSet: LineRadarChartDataSet, IRadarChartDataSet
{
    private func initialize()
    {
        self.valueFont = NSUIFont.systemFontOfSize(13.0)
    }
    
    public required init()
    {
        super.init()
        initialize()
    }
    
    public required override init(values: [ChartDataEntry]?, label: String?)
    {
        super.init(values: values, label: label)
        initialize()
    }
    
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// flag indicating whether highlight circle should be drawn or not
    /// **default**: false
    public var drawHighlightCircleEnabled: Bool = false
    
    /// - returns: `true` if highlight circle should be drawn, `false` ifnot
    public var isDrawHighlightCircleEnabled: Bool { return drawHighlightCircleEnabled }
    
    public var highlightCircleFillColor: NSUIColor? = NSUIColor.whiteColor()
    
    /// The stroke color for highlight circle.
    /// If `nil`, the color of the dataset is taken.
    public var highlightCircleStrokeColor: NSUIColor?
    
    public var highlightCircleStrokeAlpha: CGFloat = 0.3
    
    public var highlightCircleInnerRadius: CGFloat = 3.0
    
    public var highlightCircleOuterRadius: CGFloat = 4.0
    
    public var highlightCircleStrokeWidth: CGFloat = 2.0
}