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

class RealmRadarChartViewController: RealmDemoBaseViewController {
    
    
    @IBOutlet var chartView: RadarChartView!
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Realm.io Radar Chart"
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        writeRandomDataToDb(withObjectCount: 7)
        
        _ = [["key": "toggleValues", "label": "Toggle Values"],
             ["key": "toggleHighlight", "label": "Toggle Highlight"],
             ["key": "animateX", "label": "Animate X"],
             ["key": "animateY", "label": "Animate Y"],
             ["key": "animateXY", "label": "Animate XY"],
             ["key": "saveToGallery", "label": "Save to Camera Roll"],
             ["key": "togglePinchZoom", "label": "Toggle PinchZoom"],
             ["key": "toggleAutoScaleMinMax", "label": "Toggle auto scale min/max"]]
        
        
        chartView.delegate = self
        
        
        setupRadarChartView( chartView)
        chartView.yAxis.enabled = false
        chartView.xAxis.enabled = false
        chartView.webAlpha = 0.7
        chartView.innerWebColor = NSUIColor.darkGray
        chartView.webColor = NSUIColor.gray
        setData()
    }
    
    func setData()
    {
        let realm = RLMRealm.default()
        let results: RLMResults? = RealmDemoData.allObjects(in: realm)
        let set = RealmRadarDataSet(results: results, yValueField: "yValue")
        // stacked entries
        set.label = "Realm RadarDataSet"
        set.drawFilledEnabled = true
        set.colors = [ChartColorTemplates.colorFromString( "#009688")]
        set.fillColor = ChartColorTemplates.colorFromString( "#009688")
        set.fillAlpha = 0.5
        set.lineWidth = 2.0
        let dataSets: [IChartDataSet] = [set]

        let data = RadarChartData(dataSets: dataSets)
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
extension RealmRadarChartViewController: ChartViewDelegate
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

