//
//  TimeLineChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 26/2/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

public class TimeLineChartDataSet: LineChartDataSet, ITimeLineChartDataSet
{
    // TODO: Not yet used but will be needed for scaling purposes
    internal var _xNumericValMax = Double(0.0)
    internal var _xNumericValMin = Double(0.0)
    
    public required init()
    {
        super.init()
    }
    
    public override init(yVals: [ChartDataEntry]?, label: String?)
    {
        super.init(yVals: yVals, label: label)
    }
    
    // TODO: Not yet implemented
    public override func calcMinMax(start start: Int, end: Int)
    {
        // This will need to be changed to find Min and Max for xNumericVals for scaling purposes
        super.calcMinMax(start: start, end: end)
    }

    // MARK: - Data functions and accessors

    /// - returns: the minimum y-value this DataSet holds
    public var xNumericValMin: Double { return _xNumericValMin }
    
    /// - returns: the maximum y-value this DataSet holds
    public var xNumericValMax: Double { return _xNumericValMax }
    
    /// - returns: the xNumericValue of the Entry object at the given xIndex. Returns NaN if no xNumericValue is at the given x-index.
    /// TODO: Not yet implemented
    public func xNumericValForXIndex(x: Int) -> Double
    {
        return 0.0
    }
    

    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! TimeLineChartDataSet
        copy.circleColors = circleColors
        copy.circleRadius = circleRadius
        copy.cubicIntensity = cubicIntensity
        copy.lineDashPhase = lineDashPhase
        copy.lineDashLengths = lineDashLengths
        copy.drawCirclesEnabled = drawCirclesEnabled
        copy.drawCubicEnabled = drawCubicEnabled
        copy.drawSteppedEnabled = drawSteppedEnabled
        copy._xNumericValMax = _xNumericValMax
        copy._xNumericValMin = _xNumericValMin
        return copy
    }
}
