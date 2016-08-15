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
        let ys1 = Array(1..<10).map { x in return sin(Double(x) / 2.0 / 3.141 * 1.5) }
        let ys2 = Array(1..<10).map { x in return cos(Double(x) / 2.0 / 3.141) }
        
        let yse1 = ys1.enumerate().map { x, y in return BarChartDataEntry(x: Double(x), y: y) }
        let yse2 = ys2.enumerate().map { x, y in return BarChartDataEntry(x: Double(x), y: y) }
        
        let data = BarChartData()
        let ds1 = BarChartDataSet(values: yse1, label: "Hello")
        ds1.colors = [NSUIColor.redColor()]
        data.addDataSet(ds1)
        
        let ds2 = BarChartDataSet(values: yse2, label: "World")
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