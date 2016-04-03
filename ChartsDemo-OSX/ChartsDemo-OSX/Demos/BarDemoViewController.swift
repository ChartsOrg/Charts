//
//  BarDemoViewController.swift
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

public class BarDemoViewController: NSViewController
{
    @IBOutlet var barChartView: BarChartView!
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let xs = Array(1..<10).map { return Double($0) }
        let ys1 = xs.map { i in return sin(Double(i / 2.0 / 3.141 * 1.5)) }
        let ys2 = xs.map { i in return cos(Double(i / 2.0 / 3.141)) }
        
        let yse1 = ys1.enumerate().map { idx, i in return BarChartDataEntry(value: i, xIndex: idx) }
        let yse2 = ys2.enumerate().map { idx, i in return BarChartDataEntry(value: i, xIndex: idx) }
        
        let data = BarChartData(xVals: xs)
        let ds1 = BarChartDataSet(yVals: yse1, label: "Hello")
        ds1.colors = [NSUIColor.redColor()]
        data.addDataSet(ds1)
        
        let ds2 = BarChartDataSet(yVals: yse2, label: "World")
        ds2.colors = [NSUIColor.blueColor()]
        data.addDataSet(ds2)
        self.barChartView.data = data
        
        self.barChartView.gridBackgroundColor = NSUIColor.whiteColor()
        
        self.barChartView.descriptionText = "Barchart Demo"
    }
    
    @IBAction func save(sender: AnyObject)
    {
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["png"]
        panel.beginSheetModalForWindow(self.view.window!) { (result) -> Void in
            if result == NSFileHandlingPanelOKButton
            {
                if let path = panel.URL?.path
                {
                    self.barChartView.saveToPath(path, format: .PNG, compressionQuality: 1.0)
                }
            }
        }
    }
    
    override public func viewWillAppear()
    {
        self.barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
}