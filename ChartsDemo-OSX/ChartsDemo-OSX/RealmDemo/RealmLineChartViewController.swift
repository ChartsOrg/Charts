//
//  RealmBarChartViewController.swift
//  ChartsDemo-OSX
//
//  Created by thierryH24A on 02/04/2017.
//  Copyright © 2017 dcg. All rights reserved.
//

import Cocoa
import Charts
import Realm
import ChartsRealm

class RealmLineChartViewController: RealmDemoBaseViewController {
    
    
    @IBOutlet var chartView: LineChartView!
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Realm.io Line Chart"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
 //       writeRandomDataToDb(withObjectCount: 40)
        title = "Realm.io Line Chart"
        
        _ = [["key": "toggleValues", "label": "Toggle Values"],
             ["key": "toggleHighlight", "label": "Toggle Highlight"],
             ["key": "animateX", "label": "Animate X"],
             ["key": "animateY", "label": "Animate Y"],
             ["key": "animateXY", "label": "Animate XY"],
             ["key": "saveToGallery", "label": "Save to Camera Roll"],
             ["key": "togglePinchZoom", "label": "Toggle PinchZoom"],
             ["key": "toggleAutoScaleMinMax", "label": "Toggle auto scale min/max"]]
        
        
        chartView.delegate = self
        setupBarLineChartView(    chartView)
        
        // enable description text
        chartView.chartDescription?.enabled = true
//        chartView.leftAxis.axisMaximum = 150.0
//        chartView.leftAxis.axisMinimum = 0.0
        chartView.leftAxis.drawGridLinesEnabled = false
        
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelPosition = .bottom
        
        setData()
    }
    
    func setData()
    {
        let realm = RLMRealm.default()
        
        realm.beginWriteTransaction()
        realm.deleteObjects(RealmDemoData.allObjects())
        
        for i in 0..<range1.count {
            let d = RealmDemoData(xValue: Double(i), yValue: range1[i][1])
            realm.add(d)
        }
        _ = try? realm.commitWriteTransaction()
        
        //        for i in 0..<objectCount {
        //            let d = RealmDemoData(xValue: Double(i), yValue: Double(randomFloatBetween(from: 40.0, to: 100.0)))
        //            realm.add(d)
        //        }
        //        _ = try? realm.commitWriteTransaction()
        
        //        let realm = RLMRealm.default()
        let results: RLMResults? = RealmDemoData.allObjects(in: realm)
        let set = RealmLineDataSet(results: results, xValueField: "xValue", yValueField: "yValue")
        set.label = "Realm LineDataSet"
        set.drawCircleHoleEnabled = false
        set.setColor( ChartColorTemplates.colorFromString( "#FF5722"))
        set.setCircleColor( ChartColorTemplates.colorFromString( "#FF5722"))
        set.lineWidth = 1.8
        set.circleRadius = 3.6
        set.drawCirclesEnabled = false
        let dataSets: [IChartDataSet] = [set]
        
        let data = LineChartData(dataSets: dataSets)
        styleData(data)
        chartView.data = data
        chartView.animate(yAxisDuration: 1.4, easingOption: .easeOutQuad)
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


// MARK: - ChartViewDelegate
extension RealmLineChartViewController: ChartViewDelegate
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

