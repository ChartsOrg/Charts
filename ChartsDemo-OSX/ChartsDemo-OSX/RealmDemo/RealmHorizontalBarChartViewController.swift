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

class RealmHorizontalBarChartViewController: RealmDemoBaseViewController {
    
    
    @IBOutlet var chartView: HorizontalBarChartView!
    override open func viewDidAppear()

    {
        super.viewDidAppear()
        view.window!.title = "Realm.io Horizontal Bar Chart"
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        writeRandomStackedDataToDb(withObjectCount: 50)
        
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
        
        chartView.leftAxis.axisMinimum = 0.0
        chartView.drawValueAboveBarEnabled = false
        
        setData()
    }
    
    func setData()
    {
        
        let realm = RLMRealm.default()
        let results = RealmDemoData.allObjects(in: realm)
        // RealmBarDataSet *set = [[RealmBarDataSet alloc] initWithResults:results yValueField:@@"yValue" xValueField:@"xIndex"];
        let set = RealmBarDataSet(results: results, xValueField: "xValue", yValueField: "stackValues", stackValueField: "floatValue")
        // stacked entries
        set.colors = [ChartColorTemplates.colorFromString( "#8BC34A"), ChartColorTemplates.colorFromString( "#FFC107"), ChartColorTemplates.colorFromString( "#9E9E9E")]
        set.label = "Mobile OS Distribution"
        set.stackLabels = ["iOS", "Android", "Other"]
        let dataSets: [IChartDataSet] = [set]
        let data = BarChartData(dataSets: dataSets)
        styleData(data)
        data.setValueTextColor( NSUIColor.white )
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
extension RealmHorizontalBarChartViewController: ChartViewDelegate
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

