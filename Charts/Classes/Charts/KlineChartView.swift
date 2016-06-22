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
public class KlineChartView:UIView,ChartViewDelegate ,ChartXAxisValueFormatter ,XMinMaxProvider{
    
    var formatter:NSNumberFormatter?
    
    func YxisValueFormatter() -> NSNumberFormatter {
        
        return ChartUtils.defaultValueFormatter()
    }
    
    lazy var candleView:CombinedChartView! = {
        
        let cdView = CombinedChartView()
        cdView.scaleYEnabled = false
        cdView.delegate = self
        cdView.drawGridBackgroundEnabled = true
        cdView.gridBackgroundColor = UIColor.whiteColor()
        cdView.autoScaleMinMaxEnabled = true
        cdView.leftAxis.drawGridLinesEnabled = true;
        cdView.rightAxis.enabled = false
        cdView.xAxis.labelPosition = ChartXAxis.LabelPosition.Bottom
        cdView.xAxis.drawGridLinesEnabled = true;
//        cdView.xAxis.gridLineDashLengths = [10,20]
        cdView.xAxis.gridColor = UIColor(white: 0.86, alpha: 0.8);
        cdView.leftAxis.gridColor = UIColor(white: 0.86, alpha: 0.8);
//        cdView.leftAxis.gridLineDashLengths = [10,20]
//        cdView.renderer.
//        cdView.la
        cdView.leftAxis.labelCount = 4;
        
        cdView.leftAxis.labelTextColor = UIColor(white: 0.5, alpha: 1);
        cdView.leftAxis.labelPosition = ChartYAxis.LabelPosition.InsideChart
        cdView.xAxis.spaceBetweenLabels = 20
         cdView.leftAxis.maxWidth = 70;
//        cdView.xAxis.valueFormatter = self
        
     
//        cdView._autoScaleMinMaxEnabled = true
//        cdView._maxVisibleValueCount = 100;
        
        return cdView
    }()
    
    public func stringForXValue(index: Int, original: String, viewPortHandler: ChartViewPortHandler) -> String {
        
        return ""
    }

    
    lazy var qualificationView:CombinedChartView! = {
        
        let cdView = CombinedChartView()
        cdView.scaleYEnabled = false
        cdView.delegate = self
        cdView.drawGridBackgroundEnabled = true
        cdView.gridBackgroundColor = UIColor.whiteColor()
        cdView.autoScaleMinMaxEnabled = true
        cdView.leftAxis.drawGridLinesEnabled = true;
        cdView.rightAxis.enabled = false
        cdView.xAxis.labelPosition = ChartXAxis.LabelPosition.Bottom
        cdView.xAxis.drawGridLinesEnabled = true;
        //        cdView.xAxis.gridLineDashLengths = [10,20]
        cdView.xAxis.gridColor = UIColor(white: 0.86, alpha: 0.8);
        cdView.leftAxis.gridColor = UIColor(white: 0.86, alpha: 0.8);
        
        cdView.leftAxis.labelCount = 4;
        
        cdView.leftAxis.maxWidth = 70;
//        cdView.leftAxis.minWidth = 50;
        cdView.leftAxis.labelTextColor = UIColor(white: 0.5, alpha: 1);
        cdView.leftAxis.labelPosition = ChartYAxis.LabelPosition.InsideChart
        //        cdView.leftAxis.gridLineDashLengths = [10,20]
        //        cdView.renderer.
        //        cdView.la
//        cdView.viewPortHandler = can
        
//        cdView.xAxis.valueFormatter = self
//        cdView.leftAxis.valueFormatter = formatter
        cdView._xAxis._axisMinimum = -0.5;
        cdView.xAxis.spaceBetweenLabels = 20
//        cdView.viewPortHandler.setDragOffsetX(0);
        
//        cdView.viewPortHandler.contentLeft = (10);
        return cdView
    }()
    
    private var candleData:CombinedChartData!
    
    private var qualificationData:CombinedChartData!

    private var _klineData:KlineChartData!
    var klineData:KlineChartData {
        get {
            return _klineData;
        } set {
            _klineData = newValue
            candleData = CombinedChartData(xVals: newValue.xVals)
            candleData.candleData = newValue;
            candleData.lineData = newValue.emaLineData;
            candleView.data = candleData;
//            candleView.data = self.klineData;
            candleView.setVisibleXRange(minXRange: 20, maxXRange: 150);
//            candleView.viewPortHandler.
            
            qualificationData = CombinedChartData(xVals: newValue.xVals)
            qualificationData.lineData = newValue.kdjLineData
          
//            qualificationData.candleData
            
            qualificationView.data = qualificationData
            
            qualificationView.xAxis._axisMaximum = candleView.xAxis._axisMaximum
            
            

            qualificationView.viewPortHandler.setMaximumScaleX(candleView.viewPortHandler.maxScaleX)
            qualificationView.viewPortHandler.setMinimumScaleX(candleView.viewPortHandler.minScaleX)
//
        }
    }
    
    public override func awakeFromNib() {
        
        initView()

        
    }
    
    private func initView() {
        
//        candleView.leftAxis.valueFormatter = formatter
        candleView.xMinMaxProvider = self
        qualificationView.xMinMaxProvider = self
        addSubview(candleView)
        addSubview(qualificationView)
//        qualificationView.viewPortHandler = candleView.viewPortHandler
        
//        candleView.renderer as
        //        candleView.drawOrder = [CombinedChartView.DrawOrder.Line ,CombinedChartView.DrawOrder.Candle]
        
    }
    
    public func xMinMax(chartView: ChartViewBase) {

       chartView._xAxis._axisMinimum = -0.5
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
    
//    public override init(frame: CGRect) {
//        super.init(frame:frame)
////        addSubview(candleView)
//        awakeFromNib()
//    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        candleView.frame = CGRect(x: 0,y: 0,width: self.bounds.width ,height: self.bounds.height * 2.0 / 3.0 );
        qualificationView.frame = CGRect(x: 0,y: self.bounds.height * 2.0 / 3.0 ,width:self.bounds.width, height: self.bounds.height * 1.0 / 3.0 );
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
    }
    
    public func chartTranslated(chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        chartViewRefreshAnother(chartView)
    }
    public func chartScaled(chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        chartViewRefreshAnother(chartView)
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
        
//       var  oldPoint = chartView.viewPortHandler.contentRect.origin
//        (chartView as! BarLineChartViewBase).getTransformer(.Left).pixelToValue(&oldPoint)
//        var newPoint = oldPoint
//        
//         (chartView as! BarLineChartViewBase).getTransformer(.Left).pointValueToPixel(&newPoint)
//        
//        
//        anotherView.viewPortHandler.centerViewPort(pt: newPoint, chart: anotherView)
    }
}
