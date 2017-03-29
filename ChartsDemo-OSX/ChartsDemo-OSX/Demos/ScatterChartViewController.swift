//
//  LineDemoViewController.swift
//  ChartsDemo-OSX
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts

import Foundation
import Cocoa
import Charts

open class ScatterChartViewController: NSViewController
{
    @IBOutlet var chartView: ScatterChartView!
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Scatter Chart"
    }
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()

        chartView.chartDescription?.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.setScaleEnabled ( true)
        chartView.maxVisibleCount = 200
        
        let l = chartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.drawInside = false
        l.font = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        l.xOffset = 5.0
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        leftAxis.axisMinimum = 0.0
        // this replaces startAtZero = YES
        
        chartView.rightAxis.enabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelFont = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        xAxis.drawGridLinesEnabled = false
        
        setDataCount(45, range: 100.0)
    }
    
    func setDataCount(_ count: Int, range: Double)
    {
        var yVals1 = [ChartDataEntry]()
        var yVals2 = [ChartDataEntry]()
        var yVals3 = [ChartDataEntry]()
        
        for i in 0..<count
        {
            var val = Double(arc4random_uniform(UInt32(range))) + 3
            yVals1.append(ChartDataEntry(x: Double(i), y: val))
            val = Double(arc4random_uniform(UInt32(range))) + 3
            yVals2.append(ChartDataEntry(x: Double(i) + 0.33, y: val))
            val = Double(arc4random_uniform(UInt32(range))) + 3
            yVals3.append(ChartDataEntry(x: Double(i) + 0.66, y: val))
        }
        
        let set1 = ScatterChartDataSet(values: yVals1, label: "DS 1")
        set1.setScatterShape(.square )
        set1.colors =  ChartColorTemplates.liberty()
        
        let set2 = ScatterChartDataSet(values: yVals2, label: "DS 2")
        set2.setScatterShape( .circle)
        set2.scatterShapeHoleColor = NSUIColor.blue
        set2.scatterShapeHoleRadius = 3.5
        set2.colors = ChartColorTemplates.material()
        
        let set3 = ScatterChartDataSet(values: yVals3, label: "DS 3")
        set3.setScatterShape(.cross)
        set3.colors = ChartColorTemplates.pastel()
        
        set1.scatterShapeSize = 8.0
        set2.scatterShapeSize = 8.0
        set3.scatterShapeSize = 8.0
        
        var dataSets = [ScatterChartDataSet]()
        dataSets.append(set1)
        dataSets.append(set2)
        dataSets.append(set3)
        
        let data = ScatterChartData(dataSets: dataSets)
        data.setValueFont( NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(7.0)))
        chartView.data = data
    }
}











