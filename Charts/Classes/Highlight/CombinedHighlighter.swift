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
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

public class CombinedHighlighter: ChartHighlighter
{
    /// Returns a list of SelectionDetail object corresponding to the given xIndex.
    /// - parameter xIndex:
    /// - returns:
    public override func getSelectionDetailsAtIndex(xIndex: Int, dataSetIndex: Int?) -> [ChartSelectionDetail]
    {
        var vals = [ChartSelectionDetail]()
        var pt = CGPoint()
        
        guard let
            data = self.chart?.data as? CombinedChartData
            else { return vals }
        
        // get all chartdata objects
        var dataObjects = data.allData
        
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
                let yVals: [Double] = dataSet.yValsForXIndex(xIndex)
                for yVal in yVals
                {
                    pt.y = CGFloat(yVal)
                    
                    self.chart!
                        .getTransformer(dataSet.axisDependency)
                        .pointValueToPixel(&pt)
                    
                    if !pt.y.isNaN
                    {
                        vals.append(ChartSelectionDetail(y: pt.y, value: yVal, dataIndex: i, dataSetIndex: j, dataSet: dataSet))
                    }
                }
            }
        }
        
        return vals
    }
}
