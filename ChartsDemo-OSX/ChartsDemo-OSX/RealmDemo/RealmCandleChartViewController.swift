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

class RealmCandleChartViewController: RealmDemoBaseViewController {
    
    
    @IBOutlet var chartView: CandleStickChartView!
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Realm.io Candle Chart"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        writeRandomCandleDataToDb(withObjectCount: 50)
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
        let set = RealmCandleDataSet(results: results, xValueField: "xValue", highField: "high", lowField: "low", openField: "open", closeField: "close")
        set.label = "Realm CandleDataSet"
        set.shadowColor = NSUIColor.darkGray
        set.shadowWidth = 0.7
        set.decreasingColor = NSUIColor.red
        set.decreasingFilled = true
        set.increasingColor = NSUIColor(red: CGFloat(122 / 255.0), green: CGFloat(242 / 255.0), blue: CGFloat(84 / 255.0), alpha: CGFloat(1.0))
        set.increasingFilled = false
        set.neutralColor = NSUIColor.blue
        let dataSets: [IChartDataSet] = [set]
        let data = CandleChartData(dataSets: dataSets)
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
extension RealmCandleChartViewController: ChartViewDelegate
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

