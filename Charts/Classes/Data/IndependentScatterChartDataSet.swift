//
//  ScatterChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 26/2/15.
//  derived from ScatterChart by Gerard J. Cerchio
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

public class IndependentScatterChartDataSet: BarLineScatterCandleChartDataSet
{
    @objc
    public enum IndependentScatterShape: Int
    {
        case Cross
        case Triangle
        case Circle
        case Square
        case Custom
    }
    
    public var scatterShapeSize = CGFloat(15.0)
    public var scatterShape = IndependentScatterShape.Square
    public var customScatterShape: CGPath?
    public var valueIsIndex = false;
    public var drawLinesEnabled = false;

    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        var copy = super.copyWithZone(zone) as! IndependentScatterChartDataSet
        copy.scatterShapeSize = scatterShapeSize
        copy.scatterShape = scatterShape
        copy.customScatterShape = customScatterShape
        return copy
    }
    
    public var isDrawLinesEnabled: Bool
        {
            return drawValuesEnabled
    }
}
