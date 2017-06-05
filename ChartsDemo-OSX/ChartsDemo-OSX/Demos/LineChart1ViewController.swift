//
//  vc2Controller.swift
//  newGraph2
//
//  Created by thierryH24A on 23/06/2016.
//  Copyright © 2016 thierryH24A. All rights reserved.
//

import Foundation
import Cocoa

import Charts

private var defaultsContext = 0

open class LineChart1ViewController: DemoBaseViewController
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
        view.window?.title = "Line Chart"
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
                mainMenu.addItem(withTitle: option["label"]!, action: #selector(LineChart1ViewController.optionTapped(sender:)), keyEquivalent: "")
            }
        }
        for item in mainMenu.items
        {
            item.target = self
        }
        
        let background = CAGradientLayer().turquoiseColor
        background().frame = view.bounds
        view.wantsLayer = true
        view.layer?.addSublayer(background())
        chartView.backgroundColor = #colorLiteral(red: 0.6980392157, green: 0.8431372549, blue: 1, alpha: 1)
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled( true)
        chartView.pinchZoomEnabled = true
        chartView.drawGridBackgroundEnabled = false
        chartView.drawBordersEnabled = true
        
        // x-axis limit line
        let llXAxis = ChartLimitLine(limit: 10.0, label: "Index 10")
        llXAxis.lineWidth = 4.0
        llXAxis.lineColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
        llXAxis.lineDashLengths = [10.0, 10.0, 0.0]
        llXAxis.valueTextColor = NSUIColor.black
        llXAxis.valueFont = NSUIFont.systemFont(ofSize: CGFloat(10.0))
        llXAxis.labelPosition = .rightBottom
        
        
        let llXAxis2 = ChartLimitLine(limit: 30.0, label: "Index 30")
        llXAxis2.lineWidth = 4.0
        llXAxis2.lineDashLengths = [10.0, 10.0, 0.0]
        llXAxis2.labelPosition = .rightBottom
        llXAxis2.valueFont = NSUIFont.systemFont(ofSize: CGFloat(10.0))
        llXAxis2.lineColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        
        let xAxis = chartView.xAxis
        xAxis.addLimitLine(llXAxis)
        xAxis.addLimitLine(llXAxis2)
        xAxis.gridLineDashLengths = [10.0, 10.0]
        xAxis.gridLineDashPhase = 0.0
        
        // leftAxis limit line
        let ll1 = ChartLimitLine(limit: 150.0, label: "Upper Limit")
        ll1.lineWidth = 4.0
        ll1.lineDashLengths = [5.0, 5.0]
        ll1.labelPosition = .rightTop
        ll1.valueFont = NSUIFont.systemFont(ofSize: CGFloat(10.0))
        
        let ll2 = ChartLimitLine(limit: -30.0, label: "Lower Limit")
        ll2.lineWidth = 4.0
        ll2.lineDashLengths = [5.0, 5.0]
        ll2.labelPosition = .rightBottom
        ll2.valueFont = NSUIFont.systemFont(ofSize: CGFloat(10.0))

        let leftAxis = chartView.leftAxis
        leftAxis.removeAllLimitLines()
        leftAxis.addLimitLine(ll1)
        leftAxis.addLimitLine(ll2)
        leftAxis.axisMaximum = 200.0
        leftAxis.axisMinimum = -50.0
        leftAxis.gridLineDashLengths = [5.0, 5.0]
        leftAxis.drawZeroLineEnabled = false
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        chartView.rightAxis.enabled = false
        //[_chartView.viewPortHandler setMaximumScaleY: 2.f];
        //[_chartView.viewPortHandler setMaximumScaleX: 2.f];
        let marker = BalloonMarker(color: NSUIColor(white: CGFloat(180 / 255.0), alpha: 1.0), font: NSUIFont.systemFont(ofSize: CGFloat(12.0)), textColor: NSUIColor.white, insets: NSEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: CGFloat(80.0), height: CGFloat(40.0))
        chartView.marker = marker
        
        chartView.legend.form = .line
        
        sliderX.doubleValue = 45.0
        sliderY.doubleValue = 100.0
        slidersValueChanged(sliderX)
        chartView.animate(xAxisDuration: 1.0)
    }
    
    func updateChartData()
    {
        setDataCount(Int(sliderX.intValue), range: sliderY.doubleValue)
    }
    
    func setDataCount(_ count: Int, range: Double)
    {
        var values = [ChartDataEntry]()
        
        for i in 0..<count {
            let val: Double = Double(arc4random_uniform(UInt32(range)) + 3)
            values.append(ChartDataEntry(x: Double(i), y: val))
        }
        var set1 = LineChartDataSet()
        
        if chartView.data != nil
        {
            set1 = (chartView.data?.dataSets[0] as? LineChartDataSet)!
            set1.values = values
            
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        }
        else
        {
            set1 = LineChartDataSet(values: values, label: "DataSet 1")
            set1.lineDashLengths = [5.0, 2.5]
            set1.highlightLineDashLengths = [5.0, 2.5]
            set1.colors = [#colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1)]
            set1.circleColors = [NSUIColor.black]
            set1.lineWidth = 1.0
            set1.circleRadius = 3.0
            set1.drawCircleHoleEnabled = false
            set1.valueFont = NSUIFont.systemFont(ofSize: CGFloat(9.0))
            set1.formLineDashLengths = [5.0, 2.5]
            set1.formLineWidth = 1.0
            set1.formSize = 15.0
            
            let gradientColors =
                [(ChartColorTemplates.colorFromString( "#00ff0000").cgColor ),
                 (ChartColorTemplates.colorFromString( "#ffff0000").cgColor )]
            
            let gradient: CGGradient? = CGGradient(colorsSpace: nil, colors: (gradientColors as CFArray?)!, locations: nil)
            set1.fillAlpha = 1.0
            set1.fill = Fill(linearGradient: gradient!, angle: 90.0)
            set1.drawFilledEnabled = true
            var dataSets = [LineChartDataSet]()
            dataSets.append(set1)
            
            let data = LineChartData(dataSets: dataSets)
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
    
    @IBAction func slidersValueChanged(_ sender: AnyObject) {
        sliderTextX.stringValue =  String(Int( sliderX.intValue))
        sliderTextY.stringValue =  String(Int( sliderY.intValue))
        updateChartData()
    }
}

extension NSView {
    func backgroundColorP(color: NSColor) {
        wantsLayer = true
        layer?.backgroundColor = color.cgColor
    }
}

extension CAGradientLayer {
    
    func turquoiseColor() -> CAGradientLayer {
        let topColor = NSUIColor(red: (15/255.0), green: (118/255.0), blue: (128/255.0), alpha: 1)
        let bottomColor = NSUIColor(red: (84/255.0), green: (187/255.0), blue: (187/255.0), alpha: 1)
        
        let gradientColors: Array <AnyObject> = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations: Array <NSNumber> = [0.0 , 1.0 ]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
    }
}

//glmgfk
