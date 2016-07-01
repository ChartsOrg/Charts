//
//  TimeLineData.swift
//  Charts
//
//  Created by 迅牛 on 16/6/30.
//  Copyright © 2016年 dcg. All rights reserved.
//

import UIKit

public class TimeLineData: LineChartData {
    
   public var mainLineData:LineChartData = LineChartData()
    
   public var qulificationBarData:BarChartData = BarChartData()
    
    public var limit:Double = 0.0
    
    public override init()
    {
        super.init()
        calcQualification(dataSets);
    }
    
    override func calcMinMax(start start: Int, end: Int) {
        
        super.calcMinMax(start: start, end: end)
        
       guard let data = dataSets[0] as? TimeLineChartDataSet else {
            return;
        }
        
        _yMax = data.yMax;
        _yMin = data.yMin;
        _leftAxisMax = data.yMax;
        _leftAxisMin = data.yMin;
        _rightAxisMax = data.yMaxRange;
        _rightAxisMin = data.yMinRange;
        
    }
    public override init(xVals: [String?]?, dataSets: [IChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
         calcQualification(dataSets);
    }
    
    public override init(xVals: [NSObject]?, dataSets: [IChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
        calcQualification(dataSets);
    }
    
    public override func notifyDataChanged() {
        
        super.notifyDataChanged()
         calcQualification(dataSets);
       
    }
    
    func calcQualification(dataSets: [IChartDataSet]!) {
        
        
        if (dataSets == nil && dataSets.count == 0)
        {
            return
        }
        
        for i in 0 ..< dataSets.count
        {

            
            (dataSets[i] as! TimeLineChartDataSet).calcQualification()
        }
        let line = (dataSets[0] as! TimeLineChartDataSet)
        
        if line.mainLineDataSets.count != 0 {
            mainLineData = LineChartData(xVals: xVals, dataSets:line.mainLineDataSets)
            limit = (line.entryForIndex(0) as! TimelineDataEntry).close;
        }
        if line.qulificationBarDataSets.count  != 0 {
            qulificationBarData = BarChartData(xVals: xVals, dataSets:line.qulificationBarDataSets)
        }

        
    }

}
