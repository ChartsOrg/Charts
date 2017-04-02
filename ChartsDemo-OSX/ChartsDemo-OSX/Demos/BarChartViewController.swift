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

open class BarChartViewController: NSViewController
{
    @IBOutlet var chartView: BarChartView!
    
    var values = [Double]()
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Bar Chart"
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let months = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        values = [28800, 32400, 36000, 34000, 30000, 42000, 45000]
        
        // MARK: General
        chartView.delegate                  = self
        chartView.pinchZoomEnabled          = false
        chartView.drawBarShadowEnabled      = false
        chartView.doubleTapToZoomEnabled    = false
        chartView.drawGridBackgroundEnabled = true
        chartView.fitBars                   = true
        
        // MARK: xAxis
        let xAxis                  = chartView.xAxis
        xAxis.labelPosition        = .bottom
        xAxis.drawGridLinesEnabled = true
        xAxis.valueFormatter       = IndexAxisValueFormatter(values:months)
        xAxis.granularity          = 1
        
        // MARK: leftAxis
        let leftAxis                  = chartView.leftAxis
        leftAxis.drawGridLinesEnabled = true
        leftAxis.drawZeroLineEnabled  = false
        leftAxis.valueFormatter       = HourValueFormatter()
        
        // MARK: rightAxis
        let rightAxis                  = chartView.rightAxis
        rightAxis.drawGridLinesEnabled = true
        rightAxis.valueFormatter       = HourValueFormatter()
        
        // MARK: legend
        chartView.legend.enabled = false
        
        // MARK: description
        chartView.chartDescription?.enabled = false
        
        self.updateChartData()
    }
    
    func updateChartData()
    {
        setDataCount(7, range: 100.0)
    }
    
    func setDataCount(_ count: Int, range: Double)
    {
        // MARK: BarChartDataEntry
        var yVals = [BarChartDataEntry]()
        for i in 0..<count
        {
            yVals.append(BarChartDataEntry(x: Double(i), y: values[i]))
        }
        
        // MARK: BarChartDataSet
        var set1 = BarChartDataSet()
        if chartView.data == nil
        {
            set1 = BarChartDataSet(values: yVals, label: "DataSet")
            set1.colors = ChartColorTemplates.vordiplom()
            set1.drawValuesEnabled = false
            var dataSets = [ChartDataSet]()
            
            dataSets.append(set1)
            
            // MARK: marker
            let  marker = YMarkerView( color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), font: NSUIFont.systemFont(ofSize: 12.0),
                                       textColor: NSUIColor.white,
                                       insets: EdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0),
                                       yAxisValueFormatter: HourValueFormatter())
            
            marker.minimumSize = CGSize(width: 80.0, height: 40.0)
            chartView.marker = marker
            
            // MARK: BarChartData
            let data = BarChartData(dataSets: dataSets)
            chartView.data = data
        }
        else
        {
            set1 = (chartView.data!.dataSets[0] as! BarChartDataSet )
            set1.values = yVals
            
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
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

// MARK: - ChartViewDelegate
extension BarChartViewController: ChartViewDelegate
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



