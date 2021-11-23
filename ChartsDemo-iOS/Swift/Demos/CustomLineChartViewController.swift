//
//  LineChart1ViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import UIKit
import Charts

// A Subclass for demo purpose with given configuration
// All numbers are used for demo purpose and configuration should be injected while using in app
final class CustomLineChartView: LineChartView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        extraBottomOffset = 40
        extraLeftOffset = 30
        backgroundColor = .gray
        chartDescription.enabled = false
        dragEnabled = true
        setScaleEnabled(false)
        pinchZoomEnabled = false
        legend.enabled = false
        
        rightAxis.enabled = false
        
        renderer = LineChartRendererSegmented(dataProvider: self,
                                              animator: chartAnimator,
                                              viewPortHandler: viewPortHandler)
        
        xAxisRenderer = XAxisRendererCustomInterval(viewPortHandler: viewPortHandler,
                                                    axis: xAxis, transformer:
                                                        xAxisRenderer.transformer)
        leftYAxisRenderer = YAxisRendererCustomInterval(viewPortHandler: viewPortHandler,
                                                        axis: leftAxis,
                                                        transformer: leftYAxisRenderer.transformer)
        
        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = self
        marker.minimumSize = CGSize(width: 80, height: 40)
        self.marker = marker
        
        
        setupXAxis()
        setupYAxis()
    }
    
    func setupXAxis() {
        xAxis.gridLineDashLengths = [10, 10]
        xAxis.gridLineDashPhase = 0
        xAxis.labelPosition = .bottom
        xAxis.granularity = 3
        xAxis.axisMinimum = 0
//        xAxis.axisMaximum = 32
        xAxis.avoidFirstLastClippingEnabled = true
    }
    
    func setupYAxis() {
        leftAxis.removeAllLimitLines()
        leftAxis.axisMaximum = 154
        leftAxis.granularity = 37
        leftAxis.axisMinimum = 0
        leftAxis.drawLimitLinesBehindDataEnabled = true
    }
}

class CustomLineChartViewController: DemoBaseViewController {
    
    @IBOutlet var chartView: CustomLineChartView!
    @IBOutlet var sliderX: UISlider!
    @IBOutlet var sliderY: UISlider!
    @IBOutlet var sliderTextX: UITextField!
    @IBOutlet var sliderTextY: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Line Chart 1"
        self.options = [.toggleValues,
                        .toggleFilled,
                        .toggleCircles,
                        .toggleCubic,
                        .toggleHorizontalCubic,
                        .toggleIcons,
                        .toggleStepped,
                        .toggleHighlight,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .saveToGallery,
                        .togglePinchZoom,
                        .toggleAutoScaleMinMax,
                        .toggleData]
        
        chartView.delegate = self
        updateChartData()
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        self.setDataCount()
    }
    
    
    func setDataCount() {
        var values = [ChartDataEntry]()
        values.append(ChartDataEntry(x: 1, y: 15))
        values.append(ChartDataEntry(x: 2, y: 42))
        values.append(ChartDataEntry(x: 3, y: 79))
        values.append(ChartDataEntry(x: 4, y: 111))
        values.append(ChartDataEntry(x: 5, y: 84))
        values.append(ChartDataEntry(x: 6, y: 122))
        values.append(ChartDataEntry(x: 7, y: 35))
        values.append(ChartDataEntry(x: 8, y: 79))
        values.append(ChartDataEntry(x: 9, y: 30))
        values.append(ChartDataEntry(x: 10, y: 140))
        
        let set1 = LineChartDataSet(entries: values, label: "DataSet 1")
        set1.drawIconsEnabled = false
        let circleColors = values.map { value -> UIColor in
            switch value.y {
            case 0...37:
                return UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 1.0)
            case 38...74:
                return UIColor(red: 231/255.0, green: 76/255.0, blue: 60/255.0, alpha: 1.0)
            case 75...111:
                return UIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0)
            case 112...148:
                return UIColor(red: 241/255.0, green: 196/255.0, blue: 15/255.0, alpha: 1.0)
            default:
                return UIColor.black
            }
        }
        
      let colors = [UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 1.0),
                   UIColor(red: 231/255.0, green: 76/255.0, blue: 60/255.0, alpha: 1.0),
                   UIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0),
                   UIColor(red: 241/255.0, green: 196/255.0, blue: 15/255.0, alpha: 1.0)
                   ]
        
        set1.highlightLineDashLengths = [5, 2.5]
        set1.colors = colors
        set1.circleColors = circleColors
        set1.lineWidth = 2
        set1.circleRadius = 3
        set1.drawCircleHoleEnabled = true
        set1.circleHoleRadius = 2
        set1.valueFont = .systemFont(ofSize: 9)
        set1.drawValuesEnabled = false
        set1.formLineDashLengths = [5, 2.5]
        set1.formLineWidth = 1
        set1.formSize = 15
        let data = LineChartData(dataSet: set1)
//        var rangeColor: [ClosedRange<Double>: UIColor] = [:]
        
//        (chartView.renderer as? LineChartRendererSegmented).rangeColor = rangeColor
        
        chartView.data = data
//        chartView.viewPortHandler.setMinimumScaleX(2)
//        chartView.viewPortHandler.setMaximumScaleY(20)

        chartView.animate(xAxisDuration: 2.5)
        
    }
}
