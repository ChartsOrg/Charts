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
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

public protocol ChartHighlighter {
    weak var chart: BarLineChartViewBase? { get set }

    /// Returns a Highlight object corresponding to the given x- and y- touch positions in pixels.
    /// - parameter x:
    /// - parameter y:
    /// - returns:
    func getHighlight(x x: Double, y: Double) -> ChartHighlight?

    /// Returns the corresponding x-index for a given touch-position in pixels.
    /// - parameter x:
    /// - returns:
    func getXIndex(x: Double) -> Int

    /// Returns the corresponding dataset-index for a given xIndex and xy-touch position in pixels.
    /// - parameter xIndex:
    /// - parameter x:
    /// - parameter y:
    /// - returns:
    func getDataSetIndex(xIndex xIndex: Int, x: Double, y: Double) -> Int

    /// Returns a list of SelectionDetail object corresponding to the given xIndex.
    /// - parameter xIndex:
    /// - returns:
    func getSelectionDetailsAtIndex(xIndex: Int) -> [ChartSelectionDetail]
}

// MARK: - Default implementation

internal class DefaultChartHighlighter: ChartHighlighter
{
    weak var chart: BarLineChartViewBase?

    init(chart: BarLineChartViewBase)
    {
        self.chart = chart
    }
}

public extension ChartHighlighter {

    func getHighlight(x x: Double, y: Double) -> ChartHighlight?
    {
        return _getHighlight(x: x, y: y)
    }

    internal func _getHighlight(x x: Double, y: Double) -> ChartHighlight?
    {
        let xIndex = getXIndex(x)
        if (xIndex == -Int.max)
        {
            return nil
        }
        
        let dataSetIndex = getDataSetIndex(xIndex: xIndex, x: x, y: y)
        if (dataSetIndex == -Int.max)
        {
            return nil
        }
        
        return ChartHighlight(xIndex: xIndex, dataSetIndex: dataSetIndex)
    }

    func getXIndex(x: Double) -> Int
    {
        return _getXIndex(x)
    }

    internal func _getXIndex(x: Double) -> Int
    {
        // create an array of the touch-point
        var pt = CGPoint(x: x, y: 0.0)

        // take any transformer to determine the x-axis value
        self.chart?.getTransformer(ChartYAxis.AxisDependency.Left).pixelToValue(&pt)

        return Int(round(pt.x))
    }
    
    func getDataSetIndex(xIndex xIndex: Int, x: Double, y: Double) -> Int
    {
        let valsAtIndex = getSelectionDetailsAtIndex(xIndex)
        
        let leftdist = ChartUtils.getMinimumDistance(valsAtIndex, val: y, axis: ChartYAxis.AxisDependency.Left)
        let rightdist = ChartUtils.getMinimumDistance(valsAtIndex, val: y, axis: ChartYAxis.AxisDependency.Right)
        
        let axis = leftdist < rightdist ? ChartYAxis.AxisDependency.Left : ChartYAxis.AxisDependency.Right
        
        let dataSetIndex = ChartUtils.closestDataSetIndex(valsAtIndex, value: y, axis: axis)
        
        return dataSetIndex
    }

    func getSelectionDetailsAtIndex(xIndex: Int) -> [ChartSelectionDetail]
    {
        var vals = [ChartSelectionDetail]()
        var pt = CGPoint()
        
        for (var i = 0, dataSetCount = self.chart?.data?.dataSetCount; i < dataSetCount; i++)
        {
            let dataSet = self.chart!.data!.getDataSetByIndex(i)
            
            // dont include datasets that cannot be highlighted
            if !dataSet.isHighlightEnabled
            {
                continue
            }
            
            // extract all y-values from all DataSets at the given x-index
            let yVal: Double = dataSet.yValForXIndex(xIndex)
            if yVal.isNaN
            {
                continue
            }
            
            pt.y = CGFloat(yVal)
            
            self.chart!.getTransformer(dataSet.axisDependency).pointValueToPixel(&pt)
            
            if !pt.y.isNaN
            {
                vals.append(ChartSelectionDetail(value: Double(pt.y), dataSetIndex: i, dataSet: dataSet))
            }
        }
        
        return vals
    }
}
