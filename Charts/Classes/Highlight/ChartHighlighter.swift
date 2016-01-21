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
    public func getHighlight(x x: Double, y: Double) -> ChartHighlight?
    {
        var xIndex = getXIndex(x)
        if (xIndex == -Int.max)
        {
            return nil
        }
        
        let dataSetIndex = getDataSetIndex(xIndex: xIndex, x: x, y: y)
        if (dataSetIndex == -Int.max)
        {
            return nil
        }
        
        let yValueIndex = getClosestValueOnYAxis(dataSetIndex, xIndex: xIndex, yPoint: y)
        
        let h : ChartHighlight
        
        if(yValueIndex != -1){
            
            //Update the value of the xIndex with the position on the Array.
            xIndex = yValueIndex
            
            h = ChartHighlight(xIndex: xIndex, dataSetIndex: dataSetIndex)
            
            h.setBuubleIndex(true)
            
        } else {
            
            h =  ChartHighlight(xIndex: xIndex, dataSetIndex: dataSetIndex)
        }
        
        return h
    }
    
    /// Returns the corresponding x-index for a given touch-position in pixels.
    /// - parameter x:
    /// - returns:
    public func getXIndex(x: Double) -> Int
    {
        // create an array of the touch-point
        var pt = CGPoint(x: x, y: 0.0)
        
        // take any transformer to determine the x-axis value
        self.chart?.getTransformer(ChartYAxis.AxisDependency.Left).pixelToValue(&pt)
        
        return Int(round(pt.x))
    }
    
    /// Returns the corresponding dataset-index for a given xIndex and xy-touch position in pixels.
    /// - parameter xIndex:
    /// - parameter x:
    /// - parameter y:
    /// - returns:
    public func getDataSetIndex(xIndex xIndex: Int, x: Double, y: Double) -> Int
    {
        let valsAtIndex = getSelectionDetailsAtIndex(xIndex)
        
        let leftdist = ChartUtils.getMinimumDistance(valsAtIndex, val: y, axis: ChartYAxis.AxisDependency.Left)
        let rightdist = ChartUtils.getMinimumDistance(valsAtIndex, val: y, axis: ChartYAxis.AxisDependency.Right)
        
        let axis = leftdist < rightdist ? ChartYAxis.AxisDependency.Left : ChartYAxis.AxisDependency.Right
        
        let dataSetIndex = ChartUtils.closestDataSetIndex(valsAtIndex, value: y, axis: axis)
        
        return dataSetIndex
    }
    
    /// Returns a list of SelectionDetail object corresponding to the given xIndex.
    /// - parameter xIndex:
    /// - returns:
    public func getSelectionDetailsAtIndex(xIndex: Int) -> [ChartSelectionDetail]
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
    
    /**
     New Method - Get all the Y values with the same x-Index if they exist
     
     - parameter dataSetIndex: dataSetIndex Index with the value selected
     - parameter xIndex:       Index of the value
     - parameter yPoint:       Y value of the touch
     
     - returns: index of the yValue
     */
    internal func getClosestValueOnYAxis(dataSetIndex :Int, xIndex :Int, yPoint: Double) -> Int{
        
        let dataSet = self.chart!.data!.getDataSetByIndex(dataSetIndex)
        
        let entriesIndexes = dataSet.yValsIndexForXIndex(xIndex)
        
        if(entriesIndexes.count > 1){
            
            var point = CGPoint()
            // create an array of the touch-point
            point.y = CGFloat(yPoint)
            // take any transformer to determine the x-axis value
            self.chart?.getTransformer(dataSet.axisDependency).pixelToValue(&point)
            
            let indexOnYValuesArray = self.getIndexClosestValueIndex(values: dataSet.yVals, point: point, arrayIndex: entriesIndexes)
            
            return indexOnYValuesArray
        }
        
        return -1
    }
    
    
    /**
     New Method - Look for the y value with binary search
     
     - parameter values: All the values with the same x-Index
     - parameter point:  y point
     
     - returns: return the closest element in the y position
     */
    internal func getIndexClosestValueIndex(values values: [ChartDataEntry], point: CGPoint, arrayIndex: [Int]) -> Int{
        
        // take any transformer to determine the x-axis value
        let yValue : Double = Double(point.y)
        
        var minIndex: Int = arrayIndex[0]
        let maxIndex: Int = arrayIndex[arrayIndex.count - 1]
        var resultIndex: Int = 0
        var difference: Double = Double.infinity
        
        
        for ; minIndex <= maxIndex; minIndex++ {
            
            let entry  = values[minIndex]
            
            let tempDifference = abs(yValue - entry.value)
            
            if( tempDifference < difference){
                resultIndex = minIndex
                difference = tempDifference
            }
        }
        
        return resultIndex
    }
}
