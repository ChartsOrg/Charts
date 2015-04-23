//
//  BarChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics.CGBase
import UIKit.UIColor

public class BarChartDataSet: BarLineScatterCandleChartDataSet
{
    /// space indicator between the bars in percentage of the whole width of one value (0.15 == 15% of bar width)
    public var barSpace: CGFloat = 0.15
    
    /// the maximum number of bars that are stacked upon each other, this value
    /// is calculated from the Entries that are added to the DataSet
    private var _stackSize = 1
    
    /// the color used for drawing the bar-shadows. The bar shadows is a surface behind the bar that indicates the maximum value
    public var barShadowColor = UIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0)
    
    /// the alpha value (transparency) that is used for drawing the highlight indicator bar. min = 0.0 (fully transparent), max = 1.0 (fully opaque)
    public var highLightAlpha = CGFloat(120.0 / 255.0)
    
    /// the overall entry count, including counting each stack-value individually
    private var _entryCountStacks = 0
    
    /// array of labels used to describe the different values of the stacked bars
    public var stackLabels: [String] = ["Stack"]
    
    public override init(yVals: [ChartDataEntry]?, label: String)
    {
        super.init(yVals: yVals, label: label);
        
        self.highlightColor = UIColor.blackColor();
        
        self.calcStackSize(yVals as! [BarChartDataEntry]?);
        self.calcEntryCountIncludingStacks(yVals as! [BarChartDataEntry]?);
    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        var copy = super.copyWithZone(zone) as! BarChartDataSet;
        copy.barSpace = barSpace;
        copy._stackSize = _stackSize;
        copy.barShadowColor = barShadowColor;
        copy.highLightAlpha = highLightAlpha;
        copy._entryCountStacks = _entryCountStacks;
        copy.stackLabels = stackLabels;
        return copy;
    }
    
    /// Calculates the total number of entries this DataSet represents, including
    /// stacks. All values belonging to a stack are calculated separately.
    private func calcEntryCountIncludingStacks(yVals: [BarChartDataEntry]!)
    {
        _entryCountStacks = 0;
        
        for (var i = 0; i < yVals.count; i++)
        {
            var vals = yVals[i].values;
            
            if (vals == nil)
            {
                _entryCountStacks++;
            }
            else
            {
                _entryCountStacks += vals.count;
            }
        }
    }
    
    /// calculates the maximum stacksize that occurs in the Entries array of this DataSet
    private func calcStackSize(yVals: [BarChartDataEntry]!)
    {
        for (var i = 0; i < yVals.count; i++)
        {
            var vals = yVals[i].values;
            
            if (vals != nil && vals.count > _stackSize)
            {
                _stackSize = vals.count;
            }
        }
    }
    
    /// Returns the maximum number of bars that can be stacked upon another in this DataSet.
    public var stackSize: Int
    {
        return _stackSize;
    }
    
    /// Returns true if this DataSet is stacked (stacksize > 1) or not.
    public var isStacked: Bool
    {
        return _stackSize > 1 ? true : false;
    }
    
    /// returns the overall entry count, including counting each stack-value individually
    public var entryCountStacks: Int
    {
        return _entryCountStacks;
    }
}