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

open class LineChartTimeViewController: DemoBaseViewController
{
    @IBOutlet var chartView: LineChartView!
    
    @IBOutlet var mainMenu: NSMenu!
    
    @IBOutlet weak var sliderX: NSSlider!
    @IBOutlet weak var sliderTextX: NSTextField!
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Time Line Chart"
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
                       ["label": "Toggle separator"],
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
                mainMenu.addItem(withTitle: option["label"]!, action: #selector(LineChartTimeViewController.optionTapped(sender:)), keyEquivalent: "")
            }
        }
        for item in mainMenu.items
        {
            item.target = self
        }
        
        // MARK: General
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.highlightPerDragEnabled = true
        chartView.backgroundColor = NSUIColor.white
        
        // MARK: xAxis
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        xAxis.labelTextColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = true
        xAxis.drawLimitLinesBehindDataEnabled = true
        xAxis.avoidFirstLastClippingEnabled = false
        xAxis.granularity = 1.0
        xAxis.spaceMin = xAxis.granularity / 5
        xAxis.spaceMax = xAxis.granularity / 5
        xAxis.labelRotationAngle = -75.0
        
        // MARK: leftAxis
        let leftAxis = chartView.leftAxis
        leftAxis.labelPosition = .outsideChart
        leftAxis.labelFont = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(12.0))!
        leftAxis.labelTextColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        leftAxis.axisMinimum = 0.0
        leftAxis.axisMaximum = 120.0
        leftAxis.yOffset = -9.0
        
        // MARK: rightAxis
        chartView.rightAxis.enabled = false
        
        // MARK: legend
        chartView.legend.enabled = true
        chartView.legend.form = .line
        
        // MARK: description
        chartView.chartDescription?.enabled = true
        chartView.chartDescription?.text = "Time Line Chart"
        
        sliderX.doubleValue = 20.0
        slidersValueChanged(sliderX)
    }
    
    func updateChartData()
    {
        setDataCount(Int(sliderX.intValue) , range: 30.0)
    }
    
    func setDataCount(_ count: Int, range: Double)
    {
        // MARK: ChartDataEntry
        let now = Date().timeIntervalSince1970
        let hourSeconds = 3600.0
        var values = [ChartDataEntry]()
        let from: TimeInterval = now - (Double(count) / 2.0) * hourSeconds
        let to: TimeInterval = now + (Double(count) / 2.0) * hourSeconds
        
        var x = from
        while x < to {
            let y = Double(arc4random_uniform(UInt32(range)) + 50)
            let x1 = (x - from) / hourSeconds
            values.append(ChartDataEntry(x: x1 , y: y))
            x += hourSeconds
        }
        chartView.xAxis.labelCount = 50
        chartView.xAxis.valueFormatter = DateValueFormatter(miniTime : from, interval: hourSeconds)
        
        
        let  marker = XYMarkerView( color: #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1), font: NSFont.systemFont(ofSize: 12.0),
                                    textColor: NSColor.blue,
                                    insets: NSEdgeInsetsMake(8.0, 8.0, 20.0, 8.0),
                                    xAxisValueFormatter: DateValueFormatter(miniTime: from, interval: hourSeconds),
                                    yAxisValueFormatter: DoubleAxisValueFormatter(postFixe: ""))
        marker.minimumSize = CGSize( width: 80.0, height :40.0)
        chartView.marker = marker
        
        // MARK: LineChartDataSet
        var set =  LineChartDataSet()
        if chartView.data != nil
        {
            set = (chartView.data?.dataSets[0] as? LineChartDataSet)!
            set.values = values
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        }
        else
        {
            set = LineChartDataSet(values: values, label: "DataSet 1")
            set.axisDependency = .left
            set.valueTextColor = NSUIColor(red: 0.215686274509804, green: 0.709803921568627, blue: 0.898039215686275, alpha: 1.0)
            set.lineWidth = 1.5
            set.drawCirclesEnabled = true
            set.drawValuesEnabled = true
            set.drawFilledEnabled = true
            set.fillAlpha = 0.26
            set.fillColor = NSUIColor(red: 0.215686274509804, green: 0.709803921568627, blue: 0.898039215686275, alpha: 1.0)
            set.highlightColor = NSUIColor(red: CGFloat(224 / 255.0), green: CGFloat(117 / 255.0), blue: CGFloat(117 / 255.0), alpha: 1.0)
            set.drawCircleHoleEnabled = true
            
            var dataSets = [LineChartDataSet]()
            dataSets.append(set)
            
            // MARK: LineChartData
            let data = LineChartData(dataSets: dataSets)
            data.setValueTextColor ( NSUIColor.blue)
            data.setValueFont ( NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(9.0)))
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
        updateChartData()
    }
    
    // Zoom Buttons
    @IBAction func zoomAll(_ sender: AnyObject) {
        chartView.fitScreen()
        
    }
    
    @IBAction func zoomIn(_ sender: AnyObject) {
        chartView.zoomToCenter(scaleX: 1.5, scaleY: 1) //, x: view.frame.width, y: 0)
        
    }
    
    @IBAction func zoomOut(_ sender: AnyObject) {
        chartView.zoomToCenter(scaleX: 2/3, scaleY: 1) //, x: view.frame.width, y: 0)
        
    }
    
}

