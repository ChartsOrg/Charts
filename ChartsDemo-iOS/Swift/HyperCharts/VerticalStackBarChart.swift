//
//  VerticalStackBarChart.swift
//  Hyperloung
//

import UIKit
import Charts

struct StackBarChartVisual {
    var space: Int
    var width: Int
    var bottomTitleSpace: CGFloat = 1

    static var defaultVisual: StackBarChartVisual {
        return StackBarChartVisual(space: 24, width: 32)
    }
}

struct StactBarItem {
    var color: UIColor
    var value: Double
    var title: String = ""
    var valueText: String = ""
}

struct StackBarChartItemData {
    var stackItems: [StactBarItem] = []
    var title: String
    var valueTitle: String
    var value: Double
    var isHighlight: Bool = false

    var barVisual: StackBarVisual
    
    var isSetTitle: Bool = false
    mutating func setTitle() {
        isSetTitle = true
    }
}

struct StackBarVisual {
    var radius: Double
    var normalColor: UIColor
    var highlightColor: UIColor
    var normalTextColor: UIColor
    var highlightTextColor: UIColor
    var isHighlight: Bool = false
    
    static func defaultVisual() -> StackBarVisual {
        return StackBarVisual(radius: 4.0, normalColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), highlightColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), normalTextColor: #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1), highlightTextColor: #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1))
    }
}

class VerticalStackBarChart: UIView {
    // MARK: Properties
    var chartView: BarChartView!
    var visual: StackBarChartVisual = StackBarChartVisual.defaultVisual
    private var numOfBar: Int = 3
    var chartItems: [StackBarChartItemData] = []
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
        chartView = BarChartView(frame: CGRect(x: 0, y: 0, width: width, height: 250))
        addSubview(chartView)
        
        setup(barLineChartView: chartView)
    }
    
    func updateChartViewSize() {
        let width = CGFloat(visual.width * numOfBar + visual.space * (numOfBar - 1))
        var frame = chartView.frame
        frame.size.width = width
        chartView.frame = frame
    }
    
    func setStackBarChartVisual(_ visual: StackBarChartVisual) {
        self.visual = visual
//        chartView.xAxis.yOffset = visual.bottomTitleSpace // spacing bottom  bar title - bar rect
        updateChartViewSize()
    }
    
    func setLimits(limitLines: [ChartLimitLine]) {
        var limitLine = ChartLimitLine()
        limitLine = ChartLimitLine(limit: 40.5, label: "Hello")
        limitLine.lineColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
        limitLine.valueTextColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
        limitLine.lineWidth = 0.5
        limitLine.labelPosition = .bottomLeft
        chartView.rightAxis.addLimitLine(limitLine)
    }
    
    lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.negativeSuffix = " $"
        formatter.positiveSuffix = " $"
        
        return formatter
    }()

    
    func setChartItems(items: [StackBarChartItemData]) {
//        let count = 4
//        let range: UInt32 = 60
//        let yVals = (0..<count).map { (i) -> BarChartDataEntry in
//            let mult = range + 1
//            let val1 = Double(arc4random_uniform(mult) + mult / 3)
//            let val2 = Double(arc4random_uniform(mult) + mult / 3)
//            let val3 = Double(arc4random_uniform(mult) + mult / 3)
//
//            return BarChartDataEntry(x: Double(i), yValues: [val1, val2, val3], icon: #imageLiteral(resourceName: "icon"))
//        }
//
//        let set = BarChartDataSet(entries: yVals, label: "Statistics Vienna 2014")
//        set.drawIconsEnabled = false
//        set.drawValuesEnabled = false
//        set.isDrawTopBarValue = true
//        set.barCornerRadius = 4
//        set.colors = [ChartColorTemplates.material()[0], ChartColorTemplates.material()[1], ChartColorTemplates.material()[2]]
//        set.stackLabels = ["Births", "Divorces", "Marriages"]
//
//        let data = BarChartData(dataSet: set)
//        data.setValueFont(.systemFont(ofSize: 7, weight: .light))
//        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
//        data.setValueTextColor(.white)
//
//        chartView.fitBars = true
//        chartView.data = data
        
        
        numOfBar = items.count
        updateChartViewSize()
        var yVals: [BarChartDataEntry] = []
        var index:Double = 0
        items.forEach { item in
            let data = BarChartDataEntry(x: index, yValues: item.stackItems.map({ $0.value }), data: item)
            yVals.append(data)
            index += 1
        }

        chartView.xAxis.valueFormatter = VerticalStackBarValueFormatter(barItems: items) as! IAxisValueFormatter
        chartView.xAxis.setLabelCount(numOfBar, force: false)

        let set: HyperStackChartBaseDataSet = HyperStackChartBaseDataSet(entries: yVals, label: "Hi Legend ")
        set.colors = [#colorLiteral(red: 0.3803921569, green: 0.8156862745, blue: 0.9411764706, alpha: 1),  #colorLiteral(red: 0.1215686275, green: 0.5725490196, blue: 0.8941176471, alpha: 1), #colorLiteral(red: 0.2078431373, green: 0.3411764706, blue: 0.7882352941, alpha: 1)] // array always have more than 1 item so "color(atIndex index: Int)" to be called
        set.drawValuesEnabled = false
        set.isDrawTopBarValue = true
        set.barCornerRadius = 4

        set.valueFormatter = VerticalStackBarValueFormatter(barItems: items)
        set.stackLabels = ["Births", "Divorces", "Marriages"]


        let data = BarChartData(dataSet: set)
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
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.highlightFullBarEnabled = false
        chartView.leftAxis.enabled = false
        chartView.leftAxis.axisMinimum = 0
        chartView.rightAxis.enabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.axisLineColor = .clear
        
        let l = chartView.legend
        l.enabled = true
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .circle
        l.formToTextSpace = 4
        l.xEntrySpace = 6
    }
        
    func calculateBarWidth() -> Double {
        let width = CGFloat(visual.width * numOfBar + visual.space * (numOfBar - 1))
        return Double(visual.width * numOfBar) / Double(width)
    }
    
}

class HyperStackChartBaseDataSet: BarChartDataSet {
    override init(entries: [ChartDataEntry]?, label: String?) {
        super.init(entries: entries, label: label)
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    // body Bar color
//    override func color(atIndex index: Int) -> NSUIColor {
//        let entry = entries[index / 3 ]
//        if let data = entry.data as? StackBarChartItemData {
//            return data.isHighlight ? data.barVisual.highlightColor : data.barVisual.normalColor
//        }
//        return UIColor.red
//    }

//    // value title color on top of each bar
//    override func valueTextColorAt(_ index: Int) -> NSUIColor {
//        let entry = entries[index]
//        if let data = entry.data as? StackBarChartItemData {
//            return data.isHighlight ? data.barVisual.highlightTextColor : data.barVisual.normalTextColor
//        }
//
//        return UIColor.red
//    }
}

public class VerticalStackBarValueFormatter: NSObject, IValueFormatter, IAxisValueFormatter {
    var barItems: [StackBarChartItemData] = []

    init(barItems: [StackBarChartItemData]) {
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
        if var data = entry.data as? StackBarChartItemData {
            if !data.isSetTitle {
                data.setTitle()
                return data.title
            }
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


public class VerticalStackBarLeftAxisValueFormatter: NSObject, IAxisValueFormatter {
    let unit: String
    init(unit: String) {
        self.unit = unit
    }
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return unit.isEmpty ? String(format: "%g", value) : String(format: "%g %@", value, unit)
    }

}
