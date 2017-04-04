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

class RealmScatterChartViewController: RealmDemoBaseViewController {
    
    
    @IBOutlet var chartView: ScatterChartView!
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Realm.io Scatter Chart"
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        writeRandomDataToDb(withObjectCount: 45)
        
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
        
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.pinchZoomEnabled = true
        setData()
    }
    
    func setData()
    {
        let realm = RLMRealm.default()
        let results = RealmDemoData.allObjects(in: realm)
        let set = RealmScatterDataSet(results: results, xValueField: "xValue", yValueField: "yValue")
        set.label = "Realm ScatterDataSet"
        set.scatterShapeSize = 9.0
        set.colors = [ChartColorTemplates.colorFromString( "#CDDC39")]
        set.setScatterShape( .circle )
        let dataSets: [IChartDataSet] = [set]
 
        let data = ScatterChartData(dataSets: dataSets)
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
extension RealmScatterChartViewController: ChartViewDelegate
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

