//
//  KlineChartData.swift
//  Charts
//
//  Created by 迅牛 on 16/6/16.
//  Copyright © 2016年 dcg. All rights reserved.
//

import UIKit

public class KlineChartData: CandleChartData {

    var emaLineData : LineChartData!
    var kdjLineData : LineChartData!

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
        calcQualification(dataSets);
    }
    
    public override func notifyDataChanged()
    {        
        super.notifyDataChanged() // recalculate everything
        calcQualification(dataSets);
    }
    
    public func calcQualification(dataSets: [IChartDataSet]!)  {
        
        if (dataSets == nil && dataSets.count == 0)
        {
            return
        }
        
        for i in 0 ..< dataSets.count
        {
            (dataSets[i] as! KlineChartDataSet).calcQualification()
        }
        let line = (dataSets[0] as! KlineChartDataSet)
        kdjLineData = LineChartData(xVals: xVals, dataSets:line.kdjDataSets)
        emaLineData = LineChartData(xVals: xVals, dataSets:[line.ema5DataSet,line.ema10DataSet,line.ema30DataSet])
    }
}
