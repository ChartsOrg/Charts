//
//  LineDemoViewController.swift
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

open class BarChartViewController: NSViewController
{
    @IBOutlet var barChartView: BarChartView!
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

        barChartView.delegate = self
        barChartView.chartDescription?.text = ""
        
        barChartView.pinchZoomEnabled = false
        barChartView.drawBarShadowEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.drawGridBackgroundEnabled = true
        
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = true
        xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
        xAxis.granularity = 1
        
        barChartView.leftAxis.drawGridLinesEnabled = true
        barChartView.leftAxis.drawZeroLineEnabled = false
        barChartView.leftAxis.valueFormatter = HourValueFormatter()
        
        barChartView.rightAxis.drawGridLinesEnabled = true
        barChartView.rightAxis.valueFormatter = HourValueFormatter()
        
        barChartView.legend.enabled = false

        self.updateChartData()
    }
    
    func updateChartData(){
        
        setDataCount(7, range: 100.0)
    }
    
    func setDataCount(_ count: Int, range: Double)
    {
        var yVals = [BarChartDataEntry]()
        for i in 0..<count
        {
            yVals.append(BarChartDataEntry(x: Double(i), y: values[i]))
        }
        
        var set1 = BarChartDataSet()
        
        if barChartView.data == nil
        {
            set1 = BarChartDataSet(values: yVals, label: "DataSet")
            set1.colors = ChartColorTemplates.vordiplom()
            set1.drawValuesEnabled = false
            var dataSets = [ChartDataSet]()
            
            dataSets.append(set1)
            let data = BarChartData(dataSets: dataSets)
            
            let  marker = YMarkerView( color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), font: NSUIFont.systemFont(ofSize: 12.0),
                                        textColor: NSUIColor.white,
                                        insets: EdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0),
                                        yAxisValueFormatter: HourValueFormatter())

            marker.minimumSize = CGSize(width: 80.0, height: 40.0)
            barChartView.marker = marker
            
            barChartView.data = data
            barChartView.fitBars = true
        }
        else
        {
            set1 = (barChartView.data!.dataSets[0] as! BarChartDataSet )
            set1.values = yVals
            
            barChartView.data?.notifyDataChanged()
            barChartView.notifyDataSetChanged()
            
        }
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



