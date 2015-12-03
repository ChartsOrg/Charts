//
//  BubbleChartViewController.swift
//  Ratings
//
//  Created by Nelson Tam on 2015-11-15.
//  Copyright © 2015 Nelson Tam. All rights reserved.
//

import Foundation
import Charts

class BubbleChartViewController : DemoBaseViewController, ChartViewDelegate {
    
    @IBOutlet var _chartView: BubbleChartView!
    @IBOutlet var _sliderX: UISlider!
    @IBOutlet var _sliderY: UISlider!
    @IBOutlet var _sliderTextX: UITextField!
    @IBOutlet var _sliderTextY: UITextField!
    @IBOutlet var _options: UIButton!
    
    var options : Array<NSDictionary> = Array<NSDictionary>()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupMenu() {
        options = [
            ["key": "toggleValues", "label": "Toggle Values"],
            ["key": "toggleHighlight", "label": "Toggle Highlight"],
            ["key": "toggleStartZero", "label": "Toggle StartZero"],
            ["key": "animateX", "label": "Animate X"],
            ["key": "animateY", "label": "Animate Y"],
            ["key": "animateXY", "label": "Animate XY"],
            ["key": "saveToGallery", "label": "Save to Camera Roll"],
            ["key": "togglePinchZoom", "label": "Toggle PinchZoom"],
            ["key": "toggleAutoScaleMinMax", "label": "Toggle auto scale min/max"]
        ]
        var optionNames : Array<String> = Array<String>()
        options.map{ a in optionNames.append(String(a["label"]!))}
        
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green:180/255.0, blue:220/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let menuView = BTNavigationDropdownMenu(title: optionNames.first!, items: optionNames)
        menuView.cellHeight = 50
        menuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
        menuView.cellSelectionColor = UIColor(red: 0.0/255.0, green:160.0/255.0, blue:195.0/255.0, alpha: 1.0)
        menuView.cellTextLabelColor = UIColor.whiteColor()
        menuView.cellTextLabelFont = UIFont(name: "Avenir-Heavy", size: 17)
        menuView.arrowPadding = 15
        menuView.animationDuration = 0.5
        menuView.maskBackgroundColor = UIColor.blackColor()
        menuView.maskBackgroundOpacity = 0.3
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            print("Did select item at index: \(indexPath)")
            self.optionTapped( String(self.options[indexPath]["key"]!))
        }
        
        self.navigationItem.titleView = menuView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMenu()
        
        self.title = "Bubble Chart"
        
        _chartView.delegate = self
        
        _chartView.descriptionText = ""
        _chartView.noDataTextDescription = "You need to provide data for the chart."
        
        _chartView.drawGridBackgroundEnabled = false
        _chartView.dragEnabled = false
        _chartView.setScaleEnabled(true)
        _chartView.maxVisibleValueCount = 200
        _chartView.pinchZoomEnabled = true
        _chartView.leftAxis.startAtZeroEnabled = false
        _chartView.rightAxis.startAtZeroEnabled = false
        
        let l: ChartLegend = _chartView.legend
        l.position = ChartLegend.ChartLegendPosition.RightOfChart
        l.font = UIFont(name: "HelveticaNeue-Light", size:10)!
        
        let yl: ChartYAxis = _chartView.leftAxis
        yl.labelFont = UIFont(name: "HelveticaNeue-Light", size:10)!
        yl.spaceTop = 0.3
        yl.startAtZeroEnabled = false
        yl.spaceBottom = 0.3
        
        _chartView.rightAxis.enabled = false
        
        let xl: ChartXAxis = _chartView.xAxis
        xl.labelPosition = ChartXAxis.XAxisLabelPosition.Bottom
        xl.labelFont = UIFont(name: "HelveticaNeue-Light", size:10)!
        
