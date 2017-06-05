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



open class CubicLineChartViewController: DemoBaseViewController
{
    @IBOutlet var chartView: LineChartView!
    
    @IBOutlet var mainMenu: NSMenu!
    
    @IBOutlet weak var sliderX: NSSlider!
    @IBOutlet weak var sliderY: NSSlider!
    
    @IBOutlet weak var sliderTextX: NSTextField!
    @IBOutlet weak var sliderTextY: NSTextField!
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Cubic Line Chart"
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
                mainMenu.addItem(withTitle: option["label"]!, action: #selector(optionTapped(sender:)), keyEquivalent: "")
            }
        }
        
        for item: AnyObject in mainMenu.items
        {
            if let menuItem = item as? NSMenuItem {
                menuItem.target = self
            }
        }
        
        chartView.setViewPortOffsets(left:0.0, top: 20.0, right: 0.0, bottom: 0.0)
        chartView.backgroundColor = NSUIColor(red: CGFloat(104 / 255.0), green: CGFloat(241 / 255.0), blue: CGFloat(175 / 255.0), alpha: 1.0)
        
        chartView.gridBackgroundColor =  #colorLiteral(red: 0.215686274509804, green: 0.709803921568627, blue: 0.898039215686275, alpha: 0.588235294117647)
        chartView.drawGridBackgroundEnabled = true
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled               = true
        chartView.setScaleEnabled(true)
        chartView.drawGridBackgroundEnabled = false
        chartView.maxHighlightDistance      = 300.0
        
        chartView.xAxis.enabled    = false
        
        let yAxis                  = chartView.leftAxis
        yAxis.labelFont            = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(12.0))!
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor       = NSUIColor.white
        yAxis.labelPosition        = .insideChart
        yAxis.drawGridLinesEnabled = false
        yAxis.axisLineColor        = NSUIColor.white
        
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        
        sliderX.doubleValue = 45.0
        sliderY.doubleValue = 100.0
        slidersValueChanged(sliderX)
        
        chartView.animate(xAxisDuration: 2.5, yAxisDuration : 2.0)
    }
    
    func updateChartData()
    {
        setDataCount(Int(sliderX.intValue) + 1, range: sliderY.doubleValue)
    }
    
    func setDataCount(_ count: Int, range: Double)
    {
        var yVals1 = [ChartDataEntry]()
        for i in 0..<count
        {
            let mult: Double = (range + 1)
            let val = Double(arc4random_uniform(UInt32(mult))) + 20
            yVals1.append(ChartDataEntry(x: Double(i), y: val))
        }
        
        var set1 = LineChartDataSet()
        if chartView.data != nil
        {
            set1 = chartView.data!.dataSets[0] as! LineChartDataSet
            set1.values = yVals1
            chartView.notifyDataSetChanged()
        }
        else
        {
            set1 = LineChartDataSet(values: yVals1, label: "DataSet 1")
            set1.valueFont = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(9.0))!
            set1.drawValuesEnabled = false
            
            set1.mode                                    = .cubicBezier
            set1.cubicIntensity                          = 0.2
            set1.drawCirclesEnabled                      = false
            set1.lineWidth                               = 1.8
            set1.circleRadius                            = 4.0
            set1.highlightColor                          = NSUIColor(red: CGFloat(244 / 255.0), green: CGFloat(117 / 255.0), blue: CGFloat(117 / 255.0), alpha: 1.0)
            set1.colors                                  = [NSUIColor.white]
            set1.fillColor                               = NSUIColor.white
            set1.fillAlpha                               = 1.0
            set1.drawHorizontalHighlightIndicatorEnabled = false
            
            // add fill gradient
            //let locations: [CGFloat] = [ 0.0, 1.0 ]
            //let colors = [NSUIColor.white.cgColor, NSUIColor.cyan.cgColor] as CFArray
            //let colorspace = CGColorSpaceCreateDeviceRGB()
            
            //let gradient = CGGradient(colorsSpace: colorspace, colors: colors, locations: locations)
            //            set1.fillFormatter = CubicLineSampleFillFormatter()
            //           set1.fillAlpha = 1
            //           set1.fill = Fill(linearGradient: gradient!, angle: 90)
            //           set1.drawFilledEnabled = true
            
            let data = LineChartData(dataSet: set1)
            data.setValueFont(NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(9.0)))
            data.setDrawValues(false)
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
}

// MARK: - ChartViewDelegate
extension CubicLineChartViewController: ChartViewDelegate
{
    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight)
    {
        print("chartValueSelected : x = \(highlight.x)")
    }
    
    public func chartValueNothingSelected(_ chartView: ChartViewBase)
    {
        print("chartValueNothingSelected")
    }
}







