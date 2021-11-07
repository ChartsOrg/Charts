//
//  VerticalBarChart.swift
//  Hyperloung
//

import UIKit
import Charts

struct ChartVisual {
    var space: Int
    var width: Int
    var bottomTitleSpace: CGFloat = 0

    static var defaultVisual: ChartVisual {
        return ChartVisual(space: 24, width: 32)
    }
}

struct BarChartItemData {
    var title: String
    var valueTitle: String
    var value: Double
    var isHighlight: Bool = false

    var barVisual: BarVisual
}

struct BarVisual {
    var radius: Double
    var normalColor: UIColor
    var highlightColor: UIColor
    var normalTextColor: UIColor
    var highlightTextColor: UIColor
    var isHighlight: Bool = false
    
    static func defaultVisual() -> BarVisual {
        return BarVisual(radius: 4.0, normalColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), highlightColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), normalTextColor: #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1), highlightTextColor: #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1))
    }
}

class VeritalBarChartView: UIView {
    // MARK: Properties
    var chartView: BarChartView!
    var visual: ChartVisual = ChartVisual.defaultVisual
    private var numOfBar: Int = 3
    var chartItems: [BarChartItemData] = []
    var leftAxisUnit: String = ""
    
    // MARK: LifeCycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    private func customInit() {
        let width = CGFloat(visual.width * numOfBar + visual.space * (numOfBar - 1))
        chartView = BarChartView(frame: CGRect(x: 0, y: 0, width: width, height: 200))
        addSubview(chartView)
        
        setup(barLineChartView: chartView)
        
//        setDataCount(numOfBar, range: 50, highlight: 2)
        

    }
    
    func updateChartViewSize() {
        let width = CGFloat(visual.width * numOfBar + visual.space * (numOfBar - 1))
        var frame = chartView.frame
        frame.size.width = width
        chartView.frame = frame
    }
    
    func setChartVisual(_ visual: ChartVisual) {
        self.visual = visual
        chartView.xAxis.yOffset = visual.bottomTitleSpace // spacing bottom  bar title - bar rect
        updateChartViewSize()
    }
    
    func addLimitLine(value: Double, title: String) {
        var limitLine = ChartLimitLine()
        limitLine = ChartLimitLine(limit: value, label: title)
        limitLine.lineColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
        limitLine.valueTextColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
        limitLine.lineWidth = 1
        limitLine.labelPosition = .bottomLeft
//        limitLine.lineDashLengths = [3.0]
        chartView.rightAxis.addLimitLine(limitLine)

    }
    
    func setChartItems(items: [BarChartItemData]) {
        numOfBar = items.count
        updateChartViewSize()
        var yVals: [BarChartDataEntry] = []
        var index:Double = 0
        items.forEach { item in
            let data = BarChartDataEntry(x: index, y: item.value , data: item)
            yVals.append(data)
            index += 1
        }
        
        chartView.xAxis.valueFormatter = VerticalBarValueFormatter(barItems: items)
        chartView.xAxis.setLabelCount(numOfBar, force: false)

        let dataSet: HyperChartBaseDataSet = HyperChartBaseDataSet(entries: yVals, label: "Hi Legend ")
        dataSet.colors = [.black, .green, .gray] // array always have more than 1 item so "color(atIndex index: Int)" to be called
        dataSet.drawValuesEnabled = true
        dataSet.barCornerRadius = 4

        dataSet.valueFormatter = VerticalBarValueFormatter(barItems: items)
        dataSet.stackLabels = ["Births", "Divorces", "Marriages"]

                
        let data = BarChartData(dataSet: dataSet)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
        data.setValueTextColor( .black)
        data.barWidth = calculateBarWidth()
        
        chartView.data = data
    }
    
    func setStackCharItems() {
        
    }
    
    // MARK: Functions
    /*
     Because BarChartView will calculate the with of bar by percentage,
     It will calculate by with and number of item
     But our design persist  with and space so the with of BarChartView will change by number of view and visual
     **/
    
    func setup(barLineChartView chartView: BarChartView) {
        chartView.isUserInteractionEnabled = false
        
        chartView.chartDescription?.enabled = false
        
        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.drawBarShadowEnabled = false
        
        // ChartYAxis *leftAxis = chartView.leftAxis;
        chartView.xAxis.wordWrapEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.axisLineColor = .clear
        chartView.xAxis.granularity = 1
        
        chartView.rightAxis.enabled = true
        chartView.rightAxis.axisLineColor = .clear
        chartView.rightAxis.drawLabelsEnabled = false // Hide label
        chartView.rightAxis.drawGridLinesEnabled = false

        chartView.leftAxis.enabled = true
        chartView.leftAxis.axisLineColor = .clear
        chartView.leftAxis.drawLabelsEnabled = true // Hide label
        chartView.leftAxis.drawGridLinesEnabled = true
        chartView.leftAxis.gridColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        chartView.leftAxis.valueFormatter = VerticalBarLeftAxisValueFormatter(unit: leftAxisUnit)
            
        chartView.legend.enabled = false

        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
        
        // set bottom item titles
        chartView.xAxis.yOffset = visual.bottomTitleSpace // spacing bottom  bar title - bar rect

//        chartView.highlightValues([Highlight(x: 2, dataSetIndex: 1, stackIndex: 0)])
        
    }
        
    func calculateBarWidth() -> Double {
        let width = CGFloat(visual.width * numOfBar + visual.space * (numOfBar - 1))
        return Double(visual.width * numOfBar) / Double(width)
    }
    
}

class HyperChartBaseDataSet: BarChartDataSet {
    override init(entries: [ChartDataEntry]?, label: String?) {
        super.init(entries: entries, label: label)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    // body Bar color
    override func color(atIndex index: Int) -> NSUIColor {
        let entry = entries[index]
        if let data = entry.data as? BarChartItemData {
            return data.isHighlight ? data.barVisual.highlightColor : data.barVisual.normalColor
        }
        return UIColor.red
    }
    
    // value title color on top of each bar
    override func valueTextColorAt(_ index: Int) -> NSUIColor {
        let entry = entries[index]
        if let data = entry.data as? BarChartItemData {
            return data.isHighlight ? data.barVisual.highlightTextColor : data.barVisual.normalTextColor
        }
        
        return UIColor.red
    }
}

public class VerticalBarValueFormatter: NSObject, IValueFormatter, IAxisValueFormatter {
    var barItems: [BarChartItemData] = []
    
    init(barItems: [BarChartItemData]) {
        self.barItems = barItems
    }
    
    fileprivate func format(value: Double) -> String {
        let index = Int(value)
        if index < barItems.count {
            return barItems[index].valueTitle
        }
        return ""
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return format(value: value)
    }
    
    public func stringForValue(
        _ value: Double,
        entry: ChartDataEntry,
        dataSetIndex: Int,
        viewPortHandler: ViewPortHandler?) -> String {
        if let data = entry.data as? BarChartItemData {
            return data.valueTitle
        }
        return ""
    }
    
    public func colorForValue(_ value: Double, axis: AxisBase?) -> UIColor? {
        let index = Int(value)
        if barItems.count > index {
            let item = barItems[index]

            return item.isHighlight ? item.barVisual.highlightTextColor : item.barVisual.normalTextColor
        }
        return nil
    }
}


public class VerticalBarLeftAxisValueFormatter: NSObject, IAxisValueFormatter {
    let unit: String
    init(unit: String) {
        self.unit = unit
    }
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return unit.isEmpty ? String(format: "%g", value) : String(format: "%g %@", value, unit)
    }
    
}
