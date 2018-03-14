//
//  PieData.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class PieChartData: ChartData
{
    public required init()
    {
        super.init()
    }
    
    public override init(dataSets: [ChartDataSetProtocol]?)
    {
        super.init(dataSets: dataSets)
    }

    public required init(arrayLiteral elements: ChartDataSetProtocol...)
    {
        super.init(dataSets: elements)
    }

    @objc var dataSet: PieChartDataSetProtocol?
    {
        get
        {
            return dataSets.count > 0 ? dataSets[0] as? PieChartDataSetProtocol : nil
        }
        set
        {
            if let newValue = newValue
            {
                dataSets = [newValue]
            }
            else
            {
                dataSets = []
            }
        }
    }
    
    open override func getDataSetByIndex(_ index: Int) -> ChartDataSetProtocol?
    {
        if index != 0
        {
            return nil
        }
        return super.getDataSetByIndex(index)
    }
    
    open override func getDataSetByLabel(_ label: String, ignorecase: Bool) -> ChartDataSetProtocol?
    {
        if dataSets.count == 0 || dataSets[0].label == nil
        {
            return nil
        }
        
        if ignorecase
        {
            if let label = dataSets[0].label, label.caseInsensitiveCompare(label) == .orderedSame
            {
                return dataSets[0]
            }
        }
        else
        {
            if label == dataSets[0].label
            {
                return dataSets[0]
            }
        }
        return nil
    }
    
    open override func entryForHighlight(_ highlight: Highlight) -> ChartDataEntry?
    {
        return dataSet?.entryForIndex(Int(highlight.x))
    }
    
    /// - returns: The total y-value sum across all DataSet objects the this object represents.
    @objc open var yValueSum: Double
    {
        guard let dataSet = dataSet else { return 0.0 }
        
        var yValueSum: Double = 0.0
        
        for i in 0..<dataSet.entryCount
        {
            yValueSum += dataSet.entryForIndex(i)?.y ?? 0.0
        }
        
        return yValueSum
    }
}
