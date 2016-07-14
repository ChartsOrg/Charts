//
//  HorizontalBarChartHighlighter.swift
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

public class HorizontalBarChartHighlighter: BarChartHighlighter
{
    public override func getHighlight(x x: CGFloat, y: CGFloat) -> ChartHighlight?
    {
        if let barData = self.chart?.data as? BarChartData
        {
            let pos = getValsForTouch(x: y, y: x)
            
            guard let selectionDetail = getSelectionDetail(xValue: Double(pos.y), x: y, y: x)
                else { return nil }
            
            if let set = barData.getDataSetByIndex(selectionDetail.dataSetIndex) as? IBarChartDataSet
                where set.isStacked
            {
                return getStackedHighlight(selectionDetail: selectionDetail,
                                           set: set,
                                           xValue: Double(pos.y),
                                           yValue: Double(pos.x))
            }
            
            return ChartHighlight(x: selectionDetail.xValue,
                                  y: selectionDetail.yValue,
                                  dataIndex: selectionDetail.dataIndex,
                                  dataSetIndex: selectionDetail.dataSetIndex,
                                  stackIndex: -1)
        }
        return nil
    }
    
    internal override func getDetails(
        set: IChartDataSet,
        dataSetIndex: Int,
        xValue: Double,
        rounding: ChartDataSetRounding) -> ChartSelectionDetail?
    {
        guard let chart = self.chart
            else { return nil }
        
        if let e = set.entryForXPos(xValue, rounding: rounding)
        {
            let px = chart.getTransformer(set.axisDependency).pixelForValue(x: e.y, y: e.x)
            
            return ChartSelectionDetail(x: px.x, y: px.y, xValue: e.x, yValue: e.y, dataSetIndex: dataSetIndex, dataSet: set)
        }
        
        return nil
    }
    
    internal override func getDistance(x x: CGFloat, y: CGFloat, selX: CGFloat, selY: CGFloat) -> CGFloat
    {
        return abs(y - selY)
    }
}
