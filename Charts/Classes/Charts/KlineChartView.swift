//
//  KlineChartView.swift
//  Charts
//
//  Created by 迅牛 on 16/6/16.
//  Copyright © 2016年 dcg. All rights reserved.
//

import Foundation
import CoreGraphics

@objc
public enum KLineViewType: Int {
    
    case Min = -1
    case Day = 0
    case Week
    case Month
    case Year
}

@objc
public class KlineChartView:UIView,ChartViewDelegate ,ChartXAxisValueFormatter ,ChartYAxisValueFormatter ,XMinMaxProvider {
    
    public var kLineViewType = KLineViewType.Day
    
    public var didAutoShowLast:Bool = false
    
    
    public weak var delegate: ChartViewDelegate?
    let minDateFormatter:NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        return dateFormatter;
    }()
    
    let dayDateFormatter:NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter;
    }()
    
    let monthDateFormatter:NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM"
        return dateFormatter;
    }()
    
    public var maxVisibleCount:Int = 200
    public var minVisibleCount:Int = 20

    func YxisValueFormatter() -> NSNumberFormatter {
        
        return ChartUtils.defaultValueFormatter()
    }
    
//    var currentScale
    
    lazy var candleView:CombinedChartView! = {
        
        let cdView = CombinedChartView()
        cdView.scaleYEnabled = false
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
        cdView.leftAxis.labelCount = 4;
        cdView.leftAxis.maxWidth = 70;
        cdView.leftAxis.labelTextColor = UIColor(white: 0.5, alpha: 1);
        cdView.leftAxis.labelPosition = ChartYAxis.LabelPosition.InsideChart
        cdView.leftAxis.drawTopYLabelEntryEnabled = true
        
//        cdView.rightAxis.enabled = false
        cdView.rightAxis.drawLabelsEnabled = false
        cdView.rightAxis.drawGridLinesEnabled = false
        cdView.rightAxis.drawAxisLineEnabled = false
        
        cdView.xAxis.drawAxisLineEnabled = false
        cdView.xAxis.gridColor = UIColor(white: 0.86, alpha: 0.8);
        cdView.xAxis.labelPosition = ChartXAxis.LabelPosition.Bottom
        cdView.xAxis.drawGridLinesEnabled = true;
        cdView.xAxis.spaceBetweenLabels = 20
        cdView.xAxis.gridLineDashLengths = [2,2]
        cdView.xAxis.avoidFirstLastClippingEnabled = true
       unowned let dele = self
        cdView.xAxis.valueFormatter = dele
        cdView.descriptionText = ""
        cdView.legend.horizontalAlignment = ChartLegend.HorizontalAlignment.Left
        cdView.legend.verticalAlignment = ChartLegend.VerticalAlignment.Top

        cdView.noDataText = "没有数据"
        return cdView
    }()
    
    lazy var qualificationView:CombinedChartView! = {
        
        let cdView = CombinedChartView()
        cdView.scaleYEnabled = false
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
        cdView.leftAxis.labelCount = 4;
        cdView.leftAxis.maxWidth = 70;
        cdView.leftAxis.labelTextColor = UIColor(white: 0.5, alpha: 1);
        cdView.leftAxis.labelPosition = ChartYAxis.LabelPosition.InsideChart
        cdView.leftAxis.drawTopYLabelEntryEnabled = true
        
        //        cdView.rightAxis.enabled = false
        cdView.rightAxis.drawLabelsEnabled = false
        cdView.rightAxis.drawGridLinesEnabled = false
        cdView.rightAxis.drawAxisLineEnabled = false
        
        
        cdView.xAxis.drawAxisLineEnabled = false
        cdView.xAxis.drawLabelsEnabled = false;
        cdView.xAxis.gridColor = UIColor(white: 0.86, alpha: 0.8);
        cdView.xAxis.labelPosition = ChartXAxis.LabelPosition.Bottom
        cdView.xAxis.drawGridLinesEnabled = true;
        cdView.xAxis.spaceBetweenLabels = 20
        cdView.xAxis.gridLineDashLengths = [2,2]
        
//        cdView.setDescriptionTextPosition(x: 20, y: 10)
        cdView.descriptionTextAlign = NSTextAlignment.Right

        cdView.legend.horizontalAlignment = ChartLegend.HorizontalAlignment.Left
        cdView.legend.verticalAlignment = ChartLegend.VerticalAlignment.Top

        cdView.noDataText = ""
        return cdView
    }()
    
    public  func stringForXValue(index: Int, original: String, viewPortHandler: ChartViewPortHandler) -> String {
        
        
        let  date:NSDate = NSDate(timeIntervalSince1970: (original as NSString).doubleValue)
        switch kLineViewType {
        case .Min:
            guard let klineData = klineData else { break }
            guard let viewPortHandler = candleView.viewPortHandler else { break }
            
        let stickWidth = viewPortHandler.contentWidth / CGFloat(abs(klineData._lastStart - klineData._lastEnd))
            
            if stickWidth < 4 {
                return dayDateFormatter.stringFromDate(date);
            }
            return minDateFormatter.stringFromDate(date);
        case .Day:
            guard let klineData = klineData else { break }
            guard let viewPortHandler = candleView.viewPortHandler else { break }
            
            let stickWidth = viewPortHandler.contentWidth / CGFloat(abs(klineData._lastStart - klineData._lastEnd))
            
            if stickWidth < 4 {
                return monthDateFormatter.stringFromDate(date);
            }
            return dayDateFormatter.stringFromDate(date);
        case .Month:
             return monthDateFormatter.stringFromDate(date);
            
        case .Year:
            return monthDateFormatter.stringFromDate(date);

        default:
            break
        }
        return original;
    }
    
    public func stringForNumber(number:NSNumber, xIndex: Int, max:Double ,yAxis: ChartYAxis) -> NSAttributedString {
        
        let value = number.doubleValue;
        
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
            return  NSAttributedString(string:String(format: "%.2f", sValue));
        }
    }
    
    private var candleData:CombinedChartData!
    
    private var qualificationData:CombinedChartData!

    private var _klineData:KlineChartData?
    
    var klineData:KlineChartData? {
        get {
            return _klineData;
        } set {
            _klineData = newValue
//            _klineData.isVisibKline = false
            didAutoShowLast = false
            resetData()
        }
    }
    
    func resetData() {
        
        if klineData == nil {
            candleData = CombinedChartData()
            qualificationData = CombinedChartData()
            
        } else {
            let  kLinwData = klineData!
            
            if klineData?._qualificationType == .VOL {
                
                qualificationView.legend.enabled = false
                qualificationView.leftAxis.axisMinValue = 0
                qualificationView.leftAxis.customValueFormatter = self;
                qualificationView.leftAxis.showOnlyMinMaxEnabled  = true;
            } else {
                qualificationView.leftAxis.showOnlyMinMaxEnabled  = false;
                qualificationView.legend.enabled = true;
                qualificationView.leftAxis.resetCustomAxisMin()
                qualificationView.leftAxis.customValueFormatter = nil;
            }
            
            candleData = CombinedChartData(xVals: kLinwData.xVals)
            candleData.candleData = kLinwData;
            candleData.lineData = kLinwData.emaLineData;
            
            candleView.data = candleData;
        
            var string = ""
            
            switch kLinwData._qualificationType {
            case .KDJ:
                string = "KDJ(9,3,3)"
            case .MACD:
                string = "MACD(12,26,9)"
            default:
                string = ""
            }
            
            qualificationView.descriptionText = string
            
            qualificationData = CombinedChartData(xVals: kLinwData.xVals)
            if kLinwData.quaLificationLineData != nil {
                qualificationData.lineData = kLinwData.quaLificationLineData
            }
            if kLinwData.quaLificationBarData != nil {
                qualificationData.barData = kLinwData.quaLificationBarData
            }
            qualificationView.data = qualificationData
            
            qualificationView.viewPortHandler.setMinMaxScaleX(minScaleX: candleView.viewPortHandler.minScaleX, maxScaleX: candleView.viewPortHandler.maxScaleX)
            redrawLengend(Int(kLinwData._lastEnd))
            
        }
    }

    func defualtAnimation() {
    
        candleView.setVisibleXRange(minXRange: CGFloat(minVisibleCount), maxXRange: CGFloat(maxVisibleCount));
        var matrix = CGAffineTransformMakeScale(candleView.viewPortHandler.scaleX * 1.2, candleView.viewPortHandler.scaleY)
        matrix = CGAffineTransformConcat(matrix, CGAffineTransformMakeTranslation(-((candleView.viewPortHandler.contentWidth * candleView.viewPortHandler.scaleX * 1.2) - candleView.viewPortHandler.contentWidth) , 0))
        qualificationView.viewPortHandler.refresh(newMatrix: matrix, chart: qualificationView, invalidate: true)
        candleView.viewPortHandler.refresh(newMatrix: matrix, chart: candleView, invalidate: true)
        
        guard let kLineData = klineData else { return }
        redrawLengend(Int(kLineData._lastEnd))
        
        didAutoShowLast = true
    }
    public override func awakeFromNib() {
        initView()
    }
    
    private func initView() {
        candleView.xMinMaxProvider = self
        qualificationView.xMinMaxProvider = self
        addSubview(candleView)
        addSubview(qualificationView)

    }
    
    public func xMinMax(chartView: ChartViewBase) {

       chartView._xAxis._axisMinimum = -0.5
        guard candleData != nil else {
            return
        }
       chartView._xAxis._axisMaximum = Double(candleData.xVals.count) + 0.5
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
        
        candleView.frame = CGRect(x: 0,y: 0,width: self.bounds.width ,height: self.bounds.height * 2.0 / 3.0 );
        qualificationView.frame = CGRect(x: 0,y: self.bounds.height * 2.0 / 3.0 ,width:self.bounds.width, height: self.bounds.height * 1.0 / 3.0 );
        
        guard let kLineData = klineData else { return }
        redrawLengend(Int(kLineData._lastEnd))
        
        if didAutoShowLast == false {
            
            defualtAnimation()
        }
    }
    
    public func redrawLengend(xIndex:Int) {
    
        
        guard let kLineData = klineData else { return }
        guard kLineData.dataSets.count > 0 else { return }
        guard kLineData.dataSets[0] is KlineChartDataSet else { return }
        let dataSet =  kLineData.dataSets[0] as! KlineChartDataSet
        
        guard let entry = dataSet.entryForXIndex(xIndex) else  { return }
        let entryKline = entry as! KlineChartDataEntry
        candleView.legend.colors = [dataSet.MA5Color,dataSet.MA10Color,dataSet.MA30Color]
        candleView.legend.labels = [String.init(format: "%@:%.2f", dataSet.ema5DataSet.label!,entryKline.EMA5) ,String.init(format: "%@:%.2f", dataSet.ema10DataSet.label!,entryKline.EMA10),String.init(format: "%@:%.2f", dataSet.ema30DataSet.label!,entryKline.EMA30)]
        candleView.legend.calculateDimensions(labelFont: candleView.legend.font, viewPortHandler: candleView.viewPortHandler)
        
        switch kLineData.qualificationType {
        case .KDJ:
            qualificationView.legend.colors = [dataSet.KDJ_KColor,dataSet.KDJ_DColor,dataSet.KDJ_JColor]
            qualificationView.legend.labels = [String.init(format: "%@:%.2f", "K",entryKline.KDJ_K) ,String.init(format: "%@:%.2f", "D",entryKline.KDJ_D),String.init(format: "%@:%.2f", "J",entryKline.KDJ_J)]
        case .MACD:
            
            qualificationView.legend.colors = [dataSet.MACD_DIFColor,dataSet.MACD_DEAColor,dataSet.MACD_Color]
            qualificationView.legend.labels = [String.init(format: "%@:%.2f", "DIF",entryKline.DIF) ,String.init(format: "%@:%.2f", "DEA",entryKline.DEA),String.init(format: "%@:%.2f", "MACD",entryKline.MACD)]

        default:
            return
        }
        qualificationView.legend.calculateDimensions(labelFont: qualificationView.legend.font, viewPortHandler: qualificationView.viewPortHandler)
    }
    public func chartValueNothingSelected(chartView: ChartViewBase) {

        if chartView == candleView {
            qualificationView.highlightValue(nil)
            
        } else if chartView == qualificationView {
            candleView.highlightValue(nil)
            
        }
            guard let kLineData = klineData else { return }
            redrawLengend(Int(kLineData._lastEnd))
        delegate?.chartValueNothingSelected?(chartView);
    }
    public func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        
        Swift.print("dataSetIndex \(dataSetIndex)")
        
        if chartView == candleView {
            
            if qualificationView.highlighted.count == 0 || (qualificationView.highlighted.count != 0 && qualificationView.highlighted[0].xIndex != highlight.xIndex) {
                
                qualificationView.highlightValue(xIndex: highlight.xIndex, dataSetIndex: 0, callDelegate: true)
            }
        } else if chartView == qualificationView {
            
            if candleView.highlighted.count == 0 || (candleView.highlighted.count != 0 && candleView.highlighted[0].xIndex != highlight.xIndex) {
                
                candleView.highlightValue(xIndex: highlight.xIndex, dataSetIndex: 0, callDelegate: true)
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
        
        guard let kLineData = klineData else { return }
        
        if chartView.viewPortHandler.scaleX < chartView.viewPortHandler.minScaleX + 0.1 {
            
            
            guard kLineData.isVisibKline == true
                else {
                    return
            }
            kLineData.isVisibKline = false
            
            resetData()
        } else if chartView.viewPortHandler.scaleX > chartView.viewPortHandler.minScaleX + 0.2 {
            
            guard kLineData.isVisibKline == false
                else {
                    return
            }
            kLineData.isVisibKline = true
            
            resetData()
            
        }
        
        delegate?.chartScaled?(chartView, scaleX: scaleX, scaleY: scaleY)
    }
    
    func chartViewRefreshAnother(chartView: ChartViewBase) {
        
        var  anotherView:ChartViewBase!
        if chartView == candleView {
            anotherView = qualificationView
        } else if chartView == qualificationView {
            anotherView = candleView
        }
        
        var matrix = CGAffineTransformMakeScale(chartView.viewPortHandler.scaleX, chartView.viewPortHandler.scaleY)
        matrix = CGAffineTransformConcat(matrix, CGAffineTransformMakeTranslation(chartView.viewPortHandler.transX, 0))
        
        anotherView.viewPortHandler.refresh(newMatrix: matrix, chart: anotherView, invalidate: true)

            guard let kLineData = klineData else { return }
            redrawLengend(Int(kLineData._lastEnd))

    }
    
    
}
