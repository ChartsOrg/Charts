//
//  FeedItem.swift
//  ChartsDemo-OSX
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  Copyright © 2017 thierry Hentic.
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
    
    override open func viewWillAppear()
    {
        chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        // MARK: General
        chartView.drawGridBackgroundEnabled = false
        chartView.setScaleEnabled ( true)
        chartView.maxVisibleCount = 200
        
        // MARK: xAxis
        let xAxis = chartView.xAxis
        xAxis.labelFont = NSUIFont(name: "HelveticaNeue-Light", size: 10.0)!
        xAxis.drawGridLinesEnabled = true
        
        // MARK: leftAxis
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = NSUIFont(name: "HelveticaNeue-Light", size: 10.0)!
        leftAxis.axisMinimum = 0.0
        // this replaces startAtZero = YES
        
        // MARK: rightAxis
        chartView.rightAxis.enabled = false
        
        // MARK: legend
        let legend = chartView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.drawInside = false
        legend.font = NSUIFont(name: "HelveticaNeue-Light", size: 10.0)!
        legend.xOffset = 5.0
        
        // MARK: description
        chartView.chartDescription?.enabled = false
        
        setDataCount(45, range: 100.0)
    }
    
    func setDataCount(_ count: Int, range: Double)
    {
        // MARK: ChartDataEntry
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
        
        // MARK: ScatterChartDataSet
        let set1 = ScatterChartDataSet(values: yVals1, label: "DS 1")
        set1.setScatterShape(.square )
        set1.colors =  ChartColorTemplates.liberty()
        set1.scatterShapeSize = 10.0
        
        let set2 = ScatterChartDataSet(values: yVals2, label: "DS 2")
        set2.setScatterShape( .circle)
        set2.scatterShapeHoleColor = NSUIColor.blue
        set2.scatterShapeHoleRadius = 3.5
        set2.colors = ChartColorTemplates.material()
        set2.scatterShapeSize = 10.0
        
        let set3 = ScatterChartDataSet(values: yVals3, label: "DS 3")
        set3.setScatterShape(.triangle)
        set3.colors = [NSUIColor.orange] //ChartColorTemplates.pastel()
        set3.scatterShapeSize = 10.0
        
        var dataSets = [ScatterChartDataSet]()
        dataSets.append(set1)
        dataSets.append(set2)
        dataSets.append(set3)
        
        // MARK: ScatterChartData
        let data = ScatterChartData(dataSets: dataSets)
        data.setValueFont( NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(7.0)))
        chartView.data = data
    }
    
    @IBAction func zoomAll(_ sender: AnyObject)
    {
        chartView.fitScreen()
    }
    
    @IBAction func zoomIn(_ sender: AnyObject)
    {
        chartView.zoomToCenter(scaleX: 1.5, scaleY: 1)
    }
    
    @IBAction func zoomOut(_ sender: AnyObject)
    {
        chartView.zoomToCenter(scaleX: 2/3, scaleY: 1)
    }
    
}











