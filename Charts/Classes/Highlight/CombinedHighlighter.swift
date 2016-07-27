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
    /// Returns a list of SelectionDetail object corresponding to the given xValue.
    /// - parameter xValue:
    /// - returns:
    public override func getSelectionDetailsAtIndex(xValue: Double) -> [ChartSelectionDetail]
    {
        var vals = [ChartSelectionDetail]()
        
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
                
                // don't include datasets that cannot be highlighted
                if !dataSet.isHighlightEnabled
                {
                    continue
                }
                
                if let s1 = getDetails(dataSet, dataSetIndex: j, xValue: xValue, rounding: .Up)
                {
                    s1.dataIndex = i
                    vals.append(s1)
                }
                
                if let s2 = getDetails(dataSet, dataSetIndex: j, xValue: xValue, rounding: .Down)
                {
                    s2.dataIndex = i
                    vals.append(s2)
                }
            }
        }
        
        return vals
    }
}
