//
//  CombinedHighlighter.swift
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

public class CombinedHighlighter: ChartHighlighter
{
    /// Returns a list of SelectionDetail object corresponding to the given xIndex.
    /// - parameter xIndex:
    /// - returns:
    public override func getSelectionDetailsAtIndex(xIndex: Int) -> [ChartSelectionDetail]
    {
        var vals = [ChartSelectionDetail]()
        
        if let data = self.chart?.data as? CombinedChartData
        {
            // get all chartdata objects
            var dataObjects = data.allData
            
            var pt = CGPoint()
            
            for i in 0 ..< dataObjects.count
            {
                for j in 0 ..< dataObjects[i].dataSetCount
                {
                    let dataSet = dataObjects[i].getDataSetByIndex(j)
                    
                    // dont include datasets that cannot be highlighted
                    if !dataSet.isHighlightEnabled
                    {
                        continue
                    }
                    
                    // extract all y-values from all DataSets at the given x-index
                    let yVal = dataSet.yValForXIndex(xIndex)
                    if yVal.isNaN
                    {
                        continue
                    }
                    
                    pt.y = CGFloat(yVal)
                    
                    self.chart!.getTransformer(dataSet.axisDependency).pointValueToPixel(&pt)
                    
                    if !pt.y.isNaN
                    {
                        vals.append(ChartSelectionDetail(value: Double(pt.y), dataSetIndex: j, dataSet: dataSet))
                    }
                }
            }
        }
        
        return vals
    }
}