        _sliderX.value = 5.0
        _sliderY.value = 50.0
        self.setDataCount(Int(_sliderX.value) + 1, range:Double(_sliderY.value))
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == _optionsTableView)
        {
            return self.options.count;
        }
        
        return 0;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        if ((cell == nil)) {
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            cell!.backgroundView = nil;
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel!.textColor = UIColor.whiteColor()
        }
        
        cell!.textLabel!.text = String(self.options[indexPath.row]["label"])
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView == _optionsTableView)
        {
            tableView.deselectRowAtIndexPath(indexPath, animated:true)
            
            if ((_optionsTableView) != nil)
            {
                _optionsTableView!.removeFromSuperview()
                _optionsTableView = nil;
            }
            
            self.optionTapped(String(self.options[indexPath.row]["key"]))
        }
    }
    
    func setDataCount(count: Int, range: Double) {
        var xVals: Array = Array<Int>()
    
        for (var i: Int = 0; i < count; i++)
        {
            xVals.append(i)
        }
    
        var yVals1 : Array = Array<BubbleChartDataEntry>()
        var yVals2 : Array = Array<BubbleChartDataEntry>()
        var yVals3 : Array = Array<BubbleChartDataEntry>()
    
        for (var i: Int = 0; i < count; i++)
        {
            var val: Double = Double(arc4random_uniform(UInt32(range)))
            var size: CGFloat = CGFloat(arc4random_uniform(UInt32(range)))
            yVals1.append(BubbleChartDataEntry(xIndex: i, value: val, size: size))
            
            val = Double(arc4random_uniform(UInt32(range)))
            size = CGFloat(arc4random_uniform(UInt32(range)))
            yVals2.append(BubbleChartDataEntry(xIndex: i, value: val, size: size))

            val = Double(arc4random_uniform(UInt32(range)))
            size = CGFloat(arc4random_uniform(UInt32(range)))
            yVals3.append(BubbleChartDataEntry(xIndex: i, value: val, size: size))
        }
    
        let set1: BubbleChartDataSet = BubbleChartDataSet(yVals: yVals1, label: "DS 1")
        set1.setColor(ChartColorTemplates.colorful()[0], alpha:0.50)
        set1.drawValuesEnabled = true
        let set2: BubbleChartDataSet = BubbleChartDataSet(yVals: yVals2, label: "DS 2")
        set2.setColor(ChartColorTemplates.colorful()[1], alpha:0.50)
        set2.drawValuesEnabled = true
        let set3 : BubbleChartDataSet = BubbleChartDataSet(yVals: yVals3, label: "DS 3")
        set3.setColor(ChartColorTemplates.colorful()[2], alpha:0.50)
        set3.drawValuesEnabled = true
    
        var dataSets : Array = Array<BubbleChartDataSet>()
        dataSets.append(set1)
        dataSets.append(set2)
        dataSets.append(set3)
    
        let data : BubbleChartData = BubbleChartData(xVals: xVals, dataSets:dataSets)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 7.0))
        data.setHighlightCircleWidth(1.5)
        data.setValueTextColor(UIColor.whiteColor())
    
        _chartView.data = data;
    }

    @IBAction func optionsButtonPressed(sender: UIButton) {
        
    }
    
    override func optionTapped(key: String) {
        if (key == "toggleValues") {
            for set in _chartView.data!.dataSets {
                set.drawValuesEnabled = !set.isDrawValuesEnabled
            }
            _chartView.setNeedsDisplay()
        }
    
        if (key == "toggleFilled") {
            for set in _chartView.data!.dataSets {
                if (set is LineRadarChartDataSet) {
                    let finalSet : LineRadarChartDataSet = set as! LineRadarChartDataSet
                    finalSet.drawFilledEnabled = !(finalSet.drawFilledEnabled)
                }
            }
            _chartView.setNeedsDisplay()
        }
    
        if (key == "toggleCircles") {
            for set in _chartView.data!.dataSets {
                if (set is LineRadarChartDataSet) {
                    let finalSet : LineChartDataSet = set as! LineChartDataSet
                    finalSet.drawCirclesEnabled = !(finalSet.drawCirclesEnabled)
                }
            }
    
            _chartView.setNeedsDisplay()
        }
    
        if (key == "toggleCubic") {
            for set in _chartView.data!.dataSets {
                if (set is LineRadarChartDataSet) {
                    let finalSet : LineChartDataSet = set as! LineChartDataSet
                    finalSet.drawCubicEnabled = !(finalSet.drawCubicEnabled)
                }
            }
    
            _chartView.setNeedsDisplay()
        }
    
        if (key == "toggleHighlight") {
            _chartView.data!.highlightEnabled = !_chartView.data!.isHighlightEnabled
            _chartView.setNeedsDisplay()
        }
    
        if (key == "toggleStartZero") {
            _chartView.leftAxis.startAtZeroEnabled = !_chartView.leftAxis.isStartAtZeroEnabled
            _chartView.rightAxis.startAtZeroEnabled = !_chartView.rightAxis.isStartAtZeroEnabled
    
            _chartView.setNeedsDisplay()
        }
    
        if (key == "animateX") {
            _chartView.animate(xAxisDuration: 3.0)
        }
    
        if (key == "animateY") {
            _chartView.animate(yAxisDuration: 3.0)
        }
    
        if (key == "animateXY") {
            _chartView.animate(xAxisDuration: 3.0, yAxisDuration: 3.0)
        }
    
        if (key == "saveToGallery") {
            _chartView.saveToCameraRoll()
        }
    
        if (key == "togglePinchZoom") {
            _chartView.pinchZoomEnabled = !_chartView.isPinchZoomEnabled
    
            _chartView.setNeedsDisplay()
        }
    
        if (key == "toggleAutoScaleMinMax") {
            _chartView.autoScaleMinMaxEnabled = !_chartView.isAutoScaleMinMaxEnabled
            _chartView.notifyDataSetChanged()
        }
    }

    //pragma mark - Actions
    @IBAction func sliderXValueChanged(sender: UISlider) {
        _sliderTextX.text = String(Int(_sliderX.value) + 1)
        
        self.setDataCount(Int(_sliderX.value) + 1, range:Double(_sliderY.value))
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        _sliderTextY.text = String(Int(_sliderY.value))
    
        self.setDataCount(Int(_sliderX.value) + 1, range:Double(_sliderY.value))
    }
}
