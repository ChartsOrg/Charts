//
//  KlineChartData.swift
//  Charts
//
//  Created by 迅牛 on 16/6/16.
//  Copyright © 2016年 dcg. All rights reserved.
//

import UIKit

@objc
public enum KlineQualification: Int {
    
    case VOL
    case KDJ
    case MACD
    case RSI
    case ASI
    case BOLL
    case BIAS
    case WR
}

@objc
public class KlineChartData: CandleChartData {
    
    var _qualificationType:KlineQualification = .KDJ
    
    var qualificationType:KlineQualification {
        
        get {
           return _qualificationType
        } set {
            _qualificationType = newValue
            
            calcQualification(dataSets);
        }
    }
    
    var emaLineData : LineChartData!
    var quaLificationLineData : LineChartData!
    var quaLificationBarData: BarChartData!
//    var 
    private var _isVisibKline:Bool = true
    var isVisibKline:Bool {
        get {
            return _isVisibKline
        } set {
             _isVisibKline = newValue
            
            changeEMAVisible()
        }
    }

    public override init()
    {
        super.init()
    }
    
    internal override func initialize(dataSets: [IChartDataSet])
    {
        super.initialize(dataSets)
        
    }
    
    public override init(xVals: [String?]?, dataSets: [IChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
    }
    
    public override init(xVals: [NSObject]?, dataSets: [IChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
        calcEMA(dataSets)
        calcQualification(dataSets);
    }
    
    public override func notifyDataChanged()
    {
        calcEMA(dataSets)
        calcQualification(dataSets);
        super.notifyDataChanged() // recalculate everything
       
    }
    
    public func changeEMAVisible() {
        dataSets[0].visible = isVisibKline;
        let line = (dataSets[0] as! KlineChartDataSet)
        
        line.lineDataSet.visible = !isVisibKline;
        //        }
        line.ema5DataSet.visible = isVisibKline;
        line.ema10DataSet.visible = isVisibKline;
        line.ema30DataSet.visible = isVisibKline;
        
        emaLineData = LineChartData(xVals: xVals, dataSets:[line.ema5DataSet,line.ema10DataSet,line.ema30DataSet,line.lineDataSet])
    }
    
    public func  calcEMA(dataSets: [IChartDataSet]!) {
        
        if (dataSets == nil && dataSets.count == 0)
        {
            return
        }
        
        for i in 0 ..< dataSets.count
        {
            (dataSets[i] as! KlineChartDataSet).calcEMA()
        }
        dataSets[0].visible = isVisibKline;
        let line = (dataSets[0] as! KlineChartDataSet)
        
        line.lineDataSet.visible = !isVisibKline;
        //        }
        line.ema5DataSet.visible = isVisibKline;
        line.ema10DataSet.visible = isVisibKline;
        line.ema30DataSet.visible = isVisibKline;
        
        emaLineData = LineChartData(xVals: xVals, dataSets:[line.ema5DataSet,line.ema10DataSet,line.ema30DataSet,line.lineDataSet])
    }
    
    public func calcQualification(dataSets: [IChartDataSet]!)  {
        
        if (dataSets == nil && dataSets.count == 0)
        {
            return
        }
        
        for i in 0 ..< dataSets.count
        {
            (dataSets[i] as! KlineChartDataSet)._qualificationType = _qualificationType

            (dataSets[i] as! KlineChartDataSet).calcQualification()
        }
        let line = (dataSets[0] as! KlineChartDataSet)
        
        if line.qualiLineDataSets != nil {
            quaLificationLineData = LineChartData(xVals: xVals, dataSets:line.qualiLineDataSets)
        }
        if line.qualiBarDataSets != nil {
            quaLificationBarData = BarChartData(xVals: xVals, dataSets:line.qualiBarDataSets)
        }
    }
}
