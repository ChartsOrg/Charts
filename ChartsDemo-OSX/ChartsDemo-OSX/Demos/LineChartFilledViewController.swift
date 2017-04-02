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

open class LineChartFilledViewController: DemoBaseViewController
{
    
    @IBOutlet var chartView: LineChartView!
    
    @IBOutlet var mainMenu: NSMenu!
    
    let interval = 3600.0 * 24.0
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Filled Line Chart"
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
                mainMenu.addItem(withTitle: option["label"]!, action: #selector(LineChartFilledViewController.optionTapped(sender:)), keyEquivalent: "")
            }
        }
        for item in mainMenu.items
        {
            item.target = self
        }
        
        // MARK: General
        chartView.backgroundColor = NSUIColor.white
        chartView.gridBackgroundColor = #colorLiteral(red: 0.215686274509804, green: 0.709803921568627, blue: 0.898039215686275, alpha: 0.588235294117647)
        chartView.drawGridBackgroundEnabled = true
        chartView.drawBordersEnabled = true
        chartView.pinchZoomEnabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled ( true)
        
        
        // MARK: xAxis
        let xAxis  = chartView.xAxis
        xAxis.enabled = true
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = DateValueFormatter(miniTime: range1[0][0] / 1000, interval: interval)
        xAxis.labelCount = 7
        
        // MARK: leftAxis
        let leftAxis = chartView.leftAxis
        leftAxis.axisMaximum = 40.0
        leftAxis.axisMinimum = -20.0
        leftAxis.drawAxisLineEnabled = true
        leftAxis.drawZeroLineEnabled = false
        leftAxis.drawGridLinesEnabled = true
        leftAxis.axisLineColor = NSUIColor.black
        
        // MARK: rightAxis
        chartView.rightAxis.enabled = false
        
        // MARK: legend
        let legend = chartView.legend
        legend.enabled = false
        
        
        // MARK: description
        chartView.chartDescription?.enabled = false
        
        setDataCount()
    }
    
    func updateChartData()
    {
        setDataCount()
    }
    
    func setDataCount()
    {
        // MARK: ChartDataEntry
        var yVals1 = [ChartDataEntry]()
        var yVals2 = [ChartDataEntry]()
        let miniDate = range1[0][0]
        
        for i in 0..<range1.count
        {
            let x  = ((range1[i][0] - miniDate) / interval) / 1000
            let y1 = range1[i][1]
            let y2 = range1[i][2]
            
            yVals1.append(ChartDataEntry(x: x , y: y1))
            yVals2.append(ChartDataEntry(x: x , y: y2))
        }
        
        // MARK: LineChartDataSet
        var set1 = LineChartDataSet()
        var set2 = LineChartDataSet()
        if chartView.data != nil
        {
            set1 = (chartView.data!.dataSets[0] as! LineChartDataSet )
            set2 = (chartView.data!.dataSets[1] as! LineChartDataSet )
            set1.values = yVals1
            set2.values = yVals2
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        }
        else
        {
            set1 = LineChartDataSet(values: yVals1, label: "DataSet 1")
            set1.axisDependency = .left
            set1.colors = [NSUIColor(red: CGFloat(255 / 255.0), green: CGFloat(241 / 255.0), blue: CGFloat(46 / 255.0), alpha: 1.0)]
            set1.drawCirclesEnabled = false
            set1.lineWidth = 2.0
            set1.circleRadius = 3.0
            set1.fillAlpha = 1.0
            set1.drawFilledEnabled = true
            set1.fillColor = NSUIColor.white
            set1.highlightColor = NSUIColor(red: CGFloat(244 / 255.0), green: CGFloat(117 / 255.0), blue: CGFloat(117 / 255.0), alpha: 1.0)
            set1.drawCircleHoleEnabled = false
            set1.fillFormatter = DefaultFillFormatter.with(block: {(_ dataSet: ILineChartDataSet, _ dataProvider: LineChartDataProvider) -> CGFloat in
                return CGFloat(self.chartView.leftAxis.axisMinimum)
            })
            
            set2 = LineChartDataSet(values: yVals2, label: "DataSet 2")
            set2.axisDependency = .left
            set2.colors = [NSUIColor(red: CGFloat(255 / 255.0), green: CGFloat(241 / 255.0), blue: CGFloat(46 / 255.0), alpha: 1.0)]
            set2.drawCirclesEnabled = false
            set2.lineWidth = 2.0
            set2.circleRadius = 3.0
            set2.fillAlpha = 1.0
            set2.drawFilledEnabled = true
            set2.fillColor = NSUIColor.white
            set2.highlightColor = NSUIColor(red: CGFloat(244 / 255.0), green: CGFloat(117 / 255.0), blue: CGFloat(117 / 255.0), alpha: 1.0)
            set2.drawCircleHoleEnabled = false
            set2.fillFormatter = DefaultFillFormatter.with(block: {(_ dataSet: ILineChartDataSet, _ dataProvider: LineChartDataProvider) -> CGFloat in
                return CGFloat(self.chartView.leftAxis.axisMaximum)
            })
            
            var dataSets = [LineChartDataSet]()
            dataSets.append(set1)
            dataSets.append(set2)
            
            // MARK: LineChartData
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







