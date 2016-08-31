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

open class ChartHighlighter : NSObject
{
    /// instance of the data-provider
    open weak var chart: BarLineChartViewBase?
    
    public init(chart: BarLineChartViewBase)
    {
        self.chart = chart
    }
    
    /// Returns a Highlight object corresponding to the given x- and y- touch positions in pixels.
    /// - parameter x:
    /// - parameter y:
    /// - returns:
    open func getHighlight(x: CGFloat, y: CGFloat) -> ChartHighlight?
    {
        let xIndex = getXIndex(x)
        
        guard let selectionDetail = getSelectionDetail(xIndex: xIndex, y: y, dataSetIndex: nil)
            else { return nil }
        
        return ChartHighlight(xIndex: xIndex, value: selectionDetail.value, dataIndex: selectionDetail.dataIndex, dataSetIndex: selectionDetail.dataSetIndex, stackIndex: -1)
    }
    
    /// Returns the corresponding x-index for a given touch-position in pixels.
    /// - parameter x:
    /// - returns:
    open func getXIndex(_ x: CGFloat) -> Int
    {
        // create an array of the touch-point
        var pt = CGPoint(x: x, y: 0.0)
        
        // take any transformer to determine the x-axis value
        self.chart?.getTransformer(ChartYAxis.AxisDependency.left).pixelToValue(&pt)
        
        return Int(round(pt.x))
    }
    
    /// Returns the corresponding ChartSelectionDetail for a given xIndex and y-touch position in pixels.
    /// - parameter xIndex:
    /// - parameter y:
    /// - parameter dataSetIndex: A dataset index to look at - or nil, to figure that out automatically
    /// - returns:
    open func getSelectionDetail(xIndex: Int, y: CGFloat, dataSetIndex: Int?) -> ChartSelectionDetail?
    {
        let valsAtIndex = getSelectionDetailsAtIndex(xIndex, dataSetIndex: dataSetIndex)
        
        let leftdist = ChartUtils.getMinimumDistance(valsAtIndex, y: y, axis: ChartYAxis.AxisDependency.left)
        let rightdist = ChartUtils.getMinimumDistance(valsAtIndex, y: y, axis: ChartYAxis.AxisDependency.right)
        
        let axis = leftdist < rightdist ? ChartYAxis.AxisDependency.left : ChartYAxis.AxisDependency.right
        
        let detail = ChartUtils.closestSelectionDetailByPixelY(valsAtIndex: valsAtIndex, y: y, axis: axis)
        
        return detail
    }
    
    /// Returns a list of SelectionDetail object corresponding to the given xIndex.
    /// - parameter xIndex:
    /// - parameter dataSetIndex: A dataset index to look at - or nil, to figure that out automatically
    /// - returns:
    open func getSelectionDetailsAtIndex(_ xIndex: Int, dataSetIndex: Int?) -> [ChartSelectionDetail]
    {
        var vals = [ChartSelectionDetail]()
        var pt = CGPoint()
        
        guard let data = self.chart?.data
            else { return vals }
        
        for i in 0 ..< data.dataSetCount
        {
            if dataSetIndex != nil && dataSetIndex != i
            {
                continue
            }
            
			if let dataSet = data.getDataSetByIndex(i) {
				// dont include datasets that cannot be highlighted
				if !dataSet.highlightEnabled
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
        }
        
        return vals
    }
}
