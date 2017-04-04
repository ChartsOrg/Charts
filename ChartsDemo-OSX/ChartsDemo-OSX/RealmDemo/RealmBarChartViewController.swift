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

class RealmBarChartViewController: RealmDemoBaseViewController {
    
    
    @IBOutlet var chartView: BarChartView!
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Realm.io Bar Chart"
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        writeRandomDataToDb(withObjectCount: 20)
        title = "Realm.io Bar Chart"
        
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
        setData()
    }

    func setData()
    {
        let realm = RLMRealm.default()
        let results = RealmDemoData.allObjects(in: realm)
        let set = RealmBarDataSet(results: results, xValueField: "xValue", yValueField: "yValue", label: "")
        
        set.colors = [ChartColorTemplates.colorFromString("#FF5722"), ChartColorTemplates.colorFromString("#03A9F4")]
        
        set.label = "Realm BarDataSet"
        let dataSets: [IChartDataSet] = [set]
        let data = BarChartData(dataSets: dataSets)
        styleData(data)
        
        chartView.fitBars = true
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
extension RealmBarChartViewController: ChartViewDelegate
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

