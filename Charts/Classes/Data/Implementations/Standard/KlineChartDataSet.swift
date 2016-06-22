//
//  KlineChartDataSet.swift
//  Charts
//
//  Created by 迅牛 on 16/6/16.
//  Copyright © 2016年 dcg. All rights reserved.
//

import UIKit

public class KlineChartDataSet: CandleChartDataSet,IKlineChartDataSet {
    
    public required init()
    {
        super.init()
    }
    
    var ema5DataSet:LineChartDataSet!
    var ema10DataSet:LineChartDataSet!
    var ema30DataSet:LineChartDataSet!
    
    var kdjDataSets:[LineChartDataSet]!
    
    public override init(yVals: [ChartDataEntry]?, label: String?)
    {
        super.init(yVals: yVals, label: label)
        
        highlightLineWidth = 1.5
        highlightColor = NSUIColor(white: 0.3, alpha: 1);
        calcQualification()
    }
    
    internal func calcQualification()  {
        
        for val in  yVals {
            (val as! KlineChartDataEntry).nineClocksNeedCacl = true
        }
        
       var ma5Array = [ChartDataEntry]()
       var ma10Array = [ChartDataEntry]()
       var ma30Array = [ChartDataEntry]()
        
        var kArray = [ChartDataEntry]()
        var dArray = [ChartDataEntry]()
        var jArray = [ChartDataEntry]()
//        var Array = [ChartDataEntry]()
        for i in 0 ..< yVals.count
        {
            let entry = (yVals[i] as! KlineChartDataEntry)
            entry.dataSet = self
            if (i == 0) {
                
            } else {
                entry.lastEntry = (yVals[i - 1] as? KlineChartDataEntry)
            }
            entry.calcQualification()
            
            let entryEMA5 =  BarChartDataEntry(value: entry.EMA5, xIndex: i)
            let entryEMA10 =  BarChartDataEntry(value: entry.EMA10, xIndex: i)
            let entryEMA30 =  BarChartDataEntry(value: entry.EMA30, xIndex: i)
            let entryK =  BarChartDataEntry(value: entry.KDJ_K, xIndex: i)
            let entryD =  BarChartDataEntry(value: entry.KDJ_D, xIndex: i)
            let entryJ =  BarChartDataEntry(value: entry.KDJ_J, xIndex: i)
            ma5Array.append(entryEMA5)
            ma10Array.append(entryEMA10)
            ma30Array.append(entryEMA30)
            
            kArray.append(entryK)
            dArray.append(entryD)
            jArray.append(entryJ)
        }
        
//        ma5Arr
        
//        (yVals as NSArray).valueForKey("")
        let kDataSet = LineChartDataSet(yVals: kArray, label: "K")
        kDataSet.drawCirclesEnabled = false
//        kDataSet.highlightEnabled = false
        kDataSet.drawValuesEnabled = false
        kDataSet.mode = LineChartDataSet.Mode.CubicBezier
        kDataSet.setColor(MA5Color!)
        kDataSet.highlightColor = highlightColor;
        kDataSet.highlightLineWidth = highlightLineWidth;
//        kDataSet.drawVerticalHighlightIndicatorEnabled = false
        
        let dDataSet = LineChartDataSet(yVals: dArray, label: "D")
        dDataSet.drawCirclesEnabled = false
//        dDataSet.highlightEnabled = false
        dDataSet.drawValuesEnabled = false
        dDataSet.mode = LineChartDataSet.Mode.CubicBezier
          dDataSet.setColor(MA10Color!)
        dDataSet.highlightColor = highlightColor;
        dDataSet.highlightLineWidth = highlightLineWidth;
        
//         dDataSet.drawHorizontalHighlightIndicatorEnabled = false
        
        let jDataSet = LineChartDataSet(yVals: jArray, label: "J")
        jDataSet.drawCirclesEnabled = false
//        jDataSet.highlightEnabled = false
        jDataSet.drawValuesEnabled = false
        jDataSet.mode = LineChartDataSet.Mode.CubicBezier
        jDataSet.highlightColor = highlightColor;
        jDataSet.highlightLineWidth = highlightLineWidth;
        
//         jDataSet.drawVerticalHighlightIndicatorEnabled = false
        
        jDataSet.setColor(MA30Color!)
        
        kdjDataSets = [kDataSet,dDataSet,jDataSet]

        ema5DataSet = LineChartDataSet(yVals: ma5Array, label: "EMA5")
        ema5DataSet.drawCirclesEnabled = false
        ema5DataSet.highlightEnabled = false
        ema5DataSet.drawValuesEnabled = false
        ema5DataSet.mode = LineChartDataSet.Mode.CubicBezier
        
        ema5DataSet.setColor(MA5Color!)
//        ema5DataSet.mode = LineChartDataSet.Mode.CubicBezier
        ema10DataSet = LineChartDataSet(yVals: ma10Array, label: "EMA10")
        ema10DataSet.setColor(MA10Color!)
        ema10DataSet.drawCirclesEnabled = false
        ema10DataSet.highlightEnabled = false
        ema10DataSet.drawValuesEnabled = false
        ema10DataSet.mode = LineChartDataSet.Mode.CubicBezier
//        ema10DataSet.mode = LineChartDataSet.Mode.CubicBezier
        ema30DataSet = LineChartDataSet(yVals: ma30Array, label: "EMA30")
        ema30DataSet.setColor(MA30Color!)
        ema30DataSet.drawCirclesEnabled = false
        ema30DataSet.highlightEnabled = false
        ema30DataSet.drawValuesEnabled = false
        ema30DataSet.mode = LineChartDataSet.Mode.CubicBezier
//        ema30DataSet.mode = LineChartDataSet.Mode.CubicBezier
    }
    private var _MA5Color:NSUIColor?
     private var _MA10Color:NSUIColor?
     private var _MA30Color:NSUIColor?
    
    public var MA5Color: NSUIColor? {
        get {
            if _MA5Color == nil {
                _MA5Color = NSUIColor.redColor()
            } else {
            }
         return  _MA5Color;
           
        } set {
            _MA5Color = newValue
            ema5DataSet.setColor(self.MA5Color!)
        }
    }
    public var MA10Color: NSUIColor? {
        get {
            if _MA10Color == nil {
                _MA10Color = NSUIColor.greenColor()
            } else {
            }
            return  _MA10Color;
            
        } set {
            _MA10Color = newValue
            ema10DataSet.setColor(self.MA10Color!)
        }
    }
    public var MA30Color: NSUIColor? {
        get {
            if _MA30Color == nil {
                _MA30Color = NSUIColor.blueColor()
            } else {
            }
            return  _MA30Color;
            
        } set {
            _MA30Color = newValue
            ema30DataSet.setColor(self.MA30Color!)
        }
    }

}
