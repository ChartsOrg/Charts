//
//  RealmDemoBaseViewController.swift
//  ChartsDemo-OSX
//
//  Created by thierryH24A on 02/04/2017.
//  Copyright © 2017 dcg. All rights reserved.
//

import Cocoa
import Realm
import Charts


class RealmDemoBaseViewController: DemoBaseViewController
{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)!
        initialize()
    }
    
    func initialize()
    {
        //edgesForExtendedLayout = []
        let defaultRealmPath: URL? = RLMRealmConfiguration.default().fileURL
        try? FileManager.default.removeItem(at: defaultRealmPath!)
    }
    
    func randomFloatBetween(from: Float, to: Float)->Float
    {
        return Float(arc4random_uniform( UInt32(to - from ))) + Float(from)
    }
    
    func writeRandomDataToDb(withObjectCount objectCount: Int)
    {
        let realm = RLMRealm.default()
        
        realm.beginWriteTransaction()
        realm.deleteObjects(RealmDemoData.allObjects())
        
        for i in 0..<objectCount {
            let d = RealmDemoData(xValue: Double(i), yValue: Double(randomFloatBetween(from: 40.0, to: 100.0)))
            realm.add(d)
        }
        _ = try? realm.commitWriteTransaction()
    }
    
    func writeRandomStackedDataToDb(withObjectCount objectCount: Int)
    {
        let realm = RLMRealm.default()
        
        realm.beginWriteTransaction()
        realm.deleteObjects(RealmDemoData.allObjects())
        
        for i in 0..<objectCount
        {
            let val1: Float = randomFloatBetween(from: 34.0, to: 46.0)
            let val2: Float = randomFloatBetween(from: 34.0, to: 46.0)
            let stack: [NSNumber] = [NSNumber(value: val1), NSNumber(value: val2), NSNumber(value: 100.0 - val1 - val2)]
            let d = RealmDemoData(xValue: Double(i), stackValues: stack)
            realm.add(d)
        }
        
        _ = try? realm.commitWriteTransaction()
    }
    
    func writeRandomCandleDataToDb(withObjectCount objectCount: Int)
    {
        let realm = RLMRealm.default()
        realm.beginWriteTransaction()
        realm.deleteObjects(RealmDemoData.allObjects())
        
        for i in 0..<objectCount {
            let mult: Float = 50
            let val = randomFloatBetween(from: mult, to: mult + 40)
            let high = randomFloatBetween(from: 8, to: 17)
            let low: Float = randomFloatBetween(from: 8, to: 17)
            let open: Float = randomFloatBetween(from: 1, to: 7)
            let close: Float = randomFloatBetween(from: 1, to: 7)
            let even: Bool = i % 2 == 0
            let d = RealmDemoData(xValue: Double(i), high: Double(val + high), low: Double(val - low), open: Double(even ? val + open : val - open), close: Double(even ? val - close : val + close))
            realm.add(d)
        }
        _ = try? realm.commitWriteTransaction()
    }
    
    func writeRandomBubbleDataToDb(withObjectCount objectCount: Int)
    {
        let realm = RLMRealm.default()
        
        realm.beginWriteTransaction()
        realm.deleteObjects(RealmDemoData.allObjects())
        
        for i in 0..<objectCount {
            let d = RealmDemoData(xValue: Double(i), yValue: Double(randomFloatBetween(from: 30.0, to: 130.0)), bubbleSize: Double(randomFloatBetween(from: 15.0, to: 35.0)))
            realm.add(d)
        }
        _ = try? realm.commitWriteTransaction()
    }
    
    func writeRandomPieDataToDb() {
        let realm = RLMRealm.default()
        
        realm.beginWriteTransaction()
        realm.deleteObjects(RealmDemoData.allObjects())
        
        let value1: Float = randomFloatBetween(from: 15.0, to: 23.0)
        let value2: Float = randomFloatBetween(from: 15.0, to: 23.0)
        let value3: Float = randomFloatBetween(from: 15.0, to: 23.0)
        let value4: Float = randomFloatBetween(from: 15.0, to: 23.0)
        let value5: Float = 100.0 - value1 - value2 - value3 - value4
        var values: [NSNumber] = [NSNumber(value: value1), NSNumber(value:value2), NSNumber(value:value3), NSNumber(value:value4), NSNumber(value:value5)]
        var xValues: [String] = ["iOS", "Android", "WP 10", "BlackBerry", "Other"]
        for i in 0..<values.count
        {
            let y = Double(values[i])
            let d = RealmDemoData(yValue: y , label: xValues[i])
            realm.add(d)
        }
        _ = try? realm.commitWriteTransaction()
    }
    
    override func setupBarLineChartView(_ chartView: BarLineChartViewBase)
    {
        super.setupBarLineChartView(chartView)
        let percentFormatter = NumberFormatter()
        percentFormatter.positiveSuffix = "%"
        percentFormatter.negativeSuffix = "%"
        
        let leftAxis: YAxis = chartView.leftAxis
        leftAxis.labelFont = NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(8.0))!
        leftAxis.labelTextColor = NSUIColor.darkGray
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: percentFormatter)
    }
    
    func styleData(_ data: ChartData)
    {
        let percentFormatter = NumberFormatter()
        percentFormatter.positiveSuffix = "%"
        percentFormatter.negativeSuffix = "%"
        
        data.setValueFont ( NSUIFont(name: "HelveticaNeue-Light", size: CGFloat(8.0)))
        data.setValueTextColor( NSUIColor.darkGray)
        data.setValueFormatter( DefaultValueFormatter(formatter: percentFormatter))
    }
}
