//
//  PieDemoViewController.swift
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

public class PieDemoViewController: NSViewController
{
    @IBOutlet var pieChartView: PieChartView!
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let xs = Array(1..<10).map { return Double($0) }
        let ys1 = xs.map { i in return abs(sin(Double(i / 2.0 / 3.141 * 1.5)) * 100) }
        
        let yse1 = ys1.enumerate().map { idx, i in return ChartDataEntry(value: i, xIndex: idx) }
        
        let data = PieChartData(xVals: xs)
        let ds1 = PieChartDataSet(yVals: yse1, label: "Hello")
        
        ds1.colors = ChartColorTemplates.vordiplom()
        
        data.addDataSet(ds1)
        
        let paragraphStyle: NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .ByTruncatingTail
        paragraphStyle.alignment = .Center
        let centerText: NSMutableAttributedString = NSMutableAttributedString(string: "iOS Charts\nby Daniel Cohen Gindi")
        centerText.setAttributes([NSFontAttributeName: NSFont(name: "HelveticaNeue-Light", size: 15.0)!, NSParagraphStyleAttributeName: paragraphStyle], range: NSMakeRange(0, centerText.length))
        centerText.addAttributes([NSFontAttributeName: NSFont(name: "HelveticaNeue-Light", size: 13.0)!, NSForegroundColorAttributeName: NSColor.grayColor()], range: NSMakeRange(10, centerText.length - 10))
        centerText.addAttributes([NSFontAttributeName: NSFont(name: "HelveticaNeue-LightItalic", size: 13.0)!, NSForegroundColorAttributeName: NSColor(red: 51 / 255.0, green: 181 / 255.0, blue: 229 / 255.0, alpha: 1.0)], range: NSMakeRange(centerText.length - 19, 19))
        
        self.pieChartView.centerAttributedText = centerText
        
        self.pieChartView.data = data
        
        self.pieChartView.descriptionText = "Piechart Demo"
    }
    
    override public func viewWillAppear()
    {
        self.pieChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
    }
}