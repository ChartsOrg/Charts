//
//  BlockDemoViewController.swift
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

open class BlockDemoViewController: NSViewController
{
    @IBOutlet var BlockChartView: BlockChartView!
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let xArray = Array(1..<10)
        let ys1 = xArray.map { x in return sin(Double(x) / 2.0 / 3.141 * 1.5) }
        let ys2 = xArray.map { x in return cos(Double(x) / 2.0 / 3.141) }
        
        let yse1 = ys1.enumerated().map { x, y in return BlockChartDataEntry(x: Double(x), y: y) }
        let yse2 = ys2.enumerated().map { x, y in return BlockChartDataEntry(x: Double(x), y: y) }
        
        let data = BlockChartData()
        let ds1 = BlockChartDataSet(entries: yse1, label: "Hello")
        ds1.colors = [NSUIColor.red]
        data.addDataSet(ds1)

        let ds2 = BlockChartDataSet(entries: yse2, label: "World")
        ds2.colors = [NSUIColor.blue]
        data.addDataSet(ds2)

        let barWidth = 0.85
        let barSpace = 0.0
        let groupSpace = 0.3
        
        data.barWidth = barWidth
        self.BlockChartView.xAxis.axisMinimum = Double(xArray[0])
        self.BlockChartView.xAxis.axisMaximum = Double(xArray[0]) + data.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(xArray.count)
        // (0.4 + 0.05) * 2 (data set count) + 0.1 = 1
        data.groupBars(fromX: Double(xArray[0]), groupSpace: groupSpace, barSpace: barSpace)

        self.BlockChartView.data = data
        
        self.BlockChartView.gridBackgroundColor = NSUIColor.white
        
        self.BlockChartView.chartDescription?.text = "BlockChart Demo"
    }
    
    @IBAction func save(_ sender: Any)
    {
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["png"]
        panel.beginSheetModal(for: self.view.window!) { (result) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton
            {
                if let path = panel.url?.path
                {
                    let _ = self.BlockChartView.save(to: path, format: .png, compressionQuality: 1.0)
                }
            }
        }
    }
    
    override open func viewWillAppear()
    {
        self.BlockChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
}
