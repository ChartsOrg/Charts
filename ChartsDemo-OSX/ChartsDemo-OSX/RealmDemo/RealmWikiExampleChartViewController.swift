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
import RealmSwift

class RealmWikiExampleChartViewController: RealmDemoBaseViewController {
    
    @IBOutlet var lineChartView: LineChartView!
    @IBOutlet var barChartView: BarChartView!
    
    var results: RLMResults<Score>!
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Realm.io Wiki Example"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        writeRandomDataToDb(withObjectCount: 40)
        title = "Realm.io Wiki Example"
        
        _ = [["key": "toggleValues", "label": "Toggle Values"],
             ["key": "toggleHighlight", "label": "Toggle Highlight"],
             ["key": "animateX", "label": "Animate X"],
             ["key": "animateY", "label": "Animate Y"],
             ["key": "animateXY", "label": "Animate XY"],
             ["key": "saveToGallery", "label": "Save to Camera Roll"],
             ["key": "togglePinchZoom", "label": "Toggle PinchZoom"],
             ["key": "toggleAutoScaleMinMax", "label": "Toggle auto scale min/max"]]
        
        axisFormatDelegate = self
        
        setupBarLineChartView(lineChartView)
        lineChartView.delegate = self
        lineChartView.extraBottomOffset = 5.0
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.labelCount = 5
        lineChartView.xAxis.granularity = 1.0
        lineChartView.xAxis.labelPosition = .bottom
        
        setupBarLineChartView(barChartView)
        barChartView.delegate = self
        barChartView.extraBottomOffset = 5.0
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.labelCount = 5
        barChartView.xAxis.granularity = 1.0
        barChartView.xAxis.labelPosition = .bottom
        
        
        
        // setup realm
        let realm = RLMRealm.default()
        
        realm.beginWriteTransaction()
        
        // clear previous scores that might exist from previous viewing of this VC
        realm.deleteObjects(RealmDemoData.allObjects())
        
        // write some demo-data into the realm.io database
        let score1 = Score(totalScore: 100.0, scoreNr: 0.0, playerName: "Peter")
        realm.add(score1)
        
        let score2 = Score(totalScore: 110.0, scoreNr: 1.0, playerName: "Lisa")
        realm.add(score2)
        
        let score3 = Score(totalScore: 130.0, scoreNr: 2.0, playerName: "Dennis")
        realm.add(score3)
        
        let score4 = Score(totalScore: 70.0, scoreNr: 3.0, playerName: "Luke")
        realm.add(score4)
        
        let score5 = Score(totalScore: 80.0, scoreNr: 4.0, playerName: "Sarah")
        realm.add(score5)
        
        // commit changes to realm db
        _ = try? realm.commitWriteTransaction()
        
        // add data to the chart
        setData()
        
    }
    
    func setData()
    {
        let realm = RLMRealm.default()
        
        results = Score.allObjects(in: realm) as? RLMResults<Score>
        lineChartView.xAxis.valueFormatter = self
        barChartView.xAxis.valueFormatter = self
        
        // Line chart
        let lineDataSet = RealmLineDataSet(results: (results as? RLMResults<RLMObject>), xValueField: "scoreNr", yValueField: "totalScore")
        
        lineDataSet.mode = .linear
        lineDataSet.label = "Result Scores"
        lineDataSet.drawCircleHoleEnabled = false
        lineDataSet.setColor (ChartColorTemplates.colorFromString( "#FF5722"))
        lineDataSet.setCircleColor  ( ChartColorTemplates.colorFromString( "#FF5722"))
        lineDataSet.lineWidth = 1.8
        lineDataSet.circleRadius = 3.6
        
        let lineDataSets: [IChartDataSet] = [lineDataSet]
        let lineData = LineChartData(dataSets: lineDataSets)
        styleData(lineData)
        
        // set data
        lineChartView.data = lineData
        lineChartView.animate(yAxisDuration: 1.4, easingOption: .easeOutQuad)
        
        // Bar chart
        let barDataSet = RealmBarDataSet(results: (results as? RLMResults<RLMObject>), xValueField: "scoreNr", yValueField: "totalScore", label: "")
        barDataSet.colors = [ChartColorTemplates.colorFromString( "#FF5722"), ChartColorTemplates.colorFromString("#03A9F4")]
        barDataSet.label = "Realm BarDataSet"
        let barDataSets: [IChartDataSet] = [barDataSet]
        
        let barData = BarChartData(dataSets: barDataSets)
        styleData(barData)
        barChartView.data = barData
        
        barChartView.fitBars = true
        barChartView.notifyDataSetChanged()
        barChartView.animate(yAxisDuration: 1.4, easingOption: .easeOutQuad)
    }
    
    func optionTapped( sender: NSMenuItem)
    {
        switch (sender.title)
        {
        default:
            super.toggle(sender.title, chartView: lineChartView)
        }
    }
}

// MARK: - ChartViewDelegate
extension RealmWikiExampleChartViewController: ChartViewDelegate
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

extension RealmWikiExampleChartViewController: IAxisValueFormatter
{
    func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        return results!.object(at: UInt(value)).playerName
    }
}

