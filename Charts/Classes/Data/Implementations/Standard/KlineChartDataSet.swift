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
    var _qualificationType:KlineQualification = .KDJ
    var ema5DataSet:LineChartDataSet!
    var ema10DataSet:LineChartDataSet!
    var ema30DataSet:LineChartDataSet!
    
    var lineDataSet:LineChartDataSet!
    
    var qualiLineDataSets:[LineChartDataSet]!
    var qualiBarDataSets:[BarChartDataSet]!
    
    public override init(yVals: [ChartDataEntry]?, label: String?)
    {
        super.init(yVals: yVals, label: label)
        
        highlightLineWidth = 1.0
        highlightColor = NSUIColor(white: 0.3, alpha: 1);
        drawMinMaxValueEnable = true
    }
    public override func notifyDataSetChanged() {
        super.notifyDataSetChanged()
    }
    
    internal func calcQualification()  {
        
        for val in  yVals {
            (val as! KlineChartDataEntry).nineClocksNeedCacl = true
        }
        switch _qualificationType {
        case .KDJ:
            calcKDJ()
        case .MACD:
            calcMACD()
        case .VOL:
            caclVolum()
        case .RSI: break
        case .BIAS: break
        case .BOLL: break
        case .WR: break
        case .ASI: break
        }
    }
    
    func caclVolum() {
        
        var maArray = [ChartDataEntry]()
        var volumArray = [ChartDataEntry]()
        var colorArray = [NSUIColor]()
        
        for i in 0 ..< yVals.count
        {
            let entry = (yVals[i] as! KlineChartDataEntry)
            entry.dataSet = self
            if (i == 0) {
                
            } else {
                entry.lastEntry = (yVals[i - 1] as? KlineChartDataEntry)
            }
            entry._qualificationType = _qualificationType
            entry.calcQualification()
            
            let entryMA = BarChartDataEntry(value: entry.volume_MA5, xIndex: i);
            let entryVolum = BarChartDataEntry(value: entry.volume, xIndex: i);
            var color:NSUIColor!
            if (entry.close - entry.open >= 0) {
                color = increasingColor
            } else {
                color = decreasingColor
            }
            
            colorArray.append(color);
            maArray.append(entryMA);
            volumArray.append(entryVolum);
            
        }
        
        
        let maDataSet = LineChartDataSet(yVals: maArray, label: "MA5")
        maDataSet.drawCirclesEnabled = false
        maDataSet.drawValuesEnabled = false
        maDataSet.mode = LineChartDataSet.Mode.Linear
        maDataSet.setColor(MA5Color)
        maDataSet.highlightColor = highlightColor;
        maDataSet.highlightLineWidth = highlightLineWidth;
        maDataSet.drawHorizontalHighlightIndicatorEnabled = false;

        let volumDataSet = BarChartDataSet(yVals: volumArray, label: "MACD")
        volumDataSet.drawValuesEnabled = false
        volumDataSet.highlightColor = highlightColor;
        volumDataSet.colors = colorArray
        volumDataSet.barSpace = 0.3
        volumDataSet.valueColors = colorArray
        volumDataSet.barShadowColor = NSUIColor.clearColor()
        qualiLineDataSets = [maDataSet]
        qualiBarDataSets = [volumDataSet]
        
    }
    
    func calcMACD() {
        var deaArray = [ChartDataEntry]()
        var difArray = [ChartDataEntry]()
        var macdArray = [ChartDataEntry]()
        var colorArray = [NSUIColor]()
        for i in 0 ..< yVals.count
        {
            let entry = (yVals[i] as! KlineChartDataEntry)
            entry.dataSet = self
            if (i == 0) {
                
            } else {
                entry.lastEntry = (yVals[i - 1] as? KlineChartDataEntry)
            }
            entry._qualificationType = _qualificationType
            entry.calcQualification()
            
            let entryDEA =  BarChartDataEntry(value: entry.DEA, xIndex: i)
            let entryDIF =  BarChartDataEntry(value: entry.DIF, xIndex: i)
            
            var color:NSUIColor!
            let entryMACD =  BarChartDataEntry(value: entry.MACD, xIndex: i)
            if (entryMACD.value >= 0) {
                color = increasingColor
            } else {
                color = decreasingColor
            }
            
            colorArray.append(color)
            deaArray.append(entryDEA)
            difArray.append(entryDIF)
            macdArray.append(entryMACD)
        }
        
        //        (yVals as NSArray).valueForKey("")
        let deaDataSet = LineChartDataSet(yVals: deaArray, label: "DEA")
        deaDataSet.drawCirclesEnabled = false
        //        kDataSet.highlightEnabled = false
        deaDataSet.drawValuesEnabled = false
        deaDataSet.mode = LineChartDataSet.Mode.Linear
        deaDataSet.setColor(MACD_DEAColor)
        deaDataSet.highlightColor = highlightColor;
        deaDataSet.highlightLineWidth = highlightLineWidth;
        deaDataSet.drawHorizontalHighlightIndicatorEnabled = false;
        //        kDataSet.drawVerticalHighlightIndicatorEnabled = false
        
        let difDataSet = LineChartDataSet(yVals: difArray, label: "DIF")
        difDataSet.drawCirclesEnabled = false
        //        dDataSet.highlightEnabled = false
        difDataSet.drawValuesEnabled = false
        difDataSet.mode = LineChartDataSet.Mode.Linear
        difDataSet.setColor(MACD_DIFColor)
        difDataSet.highlightColor = highlightColor;
        difDataSet.highlightLineWidth = highlightLineWidth;
        difDataSet.drawHorizontalHighlightIndicatorEnabled = false;
        
        let macdDataSet = BarChartDataSet(yVals: macdArray, label: "MACD")
        macdDataSet.drawValuesEnabled = false
        macdDataSet.highlightColor = highlightColor;
        macdDataSet.colors = colorArray
        macdDataSet.barSpace = 0.7
        macdDataSet.valueColors = colorArray
        macdDataSet.barShadowColor = NSUIColor.clearColor()
        
        qualiLineDataSets = [deaDataSet,difDataSet]
        qualiBarDataSets = [macdDataSet]
    }
    
    func calcKDJ() {
        
        var kArray = [ChartDataEntry]()
        var dArray = [ChartDataEntry]()
        var jArray = [ChartDataEntry]()
        for i in 0 ..< yVals.count
        {
            let entry = (yVals[i] as! KlineChartDataEntry)
            entry.dataSet = self
            if (i == 0) {
                
            } else {
                entry.lastEntry = (yVals[i - 1] as? KlineChartDataEntry)
            }
            entry._qualificationType = _qualificationType
            entry.calcQualification()
            
            let entryK =  BarChartDataEntry(value: entry.KDJ_K, xIndex: i)
            let entryD =  BarChartDataEntry(value: entry.KDJ_D, xIndex: i)
            let entryJ =  BarChartDataEntry(value: entry.KDJ_J, xIndex: i)
            
            kArray.append(entryK)
            dArray.append(entryD)
            jArray.append(entryJ)
        }
        
        //        (yVals as NSArray).valueForKey("")
        let kDataSet = LineChartDataSet(yVals: kArray, label: "K")
        kDataSet.drawCirclesEnabled = false
        //        kDataSet.highlightEnabled = false
        kDataSet.drawValuesEnabled = false
        kDataSet.mode = LineChartDataSet.Mode.Linear
        kDataSet.setColor(KDJ_KColor)
        kDataSet.highlightColor = highlightColor;
        kDataSet.highlightLineWidth = highlightLineWidth;
        kDataSet.drawVerticalHighlightIndicatorEnabled = false
        
        let dDataSet = LineChartDataSet(yVals: dArray, label: "D")
        dDataSet.drawCirclesEnabled = false
        //        dDataSet.highlightEnabled = false
        dDataSet.drawValuesEnabled = false
        dDataSet.mode = LineChartDataSet.Mode.Linear
        dDataSet.setColor(KDJ_DColor)
        dDataSet.highlightColor = highlightColor;
        dDataSet.highlightLineWidth = highlightLineWidth;
        dDataSet.drawHorizontalHighlightIndicatorEnabled = false
        
        let jDataSet = LineChartDataSet(yVals: jArray, label: "J")
        jDataSet.drawCirclesEnabled = false
        jDataSet.drawValuesEnabled = false
        jDataSet.mode = LineChartDataSet.Mode.Linear
        jDataSet.highlightColor = highlightColor;
        jDataSet.highlightLineWidth = highlightLineWidth;
        jDataSet.drawVerticalHighlightIndicatorEnabled = false
        jDataSet.setColor(KDJ_JColor)
        
        qualiLineDataSets = [kDataSet,dDataSet,jDataSet]
        qualiBarDataSets = []
    }
    
    func calcEMA() {
        
        var ma5Array = [ChartDataEntry]()
        var ma10Array = [ChartDataEntry]()
        var ma30Array = [ChartDataEntry]()
        var valueArray = [ChartDataEntry]()
        
        for i in 0 ..< yVals.count
        {
            let entry = (yVals[i] as! KlineChartDataEntry)
            entry.dataSet = self
            if (i == 0) {
                
            } else {
                entry.lastEntry = (yVals[i - 1] as? KlineChartDataEntry)
            }
            entry.caclEMA()
            let entryEMA5 =  BarChartDataEntry(value: entry.EMA5, xIndex: i)
            let entryEMA10 =  BarChartDataEntry(value: entry.EMA10, xIndex: i)
            let entryEMA30 =  BarChartDataEntry(value: entry.EMA30, xIndex: i)
            let entryValue = BarChartDataEntry(value: entry.value, xIndex: i)
            ma5Array.append(entryEMA5)
            ma10Array.append(entryEMA10)
            ma30Array.append(entryEMA30)
            valueArray.append(entryValue)
        }
        
        ema5DataSet = LineChartDataSet(yVals: ma5Array, label: "EMA5")
        ema5DataSet.drawCirclesEnabled = false
        ema5DataSet.highlightEnabled = false
        ema5DataSet.drawValuesEnabled = false
        ema5DataSet.mode = LineChartDataSet.Mode.Linear
        
        ema5DataSet.setColor(MA5Color)
        //        ema5DataSet.mode = LineChartDataSet.Mode.CubicBezier
        ema10DataSet = LineChartDataSet(yVals: ma10Array, label: "EMA10")
        ema10DataSet.setColor(MA10Color)
        ema10DataSet.drawCirclesEnabled = false
        ema10DataSet.highlightEnabled = false
        ema10DataSet.drawValuesEnabled = false
        ema10DataSet.mode = LineChartDataSet.Mode.Linear
        //        ema10DataSet.mode = LineChartDataSet.Mode.CubicBezier
        ema30DataSet = LineChartDataSet(yVals: ma30Array, label: "EMA30")
        ema30DataSet.setColor(MA30Color)
        ema30DataSet.drawCirclesEnabled = false
        ema30DataSet.highlightEnabled = false
        ema30DataSet.drawValuesEnabled = false
        ema30DataSet.mode = LineChartDataSet.Mode.Linear
        
        lineDataSet = LineChartDataSet(yVals: valueArray, label:label)
        lineDataSet.drawCirclesEnabled = false
        //        kDataSet.highlightEnabled = false
        lineDataSet.drawValuesEnabled = false
        lineDataSet.mode = LineChartDataSet.Mode.CubicBezier
        lineDataSet.setColor(UIColor(white: 0.45, alpha: 1))
        lineDataSet.highlightColor = highlightColor;
        lineDataSet.highlightLineWidth = highlightLineWidth;
        lineDataSet.visible = false;

    }
    
    private var _MA5Color:NSUIColor = NSUIColor(red: CGFloat(26) / 255.0, green: CGFloat(154) / 255.0, blue: CGFloat(242) / 255.0, alpha: 1)
     private var _MA10Color:NSUIColor = NSUIColor(red: CGFloat(253) / 255.0, green: CGFloat(186) / 255.0, blue: CGFloat(49) / 255.0, alpha: 1)
     private var _MA30Color:NSUIColor = NSUIColor(red: CGFloat(252) / 255.0, green: CGFloat(13) / 255.0, blue: CGFloat(27) / 255.0, alpha: 1)
    
    public var MA5Color: NSUIColor {
        get {
         return  _MA5Color;
           
        } set {
            _MA5Color = newValue
            ema5DataSet.setColor(self.MA5Color)
        }
    }
    public var MA10Color: NSUIColor {
        get {

            return  _MA10Color;
            
        } set {
            _MA10Color = newValue
            ema10DataSet.setColor(self.MA10Color)
        }
    }
    public var MA30Color: NSUIColor {
        get {

            return  _MA30Color;
            
        } set {
            _MA30Color = newValue
            ema30DataSet.setColor(self.MA30Color)
        }
    }
    
    public var MACD_Color: NSUIColor = NSUIColor(red: CGFloat(190) / 255.0, green: CGFloat(7) / 255.0, blue: CGFloat(18) / 255.0, alpha: 1)
    public var MACD_DEAColor: NSUIColor = NSUIColor(red: CGFloat(252) / 255.0, green: CGFloat(42) / 255.0, blue: CGFloat(252) / 255.0, alpha: 1)
    public var MACD_DIFColor: NSUIColor = NSUIColor(red: CGFloat(11) / 255.0, green: CGFloat(36) / 255.0, blue: CGFloat(251) / 255.0, alpha: 1)
    
    public var KDJ_KColor: NSUIColor = NSUIColor(red: CGFloat(0) / 255.0, green: CGFloat(0) / 255.0, blue: CGFloat(250) / 255.0, alpha: 1)
    public var KDJ_DColor: NSUIColor = NSUIColor(red: CGFloat(252) / 255.0, green: CGFloat(0) / 255.0, blue: CGFloat(252) / 255.0, alpha: 1)
    public var KDJ_JColor: NSUIColor = NSUIColor(red: CGFloat(0) / 255.0, green: CGFloat(255) / 255.0, blue: CGFloat(254) / 255.0, alpha: 1)

}
