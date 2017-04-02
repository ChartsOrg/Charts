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

open class HorizontalBarChartViewController: DemoBaseViewController
{
    @IBOutlet var chartView: HorizontalBarChartView!
    
    @IBOutlet var mainMenu: NSMenu!
    
    @IBOutlet weak var sliderX: NSSlider!
    @IBOutlet weak var sliderY: NSSlider!
    
    @IBOutlet weak var sliderTextX: NSTextField!
    @IBOutlet weak var sliderTextY: NSTextField!
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Horizontal Bar Chart"
    }
    
    override open func viewWillAppear()
    {
        chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        let options = [["label": "Zoom In"],
                       ["label": "Zoom out"],
                       ["label": "Reset Zoom"],
                       ["label": "separator"],
                       ["label": "Toggle Values"],
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
                mainMenu.addItem(withTitle: option["label"]!, action: #selector(HorizontalBarChartViewController.optionTapped(sender:)), keyEquivalent: "")
            }
        }
        for item in mainMenu.items
        {
            item.target = self
        }
        
        // MARK: General
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.maxVisibleCount = 60
        chartView.fitBars = true
        
        // MARK: xAxis
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = NSUIFont.systemFont(ofSize: CGFloat(10.0))
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity = 10.0
        
        // MARK: leftAxis
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = NSUIFont.systemFont(ofSize: CGFloat(10.0))
        leftAxis.drawAxisLineEnabled = true
        leftAxis.drawGridLinesEnabled = true
        leftAxis.axisMinimum = 0.0
        
        // MARK: rightAxis
        let rightAxis                  = chartView.rightAxis
        rightAxis.enabled              = true
        rightAxis.labelFont            = NSUIFont.systemFont(ofSize: CGFloat(10.0))
        rightAxis.drawAxisLineEnabled  = true
        rightAxis.drawGridLinesEnabled = false
        rightAxis.axisMinimum          = 0.0
        
        // MARK: legend
        let l = chartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formSize = 8.0
        l.font = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(11.0))!
        l.xEntrySpace = 4.0
        
        // MARK: description
        chartView.chartDescription?.text = "Horizontal Bar Chart"

        sliderX.doubleValue = 12.0
        sliderY.doubleValue = 50.0
        slidersValueChanged(sliderX)
    }
    
    func updateChartData()
    {
        setDataCount(Int(sliderX.intValue) + 1, range: sliderY.doubleValue)
    }
    
    func setDataCount(_ count: Int, range: Double)
    {
        let barWidth = 9.0
        let spaceForBar = 10.0
        
        // MARK: BarChartDataEntry
        var yVals = [BarChartDataEntry]()
        for i in 0..<count
        {
            let mult = range + 1.0
            let val = Double(arc4random_uniform(UInt32(mult)))
            yVals.append(BarChartDataEntry(x: Double(i) * spaceForBar, y: val))
        }
        
        // MARK: BarChartDataSet
        var set1 = BarChartDataSet()
        if chartView.data != nil
        {
            set1 = ( chartView.data?.dataSets[0] as? BarChartDataSet)!
            set1.values = yVals
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        }
        else
        {
            set1 = BarChartDataSet(values: yVals, label: "DataSet")
            
            // MARK: BarChartData
            let data            = BarChartData(dataSets: [set1])
            data.setValueFont(NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(10.0)))
            data.barWidth       = barWidth
            chartView.data = data
        }
    }
    
    func optionTapped( sender: NSMenuItem)
    {
        switch (sender.title)
        {
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


