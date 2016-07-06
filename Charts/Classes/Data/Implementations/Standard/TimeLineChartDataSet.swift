//
//  TimeLineChartDataSet.swift
//  Charts
//
//  Created by 迅牛 on 16/6/30.
//  Copyright © 2016年 dcg. All rights reserved.
//

import UIKit

public class TimeLineChartDataSet: LineChartDataSet,ITimeLineDataSet {
    
    
    internal var _yMaxRange = Double(0.0)
    internal var _yMinRange = Double(0.0)
    
    internal var _avgVisibe:Bool = false
    
    public var avgVisibe: Bool {
        
        get {
           return _avgVisibe
        } set {
            _avgVisibe = newValue
            
        }
    }
    
    /// - returns: the minimum y-value this DataSet holds
    public  var yMinRange: Double { return _yMinRange }
    
    /// - returns: the maximum y-value this DataSet holds
    public  var yMaxRange: Double { return _yMaxRange }
    
    
    lazy internal var _mainLineDataSets:[LineChartDataSet] = [LineChartDataSet]()

    lazy internal var _qulificationBarDataSets:[BarChartDataSet] = [BarChartDataSet]()
    
    public required init()
    {
        super.init()
    }
    
    
    
    public override init(yVals: [ChartDataEntry]?, label: String?)
    {
        super.init(yVals: yVals, label: label)
        
        highlightLineWidth = 1.0
        highlightColor = NSUIColor(white: 0.3, alpha: 1);
        drawMinMaxValueEnable = true
        
//        calcQualification()
    
    }
    public override func notifyDataSetChanged() {
        super.notifyDataSetChanged()
    }
    
    public override func calcMinMax(start start: Int, end: Int) {
        
        let yValCount = self.entryCount
        
        if yValCount == 0
        {
            return
        }
        var entries = yVals as! [TimelineDataEntry]
        
        var endValue : Int
        
        if end == 0 || end >= yValCount
        {
            endValue = yValCount - 1
        }
        else
        {
            endValue = end
        }
        
        _lastStart = start
        _lastEnd = end
        
        _yMin = DBL_MAX
        _yMax = -DBL_MAX
        
        for i in start.stride(through: endValue, by: 1)
        {
            let e = entries[i]
            
            if (e.low < _yMin)
            {
                _yMin = e.low
                _yMinXIndex = e.xIndex
            }
            
            if (e.high > _yMax)
            {
                _yMax = e.high
                _yMaxXIndex = e.xIndex
            }
            
        }
        
        let  positive = ( entries[_lastStart].close - yMin)
        let neg  = (entries[_lastStart].close - yMax)
        
        let  range = max( abs(positive), abs(neg))
        _yMin = entries[_lastStart].close - range
        _yMax = entries[_lastStart].close + range


    }
    
    func calcQualification() {
        
        var barArray = [ChartDataEntry]()
        var lineArray = [ChartDataEntry]()
        var originArray = [ChartDataEntry]()
        var colorArray = [NSUIColor]()
        for i in 0 ..< yVals.count
        {
            let entry = (yVals[i] as! TimelineDataEntry)

            var color:NSUIColor!
            let line  =  BarChartDataEntry(value: entry.avg, xIndex: i)
            let origin  = BarChartDataEntry(value: entry.value, xIndex: i)
            let entryBar =  BarChartDataEntry(value: entry.volume, xIndex: i)
            if (entry.current - entry.close >= 0) {
                color = increasingColor
            } else {
                color = decreasingColor
            }
            
            originArray.append(origin);
            colorArray.append(color)
            barArray.append(entryBar)
            lineArray.append(line)

        }
        
        let origin = LineChartDataSet(yVals: originArray, label: "当前")
        origin.mode = LineChartDataSet.Mode.Linear
        origin.fillAlpha = fillAlpha;
        origin.fillColor = fillColor;
        origin.fill = fill;
        origin.drawFilledEnabled = drawFilledEnabled
//        origin.
        origin.colors = colors
        origin.circleHoleColor = circleHoleColor;
        origin.drawValuesEnabled = drawValuesEnabled
        origin.circleHoleRadius = circleHoleRadius;
        origin.circleColors = circleColors;
        origin.drawCirclesEnabled = drawCirclesEnabled
        origin.highlightEnabled = highlightEnabled;
        origin.highlightLineDashPhase = highlightLineDashPhase;
        origin.highlightColor = highlightColor;
        origin.highlightLineWidth = highlightLineWidth;
        origin.drawHorizontalHighlightValueEnable = true;
        origin.drawHorizontalHighlightIndicatorEnabled = true;

        let lineDataSet = LineChartDataSet(yVals: lineArray, label: "avg")
        lineDataSet.drawCirclesEnabled = false
        lineDataSet.drawValuesEnabled = false
        lineDataSet.mode = LineChartDataSet.Mode.Linear
        lineDataSet.setColor(avgColor)
        lineDataSet.highlightColor = highlightColor;
        lineDataSet.highlightLineWidth = highlightLineWidth;
        lineDataSet.drawHorizontalHighlightIndicatorEnabled = false;
        lineDataSet.lineWidth = 0.5;
        lineDataSet.visible = self.avgVisibe;

        let barDataSet = BarChartDataSet(yVals: barArray, label: "VOL")
        barDataSet.drawValuesEnabled = false
        barDataSet.highlightColor = highlightColor;
        barDataSet.colors = colorArray
        barDataSet.barSpace = 0.1
        barDataSet.barShadowColor = NSUIColor.clearColor();
        barDataSet.highlightAlpha = 1
        barDataSet.highlightLineWidth = 1;
        barDataSet.valueColors = colorArray
        
        //
        _mainLineDataSets = [origin, lineDataSet]
        _qulificationBarDataSets = [barDataSet]
        //        difDataSet.en
    }
    
    public var avgColor:NSUIColor = NSUIColor.orangeColor()
    public var increasingColor: NSUIColor = NSUIColor(red: CGFloat(255) / 255.0, green: CGFloat(48) / 255.0, blue: CGFloat(66) / 255.0, alpha: 1)
    public var decreasingColor: NSUIColor = NSUIColor(red: CGFloat(0) / 255.0, green: CGFloat(191) / 255.0, blue: CGFloat(128) / 255.0, alpha: 1)

    public var mainLineDataSets:[LineChartDataSet] {
        
        return _mainLineDataSets
    }
    public var qulificationBarDataSets:[BarChartDataSet] {
        
        return _qulificationBarDataSets;
    }
}
