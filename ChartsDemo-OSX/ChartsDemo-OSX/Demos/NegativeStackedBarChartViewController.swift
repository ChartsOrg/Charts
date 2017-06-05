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



open class NegativeStackedBarChartViewController: DemoBaseViewController
{
    @IBOutlet var chartView: HorizontalBarChartView!
    
    @IBOutlet var mainMenu: NSMenu!
    
    let categories = ["0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69",  "70-74", "75-79", "80-84", "85-89", "90-94", "95-99", "100 +"]
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Negative Stacked Bar Chart"
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
                mainMenu.addItem(withTitle: option["label"]!, action: #selector(NegativeStackedBarChartViewController.optionTapped(sender:)), keyEquivalent: "")
            }
        }
        for item in mainMenu.items
        {
            item.target = self
        }
        
        let customFormatter = NumberFormatter()
        customFormatter.negativePrefix = ""
        customFormatter.positiveSuffix = "%"
        customFormatter.negativeSuffix = "%"
        customFormatter.minimumSignificantDigits = 1
        customFormatter.minimumFractionDigits = 1
        
        chartView.chartDescription?.enabled = true
        chartView.chartDescription?.text = "Population pyramid"
        chartView.chartDescription?.textAlign = .right
        chartView.chartDescription?.textColor = NSUIColor.blue
        
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.highlightFullBarEnabled = false
        
        // scaling can now only be done on x- and y-axis separately
        chartView.pinchZoomEnabled = false
        
        chartView.leftAxis.enabled = false
        
        let rightAxis = chartView.rightAxis
        rightAxis.axisMaximum = 5.0
        rightAxis.axisMinimum = -5.0
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawZeroLineEnabled = true
        rightAxis.labelCount = 7
        rightAxis.valueFormatter = DefaultAxisValueFormatter(formatter : customFormatter)
        rightAxis.labelFont = NSUIFont.systemFont(ofSize: CGFloat(9.0))
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bothSided
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = true
        xAxis.axisMinimum = 0.0
        xAxis.axisMaximum = 22.0
        xAxis.centerAxisLabelsEnabled = true
        xAxis.labelCount = categories.count
        xAxis.granularity = 1
        xAxis.valueFormatter = IndexAxisValueFormatter(values: categories)
        
        chartView.rightAxis.labelFont = NSUIFont.systemFont(ofSize: CGFloat(9.0))
 
        let l = chartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .bottom
        l.orientation = .vertical
        l.drawInside = false
        l.formSize = 8.0
        l.formToTextSpace = 4.0
        l.xEntrySpace = 6.0
        
        updateChartData()
    }
    
    func updateChartData()
    {
        setChartData()
    }
    
    func setChartData()
    {
        let men = [-2.2, -2.2, -2.3, -2.5, -2.7, -3.1, -3.2, -3.0, -3.2, -4.3, -4.4, -3.6, -3.1, -2.4, -2.5, -2.3, -1.2, -0.6, -0.2, -0.0, -0.0]
        let women =  [2.1, 2.0, 2.2, 2.4, 2.6, 3.0, 3.1, 2.9, 3.1, 4.1, 4.3, 3.6, 3.4, 2.6, 2.9, 2.9,  1.8, 1.2, 0.6, 0.1, 0.0]
        
        var yValues = [BarChartDataEntry]()
        for i in 0..<categories.count
        {
            yValues.append(BarChartDataEntry(x: Double(i ) , yValues: [men[i], women[i]]))
        }
        
        var set = BarChartDataSet()
        if chartView.data != nil
        {
            set = (chartView.data?.dataSets[0] as? BarChartDataSet)!
            set.values = yValues
            
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        }
        else
        {
            let customFormatter = NumberFormatter()
            customFormatter.negativePrefix = ""
            customFormatter.positiveSuffix = "%"
            customFormatter.negativeSuffix = "%"
            customFormatter.minimumSignificantDigits = 1
            customFormatter.minimumFractionDigits = 1
            
            set = BarChartDataSet(values: yValues, label: "Age Distribution")
            set.valueFormatter = DefaultValueFormatter(formatter : customFormatter)
            set.valueFont = NSUIFont.systemFont(ofSize: CGFloat(7.0))
            set.axisDependency = .right
            set.colors = [#colorLiteral(red: 0.262745098039216, green: 0.262745098039216, blue: 0.282352941176471, alpha: 1.0), #colorLiteral(red: 0.486274509803922, green: 0.709803921568627, blue: 0.925490196078431, alpha: 1.0)]
            set.stackLabels = ["Men", "Women"]
            set.valueFormatter = DefaultValueFormatter(formatter: customFormatter)
            
            let data = BarChartData(dataSet: set)
            data.barWidth = 1.05
            chartView.data = data
            chartView.needsDisplay =  true
        }
    }

    
    internal func optionTapped( sender: NSMenuItem)
    {
        switch (sender.title)
        {
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

