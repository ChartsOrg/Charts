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

open class StackedBarChartViewController: NSViewController
{
    @IBOutlet var chartView: BarChartView!
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Stacked Bar Chart"
    }

    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        chartView.chartDescription?.enabled = false
        chartView.maxVisibleCount = 40
        chartView.pinchZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.highlightFullBarEnabled = false
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = " $"
        leftAxisFormatter.positiveSuffix = " $"
        
        let leftAxis = chartView.leftAxis
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.axisMinimum = 0.0
        
        // this replaces startAtZero = YES
        chartView.rightAxis.enabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .top
        
        let legend = chartView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.drawInside = false
        legend.form = .square
        legend.formSize = 8.0
        legend.formToTextSpace = 4.0
        legend.xEntrySpace = 6.0
        
        setDataCount(12, range: 100.0)
    }
    
    func setDataCount(_ count: Int, range: Double)
    {
        var yVals = [ChartDataEntry]()
        for i in 0..<count
        {
            let mult = range + 1
            let val1 = Double(arc4random_uniform(UInt32(mult))) + mult / 3
            let val2 = Double(arc4random_uniform(UInt32(mult))) + mult / 3
            let val3 = Double(arc4random_uniform(UInt32(mult))) + mult / 3
            yVals.append(BarChartDataEntry(x: Double(i), yValues: [(val1), (val2), (val3)]))
        }
        
        var set1 =  BarChartDataSet()
        if chartView.data != nil
        {
            set1 = chartView.data!.dataSets[0] as! BarChartDataSet
            set1.values = yVals
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        }
        else
        {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 1
            formatter.negativeSuffix = " $"
            formatter.positiveSuffix = " $"
            
            set1 = BarChartDataSet(values: yVals, label: "Statistics Vienna 2014")
            set1.colors = [ChartColorTemplates.material()[0], ChartColorTemplates.material()[1], ChartColorTemplates.material()[2]]
            set1.stackLabels = ["Births", "Divorces", "Marriages"]
            set1.valueFont = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
            set1.valueFormatter = DefaultValueFormatter(formatter: formatter )
            set1.valueTextColor = NSUIColor.white
            
            var dataSets = [BarChartDataSet]()
            dataSets.append(set1)
            
            let data = BarChartData()
            data.addDataSet(dataSets[0] )
            chartView.fitBars = true
            chartView.data = data
        }
    }
}


