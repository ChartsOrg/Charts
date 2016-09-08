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

open class LineDemoViewController: NSViewController
{
    @IBOutlet var lineChartView: LineChartView!
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let xs = Array(1..<10).map { return Double($0) }
        let ys1 = xs.map { i in return sin(Double(i / 2.0 / 3.141 * 1.5)) }
        let ys2 = xs.map { i in return cos(Double(i / 2.0 / 3.141)) }
        
        let yse1 = ys1.enumerated().map { idx, i in return ChartDataEntry(value: i, xIndex: idx) }
        let yse2 = ys2.enumerated().map { idx, i in return ChartDataEntry(value: i, xIndex: idx) }
        
        let data = LineChartData(xVals: xs as [NSObject])
        let ds1 = LineChartDataSet(yVals: yse1, label: "Hello")
        ds1.colors = [NSUIColor.red]
        data.addDataSet(ds1)
        
        let ds2 = LineChartDataSet(yVals: yse2, label: "World")
        ds2.colors = [NSUIColor.blue]
        data.addDataSet(ds2)
        self.lineChartView.data = data
        
        self.lineChartView.gridBackgroundColor = NSUIColor.white

        self.lineChartView.descriptionText = "Linechart Demo"
    }
    
    override open func viewWillAppear()
    {
        self.lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
    }
}
