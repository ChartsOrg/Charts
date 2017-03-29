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



open class SinusBarChartViewController: DemoBaseViewController
{
    @IBOutlet var chartView: BarChartView!
    
    @IBOutlet var mainMenu: NSMenu!
    
    @IBOutlet weak var sliderX: NSSlider!
    @IBOutlet weak var sliderTextX: NSTextField!
    
    override open func viewDidAppear() {
        super.viewDidAppear()
        view.window!.title = "Sinus Bar Chart"
    }
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        let options = [["label": "Back to Brands"],
                       ["label": "separator"],
                       ["label": "Zoom In"],
                       ["label": "Zoom out"],
                       ["label": "Reset Zoom"],
                       ["label": "separator"],
                       ["label": "Toggle Values"],
                       
                       ["label": "begin insert"],
                       ["label": "linear"],
                       ["label": "separator"],
                       
                       ["label": "easeInQuad"],
                       ["label": "easeOutQuad"],
                       ["label": "easeInOutQuad"],
                       ["label": "separator"],
                       
                       ["label": "easeInCubic"],
                       ["label": "easeOutCubic"],
                       ["label": "easeInOutCubic"],
                       ["label": "separator"],
                       
                       ["label": "easeInQuart"],
                       ["label": "easeOutQuart"],
                       ["label": "easeInOutQuart"],
                       ["label": "separator"],
                       
                       ["label": "easeInQuint"],
                       ["label": "easeOutQuint"],
                       ["label": "easeInOutQuint"],
                       ["label": "separator"],
                       
                       ["label": "easeInSine"],
                       ["label": "easeOutSine"],
                       ["label": "easeInOutSine"],
                       ["label": "separator"],
                       
                       ["label": "easeInExpo"],
                       ["label": "easeOutExpo"],
                       ["label": "easeInOutExpo"],
                       ["label": "separator"],
                       
                       ["label": "easeInCirc"],
                       ["label": "easeOutCirc"],
                       ["label": "easeInOutCirc"],
                       ["label": "separator"],
                       
                       ["label": "easeInElastic"],
                       ["label": "easeOutElastic"],
                       ["label": "easeInOutElastic"],
                       ["label": "separator"],
                       
                       ["label": "easeInBack"],
                       ["label": "easeOutBack"],
                       ["label": "easeInOutBack"],
                       ["label": "separator"],
                       
                       ["label": "easeInBounce"],
                       ["label": "easeOutBounce"],
                       ["label": "easeInOutBounce"],
                       
                       ["label": "end insert"],
                       ["label": "Animate ..."],
                       
                       ["label": "Save to Camera Roll"],
                       ["label": "Toggle PinchZoom"],
                       ["label": "Toggle auto scale min/max"],
                       ["label": "Toggle Data"]]
       
        let subMenu = NSMenu()
        mainMenu.removeAllItems()
        subMenu.removeAllItems()
        var subMenuEnabled = false
        var addSubMenuEnable = false
        for option in options
        {
            switch (option["label"]!)
            {
            case "separator" :
                if subMenuEnabled == false && addSubMenuEnable == false
                {
                    mainMenu.addItem(NSMenuItem.separator())
                }
                else
                {
                    subMenu.addItem(NSMenuItem.separator())
                }
                
            case "begin insert" :
                subMenu.removeAllItems()
                subMenuEnabled = true
                
            case "end insert" :
                subMenuEnabled =  false
                addSubMenuEnable =  true
                
            default:
                if subMenuEnabled == false && addSubMenuEnable == false
                {
                    mainMenu.addItem(withTitle: option["label"]!, action: #selector(optionTapped(sender:)), keyEquivalent: "")
                }
                else
                {
                    if subMenuEnabled == true && addSubMenuEnable == false
                    {
                        subMenu.addItem(withTitle: option["label"]!, action: #selector(optionTapped(sender:)), keyEquivalent: "")
                    }
                    else
                    {
                        addSubMenuEnable =  false
                        let subMenuItem = NSMenuItem(title: option["label"]!, action: nil, keyEquivalent: "")
                        mainMenu.addItem(subMenuItem)
                        mainMenu.setSubmenu(subMenu, for: subMenuItem)
                    }
                }
            }
        }
        for item: AnyObject in mainMenu.items {
            if let menuItem = item as? NSMenuItem {
                menuItem.target = self
            }
        }
        
        chartView.chartDescription?.enabled = false
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.maxVisibleCount = 60
        chartView.pinchZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.drawBordersEnabled = true
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        xAxis.drawGridLinesEnabled = false
        xAxis.enabled = false
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        leftAxis.labelCount = 6
        leftAxis.axisMinimum = -2.5
        leftAxis.axisMaximum = 2.5
        leftAxis.granularityEnabled = true
        leftAxis.granularity = 0.1
        
        let rightAxis = chartView.rightAxis
        rightAxis.drawGridLinesEnabled = false
        rightAxis.labelFont = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        rightAxis.labelCount = 6
        rightAxis.axisMinimum = -2.5
        rightAxis.axisMaximum = 2.5
        rightAxis.granularity = 0.1
        
        let l = chartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formSize = 9.0
        l.font = NSUIFont.systemFont(ofSize: CGFloat(11.0))
        l.xEntrySpace = 4.0
        
        sliderX.doubleValue  = 150.0
        slidersValueChanged(sliderX)
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        setDataCount(150)
    }
    
    func updateChartData()
    {
        setDataCount  (Int(sliderX.intValue))
    }
    
    func setDataCount(_ count: Int) {
        
        var entries = [BarChartDataEntry]()
        
        for i in 0..<count
        {
            entries.append(BarChartDataEntry(x: Double(i), y: Double(sinf(Float(.pi * Double(i % 128) / 64.0)))))
        }
        
        var set = BarChartDataSet()
        if chartView.data != nil
        {
            set = (chartView.data?.dataSets[0] as? BarChartDataSet)!
            set.values = entries
            
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        }
        else
        {
            set = BarChartDataSet(values: entries, label: "Sinus Function")
            set.colors = [NSUIColor(red: CGFloat(240 / 255.0), green: CGFloat(120 / 255.0), blue: CGFloat(124 / 255.0), alpha: 1.0)]
        }
        set.valueFont = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        set.drawValuesEnabled = false
        set.barBorderWidth = 0.1
        
        let data = BarChartData(dataSet: set)
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
    
    @IBAction func slidersValueChanged(_ sender: AnyObject)
    {
        sliderTextX.stringValue =  String(Int( sliderX.intValue))
        updateChartData()
    }
}


