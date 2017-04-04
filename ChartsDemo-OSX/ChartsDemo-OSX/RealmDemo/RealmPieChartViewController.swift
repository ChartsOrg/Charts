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

class RealmPieChartViewController: RealmDemoBaseViewController {
    
    
    @IBOutlet var chartView: PieChartView!
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Realm.io Pie Chart"
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        writeRandomPieDataToDb()
        
        
        title = "Realm.io Pie Chart"
        
        _ = [["key": "toggleValues", "label": "Toggle Values"],
             ["key": "toggleHighlight", "label": "Toggle Highlight"],
             ["key": "animateX", "label": "Animate X"],
             ["key": "animateY", "label": "Animate Y"],
             ["key": "animateXY", "label": "Animate XY"],
             ["key": "saveToGallery", "label": "Save to Camera Roll"],
             ["key": "togglePinchZoom", "label": "Toggle PinchZoom"],
             ["key": "toggleAutoScaleMinMax", "label": "Toggle auto scale min/max"]]
        
        
        chartView.delegate = self
        setupPieChartView(    chartView)
        setData()
    }
    
    func setData()
    {
        let realm = RLMRealm.default()
        let results: RLMResults? = RealmDemoData.allObjects(in: realm)
        
        let set = RealmPieDataSet(results: results, yValueField: "yValue", labelField: "label")
        set.valueFont = NSUIFont.systemFont(ofSize: CGFloat(9.0))
        set.colors = ChartColorTemplates.vordiplom()
        set.label = "Example market share"
        set.sliceSpace = 2.0
        let dataSets: [IChartDataSet] = [set]
        
        let data = PieChartData(dataSets: dataSets)
        styleData(data)
        data.setValueTextColor ( NSUIColor.white)
        data.setValueFont (NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(12.0)))
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
extension RealmPieChartViewController: ChartViewDelegate
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

