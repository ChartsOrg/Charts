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

open class MultipleBarChartViewController: DemoBaseViewController
{
    @IBOutlet var chartView: BarChartView!
    
    @IBOutlet weak var sliderX: NSSlider!
    @IBOutlet weak var sliderY: NSSlider!
    
    @IBOutlet weak var sliderTextX: NSTextField!
    @IBOutlet weak var sliderTextY: NSTextField!
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Multiple Bar Chart"
    }
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()

        chartView.chartDescription?.enabled = false
        chartView.delegate = self
        chartView.pinchZoomEnabled = false
        chartView.drawBarShadowEnabled = false
        chartView.drawGridBackgroundEnabled = true
        
        let marker = BalloonMarker(color: NSUIColor(white: CGFloat(180 / 255.0), alpha: 1.0), font: NSUIFont.systemFont(ofSize: CGFloat(12.0)), textColor: NSUIColor.white, insets: NSEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: CGFloat(80.0), height: CGFloat(40.0))
        chartView.marker = marker

        let legend = chartView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.drawInside = true
        legend.font = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(8.0))!
        legend.yOffset = 10.0
        legend.xOffset = 10.0
        legend.yEntrySpace = 0.0
        
        let xAxis = chartView.xAxis
        xAxis.labelFont = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        xAxis.granularity = 1.0
        xAxis.centerAxisLabelsEnabled = true
        xAxis.labelCount = 20
        xAxis.gridLineWidth = 2.0
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.maximumFractionDigits = 1
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        leftAxis.valueFormatter = LargeValueFormatter()
        leftAxis.drawGridLinesEnabled = false
        leftAxis.spaceTop = 0.35
        leftAxis.axisMinimum = 0
    
        chartView.rightAxis.enabled = false
        sliderX.doubleValue = 10.0
        sliderY.doubleValue = 100.0
        self.slidersValueChanged(sliderX)
    }
    
    func updateChartData()
    {
        self.setDataCount(Int(sliderX.intValue), range: sliderY.doubleValue)
    }
    
    func setDataCount(_ count: Int, range: Double)
    {
        let groupSpace = 0.2
        let barSpace = 0.00
        let barWidth = 0.2
        // (0.2 + 0.00) * 4 + 0.2 = 1.00 -> interval per "group"
        
        var yVals1 = [ChartDataEntry]()
        var yVals2 = [ChartDataEntry]()
        var yVals3 = [ChartDataEntry]()
        var yVals4 = [ChartDataEntry]()
        
        let randomMultiplier = range * 100000.0
        let groupCount = count + 1
        let startYear = 1980
        let endYear = startYear + groupCount

        for i in startYear..<endYear
        {
            yVals1.append(BarChartDataEntry(x: Double(i), y: Double(arc4random_uniform(UInt32(randomMultiplier)))))
            yVals2.append(BarChartDataEntry(x: Double(i), y: Double(arc4random_uniform(UInt32(randomMultiplier)))))
            yVals3.append(BarChartDataEntry(x: Double(i), y: Double(arc4random_uniform(UInt32(randomMultiplier)))))
            yVals4.append(BarChartDataEntry(x: Double(i), y: Double(arc4random_uniform(UInt32(randomMultiplier)))))
        }

        var set1 = BarChartDataSet()
        var set2 = BarChartDataSet()
        var set3 = BarChartDataSet()
        var set4 = BarChartDataSet()
        
        if chartView.data != nil
        {
            set1 = chartView.data?.dataSets[0] as! BarChartDataSet
            set2 = chartView.data?.dataSets[1] as! BarChartDataSet
            set3 = chartView.data?.dataSets[2] as! BarChartDataSet
            set4 = chartView.data?.dataSets[3] as! BarChartDataSet
                
            set1.values = yVals1
            set2.values = yVals2
            set3.values = yVals3
            set4.values = yVals4
            let data = BarChartData(dataSets: [set1, set2, set3, set4])

            chartView.xAxis.axisMinimum = Double(startYear)
            chartView.xAxis.axisMaximum = (data.groupWidth(groupSpace: groupSpace, barSpace: barSpace)) * sliderX.doubleValue + Double(startYear)

            data.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
            chartView.data = data
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        }
        else
        {
            set1 = BarChartDataSet(values: yVals1, label: "Company A")
            set1.colors = [NSUIColor(red: CGFloat(104 / 255.0), green: CGFloat(241 / 255.0), blue: CGFloat(175 / 255.0), alpha: 1.0)]

            
            set2 = BarChartDataSet(values: yVals2, label: "Company B")
            set2.colors = [NSUIColor(red: CGFloat(164 / 255.0), green: CGFloat(228 / 255.0), blue: CGFloat(251 / 255.0), alpha: 1.0)]
            
            set3 = BarChartDataSet(values: yVals3, label: "Company C")
            set3.colors = [NSUIColor(red: CGFloat(242 / 255.0), green: CGFloat(247 / 255.0), blue: CGFloat(158 / 255.0), alpha: 1.0)]
            
            set4 = BarChartDataSet(values: yVals4, label: "Company D")
            set4.colors = [NSUIColor(red: 1.0, green: CGFloat(102 / 255.0), blue: CGFloat(0 / 255.0), alpha: 1.0)]
            
            var dataSets = [BarChartDataSet]()
            dataSets.append(set1)
            dataSets.append(set2)
            dataSets.append(set3)
            dataSets.append(set4)
            
            let data = BarChartData(dataSets: dataSets)
            
            data.setValueFont( NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(10.0)))
            data.setValueFormatter(LargeValueFormatter())
            
            // specify the width each bar should have
            data.barWidth = barWidth
            
            // restrict the x-axis range
            chartView.xAxis.axisMinimum = Double(startYear)
            // groupWidthWithGroupSpace(...) is a helper that calculates the width each group needs based on the provided parameters
            chartView.xAxis.axisMaximum = Double(startYear) + data.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(groupCount)
            data.groupBars( fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
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
    
    // MARK: - Actions
    @IBAction func slidersValueChanged(_ sender: Any)
    {
        let startYear: Int = 1980
        let endYear: Int = startYear + Int(sliderX.intValue)
        sliderTextX.stringValue = "\(startYear)-\(endYear)"
        sliderTextY.stringValue = sliderY.stringValue
        self.updateChartData()
    }
}
    
    
// MARK: - ChartViewDelegate
extension MultipleBarChartViewController: ChartViewDelegate
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

