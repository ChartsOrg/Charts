//
//  ChartHighlighter.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 26/7/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

public class ChartHighlighter : NSObject
{
    /// instance of the data-provider
    public weak var chart: BarLineChartViewBase?
    
    public init(chart: BarLineChartViewBase)
    {
        self.chart = chart
    }
    
    /// Returns a Highlight object corresponding to the given x- and y- touch positions in pixels.
    /// - parameter x:
    /// - parameter y:
    /// - returns:
    public func getHighlight(x x: CGFloat, y: CGFloat) -> ChartHighlight?
    {
        let xIndex = getXIndex(x)
        
        guard let
            selectionDetail = getSelectionDetail(xIndex: xIndex, y: y, dataSetIndex: nil)
            else { return nil }
        
        return ChartHighlight(xIndex: xIndex, value: selectionDetail.value, dataIndex: selectionDetail.dataIndex, dataSetIndex: selectionDetail.dataSetIndex, stackIndex: -1)
    }
    
    /// Returns the corresponding x-index for a given touch-position in pixels.
    /// - parameter x:
    /// - returns:
    public func getXIndex(x: CGFloat) -> Int
    {
        // create an array of the touch-point
        var pt = CGPoint(x: x, y: 0.0)
        
        // take any transformer to determine the x-axis value
        self.chart?.getTransformer(ChartYAxis.AxisDependency.Left).pixelToValue(&pt)
        
        return Int(round(pt.x))
    }
    
    /// Returns the corresponding ChartSelectionDetail for a given xIndex and y-touch position in pixels.
    /// - parameter xIndex:
    /// - parameter y:
    /// - parameter dataSetIndex: A dataset index to look at - or nil, to figure that out automatically
    /// - returns:
    public func getSelectionDetail(xIndex xIndex: Int, y: CGFloat, dataSetIndex: Int?) -> ChartSelectionDetail?
    {
        let valsAtIndex = getSelectionDetailsAtIndex(xIndex, dataSetIndex: dataSetIndex)
        
        let leftdist = ChartUtils.getMinimumDistance(valsAtIndex, y: y, axis: ChartYAxis.AxisDependency.Left)
        let rightdist = ChartUtils.getMinimumDistance(valsAtIndex, y: y, axis: ChartYAxis.AxisDependency.Right)
        
        let axis = leftdist < rightdist ? ChartYAxis.AxisDependency.Left : ChartYAxis.AxisDependency.Right
        
        let detail = ChartUtils.closestSelectionDetailByPixelY(valsAtIndex: valsAtIndex, y: y, axis: axis)
        
        return detail
    }
    
    /// Returns a list of SelectionDetail object corresponding to the given xIndex.
    /// - parameter xIndex:
    /// - parameter dataSetIndex: A dataset index to look at - or nil, to figure that out automatically
    /// - returns:
    public func getSelectionDetailsAtIndex(xIndex: Int, dataSetIndex: Int?) -> [ChartSelectionDetail]
    {
        var vals = [ChartSelectionDetail]()
        var pt = CGPoint()
        
        guard let
            data = self.chart?.data
            else { return vals }
        
        for i in 0 ..< data.dataSetCount
        {
            if dataSetIndex != nil && dataSetIndex != i
            {
                continue
            }
            
            let dataSet = data.getDataSetByIndex(i)
            
            // dont include datasets that cannot be highlighted
            if !dataSet.isHighlightEnabled
            {
                continue
            }
            
            // extract all y-values from all DataSets at the given x-index
            let yVals: [Double] = dataSet.yValsForXIndex(xIndex)
            for yVal in yVals
            {
                pt.y = CGFloat(yVal)
                
                self.chart!.getTransformer(dataSet.axisDependency).pointValueToPixel(&pt)
                
                if !pt.y.isNaN
                {
                    vals.append(ChartSelectionDetail(y: pt.y, value: yVal, dataSetIndex: i, dataSet: dataSet))
                }
            }
        }
        
        return vals
    }
}
