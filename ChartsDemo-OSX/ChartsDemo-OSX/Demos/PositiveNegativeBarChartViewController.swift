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



open class PositiveNegativeBarChartViewController: DemoBaseViewController
{
    @IBOutlet var chartView: BarChartView!
    
    @IBOutlet var mainMenu: NSMenu!
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Positive Negative Bar Chart"
    }
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        let options = [["label": "Toggle Values"],
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
        for item in mainMenu.items
        {
            item.target = self
        }
        
        chartView.extraTopOffset = -30.0
        chartView.extraBottomOffset = 10.0
        chartView.extraLeftOffset = 70.0
        chartView.extraRightOffset = 70.0
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.chartDescription?.enabled = false
        // scaling can now only be done on x- and y-axis separately
        chartView.pinchZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = NSUIFont.systemFont(ofSize: CGFloat(13.0))
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = true
        xAxis.labelTextColor = NSUIColor.lightGray
        xAxis.labelCount = 5
        xAxis.centerAxisLabelsEnabled = true
        xAxis.granularity = 1.0
        //xAxis.valueFormatter = self
        
        let leftAxis = chartView.leftAxis
        leftAxis.drawLabelsEnabled = false
        leftAxis.spaceTop = 0.25
        leftAxis.spaceBottom = 0.25
        leftAxis.drawAxisLineEnabled = true
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawZeroLineEnabled = true
        leftAxis.zeroLineColor = NSUIColor.gray
        leftAxis.zeroLineWidth = 0.7
        
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        updateChartData()
    }
    
    func updateChartData()
    {
        setChartData()
    }
    
    func setChartData()
    {
        // THIS IS THE ORIGINAL DATA YOU WANT TO PLOT
        var dataList  = [DataList]()
        dataList.append(DataList(xValue: 0, yValue : -224.1, xLabel  : "12-19"))
        dataList.append(DataList(xValue: 1, yValue : 238.5, xLabel : "12-30"))
        dataList.append(DataList(xValue: 2, yValue : 1280.1, xLabel : "12-31"))
        dataList.append(DataList(xValue: 3, yValue : -442.3, xLabel : "01-01"))
        dataList.append(DataList(xValue: 4, yValue : -2280.1,xLabel : "01-02"))
        
        var values = [BarChartDataEntry]()
        var colors = [NSUIColor]()
        let green = NSUIColor.green
        let red = NSUIColor.red
        
        for i in 0..<dataList.count
        {
            let d = dataList[i]
            let entry = BarChartDataEntry(x: d.xValue, y: d.yValue)
            values.append(entry)
            
            // specific colors
            if d.yValue >= 0.0 {
                colors.append(red)
            }
            else {
                colors.append(green)
            }
        }
        
        let set = BarChartDataSet(values: values, label: "Values")
        set.colors = colors
        set.valueColors = colors
        let data = BarChartData(dataSet: set)
        data.setValueFont(NSUIFont.systemFont(ofSize: CGFloat(13.0)))
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        data.setValueFormatter( DefaultValueFormatter(formatter: formatter ))
        data.barWidth = 0.8
        chartView.data = data
    }
    
    func optionTapped( sender: NSMenuItem)
    {
        switch (sender.title)
        {
        default:
            super.toggle(sender.title, chartView: chartView)
        }
    }
}

class DataList{
    var xValue : Double
    var yValue : Double
    var xLabel : String
    init(xValue:Double,yValue:Double,xLabel:String){
        self.xValue = xValue
        self.yValue = yValue
        self.xLabel = xLabel
    }
}

