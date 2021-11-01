//
//  BarChartViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import UIKit
import Charts

// A Subclass for demo purpose with given configuration
// All numbers are used for demo purpose and configuration should be injected while using in app
final class CustomBarChartView: BarChartView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        drawBarShadowEnabled = false
        drawValueAboveBarEnabled = false
        rightAxis.enabled = false
        legend.enabled = false
        xAxis.gridLineDashPhase = 1
        xAxis.gridLineDashLengths = [10]
        
        chartDescription.enabled = false
        dragEnabled = false
        setScaleEnabled(false)
        pinchZoomEnabled = false
        
        rightAxis.enabled = false
        
        xAxisRenderer = XAxisRendererCustomGridLine(viewPortHandler: viewPortHandler,
                                                    axis: xAxis,
                                                    transformer: xAxisRenderer.transformer)
        
        leftYAxisRenderer = YAxisRendererCustomInterval(viewPortHandler: viewPortHandler,
                                                        axis: leftAxis,
                                                        transformer: leftYAxisRenderer.transformer)
        
        rightYAxisRenderer = YAxisRendererCustomInterval(viewPortHandler: viewPortHandler,
                                                         axis: rightAxis,
                                                         transformer: leftYAxisRenderer.transformer)
        
        setupXAxis()
        setupYAxis()
    }
    
    func setupXAxis() {
        xAxis.axisMaximum = 5
        xAxis.axisMinimum = 0
        xAxis.granularity = 8
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.valueFormatter = DayAxisValueFormatter(chart: self)
        xAxis.centerAxisLabelsEnabled = true
    }
    
    func setupYAxis() {
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 4
        
        leftAxis.valueFormatter = DurationFormatter()
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.2
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 33
        leftAxis.drawAxisLineEnabled = false
    }
}

class CustomBarChartViewController: DemoBaseViewController {
    
    @IBOutlet var chartView: CustomBarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Bar Chart"
        
        self.setup(barLineChartView: chartView)
        
        chartView.delegate = self
        updateChartData()
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        self.setDataCount()
    }
    
    func setDataCount() {
        var yVals = [BarChartDataEntry]()
        yVals.append(BarChartDataEntry(x: 1, y: 3))
        yVals.append(BarChartDataEntry(x: 2, y: 8))
        yVals.append(BarChartDataEntry(x: 3, y: 28))
        yVals.append(BarChartDataEntry(x: 4, y: 15))
        yVals.append(BarChartDataEntry(x: 5, y: 5))
        
        let set1: BarChartDataSet = BarChartDataSet(entries: yVals, label: "The year 2017")
        set1.colors = ChartColorTemplates.material()
        set1.drawValuesEnabled = false
        
        let data = BarChartData(dataSet: set1)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
        
        let groupSpace = 0.08;
        let barSpace = 0.59;
        let barWidth = 0.33;
        
        chartView.xAxis.axisMaximum = Double(yVals.count)

        // specify the width each bar should have
        data.barWidth = barWidth;
        data.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
        
        chartView.data = data
        chartView.animate(yAxisDuration: 2.5)
    }
}

// Mock for demo pupose
final class DurationFormatter: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let intValue = Int(value)
        guard intValue > 0 else {
            return "0"
        }
        guard intValue > 10 else {
            return "00:0" + String(intValue)
        }
        return "00:" + String(intValue)
    }
}

// Mock for demo pupose
final class RangeFormatter: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        switch value {
        case 0:
            return "0 - 41"
        case 1:
            return "43 - 62"
        case 2:
            return "64 - 83"
        case 3:
            return "85 - 146"
        case 4:
            return "148 - 209"
        default:
            return ""
        }
    }
}
