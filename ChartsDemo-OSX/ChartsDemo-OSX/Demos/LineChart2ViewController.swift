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

open class LineChart2ViewController: DemoBaseViewController
{
    
    @IBOutlet var chartView: LineChartView!
    
    @IBOutlet var mainMenu: NSMenu!
    
    @IBOutlet weak var sliderX: NSSlider!
    @IBOutlet weak var sliderY: NSSlider!
    
    @IBOutlet weak var sliderTextX: NSTextField!
    @IBOutlet weak var sliderTextY: NSTextField!
    
    override open func viewDidAppear() {
        super.viewDidAppear()
        view.window!.title = "Line Chart 2 (Dual YAxis)"
    }
    
    override open func viewWillAppear()
    {
        chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        let options = [["label": "Toggle Values"],
                       ["label": "Toggle Filled"],
                       ["label": "Toggle Circles"],
                       ["label": "Toggle Cubic"],
                       ["label": "Toggle Horizontal Cubic"],
                       ["label": "Toggle Stepped"],
                       ["label": "separator"],
                       ["label": "Toggle Highlight"],
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
                mainMenu.addItem(withTitle: option["label"]!, action: #selector(LineChart2ViewController.optionTapped(sender:)), keyEquivalent: "")
            }
        }
        for item in mainMenu.items
        {
            item.target = self
        }
        
        // MARK: General
        chartView.dragEnabled = true
        chartView.setScaleEnabled ( true)
        chartView.drawGridBackgroundEnabled = false
        chartView.pinchZoomEnabled = true
        chartView.drawBordersEnabled = true
        chartView.backgroundColor = NSUIColor(white: CGFloat(204 / 255.0), alpha: 1.0)
        
        // MARK: xAxis
        let xAxis = chartView.xAxis
        xAxis.labelFont = NSUIFont.systemFont(ofSize: CGFloat(12.0))
        xAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.labelPosition = .bottom
        
        // MARK: leftAxis
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = #colorLiteral(red: 0.215686274509804, green: 0.709803921568627, blue: 0.898039215686275, alpha: 1.0)
        leftAxis.axisMaximum = 200.0
        leftAxis.axisMinimum = 0.0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.drawZeroLineEnabled = false
        leftAxis.granularityEnabled = true
        
        // MARK: rightAxis
        let rightAxis = chartView.rightAxis
        rightAxis.labelTextColor = #colorLiteral(red: 1, green: 0.1474981606, blue: 0, alpha: 1)
        rightAxis.axisMaximum = 900.0
        rightAxis.axisMinimum = -200.0
        rightAxis.drawGridLinesEnabled = false
        rightAxis.granularityEnabled = false
        
        // MARK: legend
        let legend = chartView.legend
        legend.form = .line
        legend.font = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(12.0))!
        legend.textColor = NSUIColor.black
        legend.horizontalAlignment = .left
        legend.orientation = .horizontal
        legend.drawInside = true
        legend.verticalAlignment = .top

        // MARK: description
        chartView.chartDescription?.enabled = false
        
        sliderX.doubleValue = 20.0
        sliderY.doubleValue = 30.0
        slidersValueChanged(sliderX)
    }
    
    func updateChartData() {
        setDataCount(Int(sliderX.intValue) + 1, range: sliderY.doubleValue)
    }
    
    func setDataCount(_ count: Int, range: Double)
    {
        // MARK: ChartDataEntry
        var yVals1 = [ChartDataEntry]()
        var yVals2 = [ChartDataEntry]()
        var yVals3 = [ChartDataEntry]()
        
        for i in 0..<count {
            let mult: Double = range / 2.0
            let val = Double(arc4random_uniform(UInt32(mult))) + 50
            yVals1.append(ChartDataEntry(x: Double(i), y: val))
        }
        
        for i in 0..<count - 1 {
            let mult: Double = range
            let val = Double(arc4random_uniform(UInt32(mult))) + 450
            yVals2.append(ChartDataEntry(x: Double(i), y: val))
        }
        
        for i in 0..<count {
            let mult: Double = range
            let val = Double(arc4random_uniform(UInt32(mult))) + 500
            yVals3.append(ChartDataEntry(x: Double(i), y: val))
        }
        
        // MARK: LineChartDataSet
        var set1 = LineChartDataSet()
        var set2 = LineChartDataSet()
        var set3 = LineChartDataSet()
        if chartView.data != nil
        {
            set1 = (chartView.data?.dataSets[0] as? LineChartDataSet)!
            set2 = (chartView.data?.dataSets[1] as? LineChartDataSet)!
            set3 = (chartView.data?.dataSets[2] as? LineChartDataSet)!
            set1.values = yVals1
            set2.values = yVals2
            set3.values = yVals3
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        }
        else
        {
            set1 = LineChartDataSet(values: yVals1, label: "DataSet 1")
            set1.axisDependency = .left
            set1.colors = [#colorLiteral(red: 0.215686274509804, green: 0.709803921568627, blue: 0.898039215686275, alpha: 1.0)]
            set1.circleColors = [NSUIColor.white]
            set1.lineWidth = 2.0
            set1.circleRadius = 3.0
            set1.fillAlpha = 65 / 255.0
            set1.fillColor = #colorLiteral(red: 0.215686274509804, green: 0.709803921568627, blue: 0.898039215686275, alpha: 1.0)
            set1.highlightColor = NSUIColor.blue
            set1.highlightEnabled = true
            set1.drawCircleHoleEnabled = false
            
            set2 = LineChartDataSet(values: yVals2, label: "DataSet 2")
            set2.axisDependency = .right
            set2.colors = [NSUIColor.red]
            set2.circleColors = [NSUIColor.white]
            set2.lineWidth = 2.0
            set2.circleRadius = 3.0
            set2.fillAlpha = 65 / 255.0
            set2.fillColor = NSUIColor.red
            set2.highlightColor = NSUIColor.red
            set2.highlightEnabled = true
            set2.drawCircleHoleEnabled = false
            
            set3 = LineChartDataSet(values: yVals3, label: "DataSet 3")
            set3.axisDependency = .right
            set3.colors = [NSUIColor.green]
            set3.circleColors = [NSUIColor.white]
            set3.lineWidth = 2.0
            set3.circleRadius = 3.0
            set3.fillAlpha = 65 / 255.0
            set3.fillColor = NSUIColor.yellow.withAlphaComponent(200 / 255.0)
            set3.highlightColor = NSUIColor.green
            set3.highlightEnabled = true
            set3.drawCircleHoleEnabled = false
            
            var dataSets = [LineChartDataSet]()
            dataSets.append(set1)
            dataSets.append(set2)
            dataSets.append(set3)
            
            // MARK: LineChartData
           let data = LineChartData(dataSets: dataSets)
            data.setValueTextColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            data.setValueFont(NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(9.0)))
            chartView.data = data
        }
    }
    
    func optionTapped( sender: NSMenuItem)
    {
        switch (sender.title)
        {
        case "Toggle Filled":
            for  i in 0..<chartView.data!.dataSets.count
            {
                let set = chartView.data!.dataSets[i] as! LineRadarChartDataSet
                set.drawFilledEnabled = !set.isDrawFilledEnabled
            }
            chartView.needsDisplay = true
            
        case "Toggle Circles":
            for  i in 0..<chartView.data!.dataSets.count
            {
                let set = chartView.data!.dataSets[i] as! LineChartDataSet
                set.drawCirclesEnabled = !set.isDrawCirclesEnabled
            }
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
        sliderTextX.stringValue =  String(Int( sliderX.intValue))
        sliderTextY.stringValue =  String(Int( sliderY.intValue))
        updateChartData()
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


