//
//  CombinedcombinedChartViewController.swift
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



open class PiePolylineChartViewController: DemoBaseViewController
{
    @IBOutlet var chartView: PieChartView!
    
    @IBOutlet var mainMenu: NSMenu!
    
    @IBOutlet weak var sliderX: NSSlider!
    @IBOutlet weak var sliderY: NSSlider!
    
    @IBOutlet weak var sliderTextX: NSTextField!
    @IBOutlet weak var sliderTextY: NSTextField!
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Pie Chart with Polyline"
    }
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        let options = [["label": "Toggle Values"],
                       ["label": "Toggle xValues"],
                       ["label": "Toggle Percent"],
                       ["label": "Toggle Hole"],
                       ["label": "separator"],
                       ["label": "Animate X"],
                       ["label": "Animate Y"],
                       ["label": "Animate XY"],
                       ["label": "Save to Camera Roll"],
                       ["label": "Toggle PinchZoom"],
                       ["label": "Toggle auto scale min/max"],
                       ["label": "Toggle Data"]]
        
        mainMenu.removeAllItems()
        for option in options
        {
            if option["label"]  == "separator"
            {
                mainMenu.addItem(NSMenuItem.separator())
            }
            else
            {
                mainMenu.addItem(withTitle: option["label"]!, action: #selector(PiePolylineChartViewController.optionTapped(sender:)), keyEquivalent: "")
            }
        }
        for item in mainMenu.items
        {
            item.target = self
        }
        
        setupPieChartView( chartView)
        chartView.legend.enabled = false
        
        //       chartView.setExtraOffsetsWithLeft(20.0, top: 0.0, right: 20.0, bottom: 0.0)
        
        sliderX.doubleValue = 4.0
        sliderY.doubleValue = 100.0
        slidersValueChanged(sliderX)
        chartView.animate(xAxisDuration: 2.5)
    }
    
    
    func updateChartData()
    {
        setDataCount(Int(sliderX.intValue) + 1, range: sliderY.doubleValue)
    }
    
    func setDataCount(_ count: Int, range: Double)
    {
        let mult: Double = range
        var entries = [PieChartDataEntry]()
        for i in 0..<count {
            entries.append(PieChartDataEntry(value: (Double(arc4random_uniform(UInt32(mult))) + mult / 5), label: parties[i % parties.count]))
        }
        let dataSet = PieChartDataSet(values: entries, label: "Election Results")
        dataSet.sliceSpace = 2.0
        
        // add a lot of colors
        var colors = [NSColor]()
        colors.append( ChartColorTemplates.vordiplom()[0] )
        colors.append( ChartColorTemplates.joyful()[0] )
        colors.append( ChartColorTemplates.colorful()[0] )
        colors.append( ChartColorTemplates.liberty()[0])
        colors.append( ChartColorTemplates.pastel()[0] )
        colors.append(#colorLiteral(red: 0.215686274509804, green: 0.709803921568627, blue: 0.898039215686275, alpha: 1.0))
        
        dataSet.colors = colors
        dataSet.valueLinePart1OffsetPercentage = 0.8
        dataSet.valueLinePart1Length = 0.2
        dataSet.valueLinePart2Length = 0.4
        dataSet.xValuePosition = .outsideSlice
        dataSet.yValuePosition = .outsideSlice
        
        let data = PieChartData()
        data.addDataSet(dataSet)
        
        let paragraphStyle: NSMutableParagraphStyle = NSParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let centerText: NSMutableAttributedString = NSMutableAttributedString(string: "Charts\nby Daniel Cohen Gindi")
        centerText.setAttributes([NSFontAttributeName: NSFont(name: "HelveticaNeue-Light", size: 15.0)!, NSParagraphStyleAttributeName: paragraphStyle], range: NSMakeRange(0, centerText.length))
        centerText.addAttributes([NSFontAttributeName: NSFont(name: "HelveticaNeue-Light", size: 13.0)!, NSForegroundColorAttributeName: NSColor.gray], range: NSMakeRange(10, centerText.length - 10))
        
        centerText.addAttributes([NSFontAttributeName: NSFont(name: "HelveticaNeue-LightItalic", size: 13.0)!, NSForegroundColorAttributeName: NSColor(red: 51 / 255.0, green: 181 / 255.0, blue: 229 / 255.0, alpha: 1.0)], range: NSMakeRange(centerText.length - 19, 19))
        
        chartView.centerAttributedText = centerText
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1.0
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(11.0)))
        data.setValueTextColor(NSUIColor.black)
        chartView.data = data
        chartView.highlightValues(nil)
    }
    
    func optionTapped( sender: NSMenuItem)
    {
        switch (sender.title)
        {
        case "Toggle Percent":
            
            chartView.usePercentValuesEnabled = !chartView.isUsePercentValuesEnabled
            chartView.needsDisplay = true
            
        case "Toggle Hole":
            chartView.drawHoleEnabled = !chartView.isDrawHoleEnabled
            chartView.needsDisplay = true
            
        case "Toggle Cubic":
            for  i in 0..<chartView.data!.dataSets.count
            {
                let set = chartView.data!.dataSets[i] as! LineChartDataSet
                set.mode = set.mode == .cubicBezier ? .linear : .cubicBezier
            }
            chartView.needsDisplay = true
            
        case "Toggle Stepped":
            for  i in 0..<chartView.data!.dataSets.count
            {
                let set = chartView.data!.dataSets[i] as! LineChartDataSet
                set.mode = set.mode == .stepped ? .linear : .stepped
            }
            chartView.needsDisplay = true
            
        case "Toggle Horizontal Cubic":
            for  i in 0..<chartView.data!.dataSets.count
            {
                let set = chartView.data!.dataSets[i] as! LineChartDataSet
                set.mode = set.mode == .horizontalBezier ? .linear : .horizontalBezier
            }
            chartView.needsDisplay = true
            
        default:
            super.toggle(sender.title, chartView: chartView)
        }
    }
    
    @IBAction func slidersValueChanged(_ sender: AnyObject)
    {
        sliderTextX.stringValue = String(Int( sliderX.intValue))
        sliderTextY.stringValue = String(Int( sliderY.intValue))
        updateChartData()
    }
    
}


