//
//  BlockChartViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import UIKit
import Charts

class BlockChartViewController: DemoBaseViewController {

    @IBOutlet var chartView: BlockChartView!
    @IBOutlet var sliderX: UISlider!
    @IBOutlet var sliderY: UISlider!
    @IBOutlet var sliderTextX: UITextField!
    @IBOutlet var sliderTextY: UITextField!

    lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.negativeSuffix = " $"
        formatter.positiveSuffix = " $"
        
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Block Chart"
        self.options = [.toggleValues,
                        .toggleIcons,
                        .toggleHighlight,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .saveToGallery,
                        .togglePinchZoom,
                        .toggleAutoScaleMinMax,
                        .toggleData,
                        .toggleBarBorders]
        
        
        chartView.delegate = self
        
        chartView.chartDescription?.enabled = false
        
        chartView.maxVisibleCount = 40
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.highlightFullBarEnabled = false
        
        let leftAxis = chartView.leftAxis
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
        leftAxis.axisMinimum = 0
        
        chartView.rightAxis.enabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .top
        
        let l = chartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formToTextSpace = 4
        l.xEntrySpace = 6
//        chartView.legend = l

        sliderX.value = 12
        sliderY.value = 100
        slidersValueChanged(nil)
        
        self.updateChartData()
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        self.setChartData(count: Int(sliderX.value + 1), range: UInt32(sliderY.value))
    }
    
    func setChartData(count: Int, range: UInt32) {
        let yVals1 = (0..<count).map { (i) -> BlockChartDataEntry in
            let mult = range + 1
            let val1 = Double(arc4random_uniform(mult) + mult / 3)
            let val2 = Double(arc4random_uniform(mult) + mult / 3)
            let val3 = Double(arc4random_uniform(mult) + mult / 3)
            
            return BlockChartDataEntry(x: Double(i), yValues: [val1, val2, val3], icon: #imageLiteral(resourceName: "icon"))
        }
        
        let yVals2 = (0..<count).map { (i) -> BlockChartDataEntry in
            let mult = range + 1
            let val1 = Double(arc4random_uniform(mult) + mult / 3)
            let val2 = Double(arc4random_uniform(mult) + mult / 3)
            let val3 = Double(arc4random_uniform(mult) + mult / 3)
            
            return BlockChartDataEntry(x: Double(i), yValues: [val1, val2, val3], icon: #imageLiteral(resourceName: "icon"))
        }
        
        let set1 = BlockChartDataSet(entries: yVals1, label: "Statistics Vienna 2014")
        set1.drawIconsEnabled = false
        set1.colors = [NSUIColor.orange, ChartColorTemplates.material()[0], ChartColorTemplates.material()[1]]
        set1.stackLabels = ["Births1", "Divorces1", "Marriages1"]
        
        let set2 = BlockChartDataSet(entries: yVals2, label: "Statistics Vienna 2014")
        set2.drawIconsEnabled = false
        set2.colors = [NSUIColor.orange, ChartColorTemplates.material()[2], ChartColorTemplates.material()[3]]
        set2.stackLabels = ["Births2", "Divorces2", "Marriages2"]
        
        let data = BlockChartData(dataSets: [set1, set2])
//        let data = BlockChartData(dataSet: set1)
        data.setValueFont(.systemFont(ofSize: 7, weight: .light))
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        data.setValueTextColor(.white)
        
        chartView.fitBars = true
        chartView.data = data
        chartView.groupBars(fromX: 0, groupSpace: 0.3, barSpace: 0)
    }
    
    override func optionTapped(_ option: Option) {
        super.handleOption(option, forChartView: chartView)
    }
    
    @IBAction func slidersValueChanged(_ sender: Any?) {
        sliderTextX.text = "\(Int(sliderX.value))"
        sliderTextY.text = "\(Int(sliderY.value))"
        
        updateChartData()
    }
}
