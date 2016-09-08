//
//  CombinedHighlighter.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

@objc(CombinedChartHighlighter)
public class CombinedHighlighter: ChartHighlighter
{
    /// bar highlighter for supporting stacked highlighting
    private var barHighlighter: BarHighlighter?
    
    public init(chart: CombinedChartDataProvider, barDataProvider: BarChartDataProvider)
    {
        super.init(chart: chart)
        
        // if there is BarData, create a BarHighlighter
        self.barHighlighter = barDataProvider.barData == nil ? nil : BarHighlighter(chart: barDataProvider)
    }
    
    public override func getHighlights(xValue xValue: Double, x: CGFloat, y: CGFloat) -> [Highlight]
    {
        var vals = [Highlight]()
        
        guard let chart = self.chart as? CombinedChartDataProvider
            else { return vals }
        
        if let dataObjects = chart.combinedData?.allData
        {
            for i in 0..<dataObjects.count
            {
                let dataObject = dataObjects[i]
                
                // in case of BarData, let the BarHighlighter take over
                if barHighlighter != nil && dataObject is BarChartData
                {
                    if let high = barHighlighter?.getHighlight(x: x, y: y)
                    {
                        high.dataIndex = i
                        vals.append(high)
                    }
                }
                else
                {
                    for j in 0..<dataObject.dataSetCount
                    {
                        let dataSet = dataObjects[i].getDataSetByIndex(j)
                        
                        // don't include datasets that cannot be highlighted
                        if !dataSet.isHighlightEnabled
                        {
                            continue
                        }
                        
                        if let s1 = buildHighlight(dataSet: dataSet, dataSetIndex: j, xValue: xValue, rounding: .Closest)
                        {
                            s1.dataIndex = i
                            vals.append(s1)
                        }
                    }
                }
            }
        }
        
        return vals
    }
}
