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

open class BarDemoViewController: NSViewController
{
    @IBOutlet var barChartView: BarChartView!
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let xs = Array(1..<10).map { return Double($0) }
        let ys1 = xs.map { i in return sin(Double(i / 2.0 / 3.141 * 1.5)) }
        let ys2 = xs.map { i in return cos(Double(i / 2.0 / 3.141)) }
        
        let yse1 = ys1.enumerated().map { idx, i in return BarChartDataEntry(value: i, xIndex: idx) }
        let yse2 = ys2.enumerated().map { idx, i in return BarChartDataEntry(value: i, xIndex: idx) }
        
        let data = BarChartData(xVals: xs as [NSObject])
        let ds1 = BarChartDataSet(yVals: yse1, label: "Hello")
        ds1.colors = [NSUIColor.red]
        data.addDataSet(ds1)
        
        let ds2 = BarChartDataSet(yVals: yse2, label: "World")
        ds2.colors = [NSUIColor.blue]
        data.addDataSet(ds2)
        self.barChartView.data = data
        
        self.barChartView.gridBackgroundColor = NSUIColor.white
        
        self.barChartView.descriptionText = "Barchart Demo"
    }
    
    @IBAction func save(_ sender: AnyObject)
    {
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["png"]
        panel.beginSheetModal(for: self.view.window!) { (result) -> Void in
            if result == NSFileHandlingPanelOKButton
            {
                if let path = panel.url?.path
                {
                    do
                    {
                        _ = try self.barChartView.saveToPath(path, format: .png, compressionQuality: 1.0)
                    }
                    catch
                    {
                        print("Saving encounter errors")
                    }
                }
            }
        }
    }
    
    override open func viewWillAppear()
    {
        self.barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
}
