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

open class BarChartViewControllerColumnWithDrilldown: DemoBaseViewController
{
    @IBOutlet var chartView: BarChartView!
    @IBOutlet var mainMenu: NSMenu!
    
    var label  = [String]()
    var dataWebIE = [String]()
    let colors = [NSUIColor.blue, NSUIColor.black, NSUIColor.green, NSUIColor.orange, NSUIColor.purple, NSUIColor.gray]
    
    var browsers = [Browser]()
    
    override open func viewDidAppear() {
        super.viewDidAppear()
        view.window!.title = "Bar Chart Column with drilldown"
    }
    
    override open func viewWillAppear()
    {
        chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
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
        
        if let filePath = Bundle.main.path(forResource: "drillDown", ofType: "plist")
        {
            browsers = Browser.browserList(filePath)
        }
        
        for browser in browsers
        {
            label.append(browser.name)
            dataWebIE.append(browser.y)
        }
        
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
        for item in mainMenu.items
        {
            item.target = self
        }
        
        mainMenu.autoenablesItems = false
        mainMenu.item(at: 0)?.isEnabled = false
        
        let customFormatter = NumberFormatter()
        customFormatter.negativePrefix = ""
        customFormatter.positiveSuffix = "%"
        customFormatter.negativeSuffix = "%"
        customFormatter.minimumSignificantDigits = 1
        customFormatter.minimumFractionDigits = 1
        
        // MARK: General
        chartView.delegate = self
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.maxVisibleCount = 60
        chartView.drawGridBackgroundEnabled = true
        chartView.gridBackgroundColor = NSUIColor.yellow
        
        chartView.highlightPerTapEnabled = true
        chartView.pinchZoomEnabled = false
        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)
        
        // MARK: xAxis
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        xAxis.drawGridLinesEnabled = false
        xAxis.enabled = true
        
        // MARK: leftAxis
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        leftAxis.labelCount = 6
        leftAxis.axisMinimum = 0
        leftAxis.granularityEnabled = true
        leftAxis.granularity = 0.1
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter : customFormatter)
        
        // MARK: rightAxis
        chartView.rightAxis.enabled = false
        
        // MARK: legend
        let legend = chartView.legend
        legend.horizontalAlignment = .left
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.drawInside = false
        legend.form = .square
        legend.formSize = 9.0
        legend.font = NSUIFont.systemFont(ofSize: CGFloat(11.0))
        legend.xEntrySpace = 4.0
        
        // MARK: description
        let bounds = chartView.bounds
        let point = CGPoint( x:bounds.width / 2, y:bounds.height * 0.25)
        chartView.chartDescription?.enabled = true
        chartView.chartDescription?.text = "Browsers"
        chartView.chartDescription?.position = point
        chartView.chartDescription?.font = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(24.0))!
        
        setData(data : dataWebIE, label: label, colors: colors)
    }
    
    func updateChartData()
    {
    }
    
    func setData(data : [String], label : [String], colors : [NSUIColor])
    {
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: label)
        
        // MARK: BarChartDataEntry
        var entries = [BarChartDataEntry]()
        for i in 0..<data.count
        {
            entries.append(BarChartDataEntry(x: Double(i), y: Double(data[i] )!))
        }
        
        // MARK: BarChartDataSet
        var set = BarChartDataSet()
        if chartView.data != nil
        {
            set = (chartView.data?.dataSets[0] as? BarChartDataSet)!
            set.values = entries
            set.colors = colors
            
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        }
        else
        {
            set = BarChartDataSet(values: entries, label: "Browser market shares")
            set.colors = colors
        }
        
        let customFormatter = NumberFormatter()
        customFormatter.negativePrefix = ""
        customFormatter.positiveSuffix = "%"
        customFormatter.negativeSuffix = "%"
        customFormatter.minimumSignificantDigits = 1
        customFormatter.minimumFractionDigits = 1
        
        set.valueFont = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        set.drawValuesEnabled = true
        set.barBorderWidth = 0.1
        set.valueFormatter = DefaultValueFormatter(formatter : customFormatter)
        
        // MARK: BarChartData
        let data = BarChartData(dataSet: set)
        chartView.data = data
    }
    
    func optionTapped( sender: NSMenuItem)
    {
        switch (sender.title)
        {
        case "Back to Brands":
            mainMenu.item(at: 0)?.isEnabled = false
            chartView.chartDescription?.text = "Browsers"
            setData(data : dataWebIE, label: label, colors: colors)
            
        case "Zoom In":
            chartView.zoom(scaleX: 1.5, scaleY: 1, x: view.frame.width, y: 0)
        case "Zoom out":
            chartView.zoom(scaleX: 2/3, scaleY: 1, x: view.frame.width, y: 0)
        case "Reset Zoom":
            chartView.fitScreen()
            
        default:
            super.toggle(sender.title, chartView: chartView)
        }
    }
    
    // Zoom Buttons
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

extension BarChartViewControllerColumnWithDrilldown: ChartViewDelegate
{
    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight)
    {
        guard chartView.chartDescription?.text == "Browsers" else { return }
        
        let index = Int(highlight.x)
        var label = [String]()
        var dataW = [String]()
        
        for browser in browsers[index].drillDown
        {
            label.append(browser.version )
            dataW.append(browser.pdm )
        }
        
        if dataW.count == 0
        {
            return
        }
        mainMenu.item(at: 0)?.isEnabled = true
        chartView.chartDescription?.text = browsers[index].name
        setData(data : dataW, label : label, colors : [colors[index]])
        
        chartView.animate(xAxisDuration: 1.0, easingOption : .linear)
    }
    
    public func chartValueNothingSelected(_ chartView: ChartViewBase)
    {
        print("chartValueNothingSelected")
    }
    
}

