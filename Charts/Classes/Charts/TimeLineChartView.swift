//
//  TimeLineChartView.swift
//  Charts
//
//  Created by 迅牛 on 16/6/16.
//  Copyright © 2016年 dcg. All rights reserved.
//

import Foundation
import CoreGraphics

@objc
public class TimeLineChartView:UIView,ChartViewDelegate ,ChartXAxisValueFormatter ,ChartYAxisValueFormatter ,XMinMaxProvider {
    
    public weak var delegate: ChartViewDelegate?
    let minDateFormatter:NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        return dateFormatter;
    }()
    
    public var maxVisibleCount:Int = 270
    public var minVisibleCount:Int = 20
    
    //    var currentScale
    
    lazy var lineView:CombinedChartView! = {
        
        let cdView = CombinedChartView()
        cdView.scaleYEnabled = false
        cdView.scaleXEnabled = false
        cdView.doubleTapToZoomEnabled = false;
        cdView.delegate = self
        cdView.drawGridBackgroundEnabled = true
        cdView.gridBackgroundColor = UIColor.whiteColor()
        cdView.autoScaleMinMaxEnabled = true
        cdView.drawBordersEnabled = true
        cdView.borderColor = UIColor(white: 0.9, alpha: 1)
        cdView.borderLineWidth = 0.5;
        
        cdView.leftAxis.drawGridLinesEnabled = true;
        cdView.leftAxis.gridLineDashLengths = [2,2]
        cdView.leftAxis.drawAxisLineEnabled = false
        cdView.leftAxis.gridColor = UIColor(white: 0.86, alpha: 0.8);
        cdView.leftAxis.maxWidth = 70;
        cdView.leftAxis.labelTextColor = UIColor(white: 0.3, alpha: 1);
        cdView.leftAxis.labelPosition = ChartYAxis.LabelPosition.InsideChart
        cdView.leftAxis.drawTopYLabelEntryEnabled = true
        
        //        cdView.rightAxis.enabled = false
//        cdView.rightAxis.drawLabelsEnabled = false
        cdView.rightAxis.drawGridLinesEnabled = false
        cdView.rightAxis.customValueFormatter = self
        cdView.leftAxis.customValueFormatter = self
        cdView.rightAxis.drawAxisLineEnabled = false
        cdView.rightAxis.labelPosition = ChartYAxis.LabelPosition.InsideChart
        
        cdView.rightAxis.maxWidth = 70;
        cdView.rightAxis.labelTextColor = UIColor(white: 0.3, alpha: 1);
        cdView.leftAxis.labelCount = 5;
        cdView.leftAxis.forceLabelsEnabled = true;
        cdView.rightAxis.labelCount = 5;
        cdView.rightAxis.forceLabelsEnabled = true;
//        cdView.
        
        
        cdView.xAxis.drawAxisLineEnabled = false
        cdView.xAxis.gridColor = UIColor(white: 0.86, alpha: 0.8);
        cdView.xAxis.labelPosition = ChartXAxis.LabelPosition.Bottom
        cdView.xAxis.drawGridLinesEnabled = true;
        cdView.xAxis.spaceBetweenLabels = 1;
        cdView.xAxis.setLabelsToSkip(120);
        cdView.xAxis.gridLineDashLengths = [2,2]
        cdView.xAxis.avoidFirstLastClippingEnabled = true
        //        cdView.xAxis.enabled = false;
        cdView.descriptionText = ""
        cdView.legend.horizontalAlignment = ChartLegend.HorizontalAlignment.Left
        cdView.legend.verticalAlignment = ChartLegend.VerticalAlignment.Top
        
        cdView.xAxis.valueFormatter = self
        
        cdView.noDataText = "没有数据"
        
        return cdView
    }()
    
    lazy var qualificationView:CombinedChartView! = {
        
        let cdView = CombinedChartView()
        cdView.scaleYEnabled = false
        cdView.scaleXEnabled = false
        cdView.doubleTapToZoomEnabled = false;
        cdView.delegate = self
        cdView.drawGridBackgroundEnabled = true
        cdView.gridBackgroundColor = UIColor.whiteColor()
        cdView.autoScaleMinMaxEnabled = true
        cdView.drawBordersEnabled = true
        cdView.borderColor = UIColor(white: 0.9, alpha: 1)
        cdView.borderLineWidth = 0.5;
        cdView.leftAxis.drawGridLinesEnabled = true;
        cdView.leftAxis.gridLineDashLengths = [2,2]
        cdView.leftAxis.drawAxisLineEnabled = false
        cdView.leftAxis.gridColor = UIColor(white: 0.86, alpha: 0.8);
        cdView.leftAxis.labelCount = 3;
        cdView.leftAxis.forceLabelsEnabled = true
        cdView.leftAxis.maxWidth = 70;
        cdView.leftAxis.labelTextColor = UIColor(white: 0.5, alpha: 1);
        cdView.leftAxis.labelPosition = ChartYAxis.LabelPosition.InsideChart
        cdView.leftAxis.drawTopYLabelEntryEnabled = true
        
        cdView.leftAxis._customValueFormatter = self
        //        cdView.rightAxis.enabled = false
        cdView.rightAxis.drawLabelsEnabled = false
        cdView.rightAxis.drawGridLinesEnabled = false
        cdView.rightAxis.drawAxisLineEnabled = false
        
        
        cdView.xAxis.drawAxisLineEnabled = false
        cdView.xAxis.drawLabelsEnabled = false;
        cdView.xAxis.gridColor = UIColor(white: 0.86, alpha: 0.8);
        cdView.xAxis.labelPosition = ChartXAxis.LabelPosition.Bottom
        cdView.xAxis.drawGridLinesEnabled = true;
        cdView.xAxis.setLabelsToSkip(120);
        cdView.xAxis.gridLineDashLengths = [2,2]
        
        //        cdView.setDescriptionTextPosition(x: 20, y: 10)
        cdView.descriptionTextAlign = NSTextAlignment.Right
        
        cdView.legend.horizontalAlignment = ChartLegend.HorizontalAlignment.Left
        cdView.legend.verticalAlignment = ChartLegend.VerticalAlignment.Top
        
        
         cdView.noDataText = ""
        return cdView
    }()
    
    public func stringForXValue(index: Int, original: String, viewPortHandler: ChartViewPortHandler) -> String {
        
        let  date:NSDate = NSDate(timeIntervalSince1970: (original as NSString).doubleValue)
        
        let calender = NSCalendar.currentCalendar()
        let dateCompnent = calender.components(NSCalendarUnit.Hour, fromDate: date)
        if dateCompnent.hour < 11 {
            return "9:30"
        } else if ( dateCompnent.hour > 11 && dateCompnent.hour < 14) {
            
            return "11:30/13:00";
        } else {
            return "15:00"
        }
    
    }
    
    public func stringForNumber(number:NSNumber, xIndex: Int, max:Double, yAxis:ChartYAxis) -> NSAttributedString {
        
           let value = number.doubleValue;
        if yAxis == qualificationView.leftAxis  {
            
            var string = ""
            
            var  sValue = value;
            if max > 999999999.0 {
                sValue = value / 100000000.0
                string = "亿"
            } else if max > 99999999.0 {
                sValue = value / 10000000.0
                string = "千万"
            } else if max > 9999999.0 {
                sValue = value / 1000000.0
                string = "百万"
            } else if max > 100000.0 {
                
                sValue = value / 10000.0
                string = "万"
            } else {
                string = "0"
            }
            if value == 0 {
                return NSAttributedString(string:string)
            } else {
                return  NSAttributedString(string:String(format: "%.2f", sValue))
            }
        } else if yAxis == lineView.rightAxis {
            
            guard let lineData = timeLineData else { return NSAttributedString(string:"")}
            let value = (value - (lineData.limit)) / (lineData.limit);
            
            var color:NSUIColor = lineView.rightAxis.labelTextColor;
            
            if let dataSet = lineData.dataSets[0] as? TimeLineChartDataSet {
                
                if value > 0 {
                    color = dataSet.increasingColor
                } else if value < 0 {
                    color = dataSet.decreasingColor
                }
            }
        let formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.PercentStyle;
            formatter.maximumFractionDigits = 2;
            formatter.minimumFractionDigits = 1;
            formatter.positivePrefix = "+"
            formatter.negativePrefix = "-"
            
           let string = formatter.stringFromNumber(NSNumber(double: value));
            
            guard string != nil else { return  NSAttributedString(string:"")}
            
            let attributeString = NSAttributedString(string: string!, attributes: [NSForegroundColorAttributeName : color])
            return attributeString;
            
        } else if yAxis == lineView.leftAxis {
            
            
          let string = (lineView.leftAxis.valueFormatter ?? lineView.leftAxis._defaultValueFormatter).stringFromNumber(number)
            
            guard let lineData = timeLineData else { return NSAttributedString(string:"")}
            let value = (value - (lineData.limit)) / (lineData.limit);
            
            var color:NSUIColor = lineView.rightAxis.labelTextColor;
            
            if let dataSet = lineData.dataSets[0] as? TimeLineChartDataSet {
                
                if value > 0 {
                    color = dataSet.increasingColor
                } else if value < 0 {
                    color = dataSet.decreasingColor
                }
            }

            guard string != nil else { return  NSAttributedString(string:"")}
            
            let attributeString = NSAttributedString(string: string!, attributes: [NSForegroundColorAttributeName : color])
            return attributeString;
            
        }

    
        return NSAttributedString(string:"")
    }
    
    private var qualificationData:CombinedChartData!
    
    private var _timeLineData:TimeLineData?
    
    var timeLineData:TimeLineData? {
        get {
            return _timeLineData;
        } set {
            _timeLineData = newValue
            //            _klineData.isVisibKline = false
            
            resetData()
            defualtAnimation()
        }
    }
    
    func resetData() {
        
        if _timeLineData == nil {
            qualificationData = CombinedChartData()
            
        } else {
            let  lineData = timeLineData!
            
            
            let data  = CombinedChartData(xVals: lineData.xVals)
            
            qualificationView.legend.enabled = false
            qualificationView.leftAxis.axisMinValue = 0
            qualificationView.leftAxis.customValueFormatter = self;
            qualificationView.leftAxis.showOnlyMinMaxEnabled  = true;
        
            data.lineData = lineData.mainLineData;
            lineView.data = data;
            lineView.setVisibleXRangeMaximum(270);
            
//            let limit =ChartLimitLine(limit: lineData.limit, label: String(format: "%.2f", lineData.limit))
////            limit.lineColor = 
//            lineView.leftAxis.addLimitLine()
//            lineView.setVisibleXRange(minXRange: CGFloat(minVisibleCount), maxXRange: CGFloat(maxVisibleCount));
            
            qualificationView.descriptionText = "(VOL)"
            
            qualificationData = CombinedChartData(xVals: lineData.xVals)

            if lineData.qulificationBarData.dataSets.count != 0 {
                qualificationData.barData = lineData.qulificationBarData
            }
            qualificationView.data = qualificationData
            
            lineView.leftAxis.axisMaxValue = lineData.yMax;
            lineView.leftAxis.axisMinValue = lineData.yMin;
            lineView.rightAxis.axisMaxValue = lineData.yMax;
            lineView.rightAxis.axisMinValue = lineData.yMin;
            
            
//            qualificationView.viewPortHandler.setMinMaxScaleX(minScaleX: lineView.viewPortHandler.minScaleX, maxScaleX: lineView.viewPortHandler.maxScaleX)
            redrawLengend(Int(lineData._lastEnd))
            
        }
    }
    
    func defualtAnimation() {
        
//        var matrix = CGAffineTransformMakeScale(lineView.viewPortHandler.scaleX * 2, lineView.viewPortHandler.scaleY)
//        matrix = CGAffineTransformConcat(matrix, CGAffineTransformMakeTranslation(-((lineView.viewPortHandler.contentWidth * lineView.viewPortHandler.scaleX * 2) - lineView.viewPortHandler.contentWidth) , 0))
//        qualificationView.viewPortHandler.refresh(newMatrix: matrix, chart: qualificationView, invalidate: true)
//        lineView.viewPortHandler.refresh(newMatrix: matrix, chart: lineView, invalidate: true)
//        
        guard let lineData = timeLineData else { return }
        redrawLengend(Int(lineData._lastEnd))
    }
    public override func awakeFromNib() {
        initView()
    }
    
    private func initView() {
        lineView.xMinMaxProvider = self
        qualificationView.xMinMaxProvider = self
        addSubview(lineView)
        addSubview(qualificationView)
        
    }
    
    public func xMinMax(chartView: ChartViewBase) {
        
        chartView._xAxis._axisMinimum = -0.5
        guard timeLineData != nil else {
            return
        }
        chartView._xAxis._axisMaximum = Double(270) + 0.5
        chartView._xAxis.axisRange = abs(chartView._xAxis._axisMaximum - chartView._xAxis._axisMinimum)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        lineView.frame = CGRect(x: 0,y: 0,width: self.bounds.width ,height: self.bounds.height * 2.0 / 3.0 );
        qualificationView.frame = CGRect(x: 0,y: self.bounds.height * 2.0 / 3.0 ,width:self.bounds.width, height: self.bounds.height * 1.0 / 3.0 );
        
        guard let kLineData = timeLineData else { return }
        redrawLengend(Int(kLineData._lastEnd))
    }
    
    public func redrawLengend(xIndex:Int) {
        
        
        guard let kLineData = timeLineData else { return }
        guard kLineData.dataSets.count > 0 else { return }
        guard kLineData.dataSets[0] is TimeLineChartDataSet else { return }
        let dataSet =  kLineData.dataSets[0] as! TimeLineChartDataSet
        
        guard let entry = dataSet.entryForXIndex(xIndex) else  { return }
        if  let entryTimeline = entry as? TimelineDataEntry {
            
            lineView.legend.colors = [NSUIColor.clearColor()]
            lineView.legend.labels = [String(format: "%@:%@","时间",minDateFormatter.stringFromDate(NSDate(timeIntervalSince1970:entryTimeline.time)))];
            
            lineView.legend.colors.append(dataSet.colorAt(0))
            lineView.legend.labels.append(String(format: "%@:%.2f","现价",entryTimeline.current))

            if dataSet.avgVisibe {
                
                lineView.legend.colors.append(dataSet.avgColor)
                lineView.legend.labels.append(String(format: "%@:%.2f","均价",entryTimeline.avg))
            }
            
            let uni = stringForNumber(0, xIndex:0, max:entryTimeline.volume, yAxis: qualificationView.leftAxis)
            
            lineView.legend.colors.append(UIColor.blackColor());
            lineView.legend.labels.append(String(format: "%@:%@%@","成交", stringForNumber(entryTimeline.volume, xIndex: entryTimeline.xIndex, max:entryTimeline.volume, yAxis: qualificationView.leftAxis).string,(uni.string != "0" ? uni.string :"")))
        }

        lineView.legend.calculateDimensions(labelFont: lineView.legend.font, viewPortHandler: lineView.viewPortHandler)
        
//        qualificationView.legend.colors = [dataSet.MACD_DIFColor,dataSet.MACD_DEAColor,dataSet.MACD_Color]
//        qualificationView.legend.labels = [String.init(format: "%@:%.2f", "DIF",entryKline.DIF) ,String.init(format: "%@:%.2f", "DEA",entryKline.DEA),String.init(format: "%@:%.2f", "MACD",entryKline.MACD)]
//  
//        qualificationView.legend.calculateDimensions(labelFont: qualificationView.legend.font, viewPortHandler: qualificationView.viewPortHandler)
    }
    public func chartValueNothingSelected(chartView: ChartViewBase) {
        
        if chartView == lineView {
            qualificationView.highlightValue(nil)
            
        } else if chartView == qualificationView {
            lineView.highlightValue(nil)
            
        }
        guard let lineData = timeLineData else { return }
        redrawLengend(Int(lineData._lastEnd))
        delegate?.chartValueNothingSelected?(lineView);
    }
    public func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        
        Swift.print("dataSetIndex \(dataSetIndex)")
        
        if chartView == lineView {
            
            if qualificationView.highlighted.count == 0 || (qualificationView.highlighted.count != 0 && qualificationView.highlighted[0].xIndex != highlight.xIndex) {
                
                qualificationView.highlightValue(xIndex: highlight.xIndex, dataSetIndex: 0, callDelegate: true)
            }
        } else if chartView == qualificationView {
            
            if lineView.highlighted.count == 0 || (lineView.highlighted.count != 0 && lineView.highlighted[0].xIndex != highlight.xIndex) {
                
                lineView.highlightValue(xIndex: highlight.xIndex, dataSetIndex: 0, callDelegate: true)
            }
        }
        redrawLengend(highlight.xIndex)
        delegate?.chartValueSelected?(chartView, entry: entry, dataSetIndex: dataSetIndex, highlight: highlight)
    }
    
    public func chartTranslated(chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        chartViewRefreshAnother(chartView)
        delegate?.chartTranslated?(chartView, dX: dX, dY: dY)
    }
    public func chartScaled(chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
        chartViewRefreshAnother(chartView)

        delegate?.chartScaled?(chartView, scaleX: scaleX, scaleY: scaleY)
    }
    
    func chartViewRefreshAnother(chartView: ChartViewBase) {
        
        var  anotherView:ChartViewBase!
        if chartView == lineView {
            anotherView = qualificationView
        } else if chartView == qualificationView {
            anotherView = lineView
        }
        
        var matrix = CGAffineTransformMakeScale(chartView.viewPortHandler.scaleX, chartView.viewPortHandler.scaleY)
        matrix = CGAffineTransformConcat(matrix, CGAffineTransformMakeTranslation(chartView.viewPortHandler.transX, 0))
        
        anotherView.viewPortHandler.refresh(newMatrix: matrix, chart: anotherView, invalidate: true)
        
        guard let lineData = timeLineData else { return }
        redrawLengend(Int(lineData._lastEnd))
        
    }
    
    
}
