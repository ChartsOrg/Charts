//
//  FeedItem.swift
//  ChartsDemo-OSX
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  Copyright © 2017 thierry Hentic.
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts

import Cocoa
import Charts

open class DemoBaseViewController: NSViewController
{
    var parties = [String]()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        parties = ["Party A", "Party B", "Party C", "Party D", "Party E", "Party F", "Party G", "Party H", "Party I", "Party J", "Party K", "Party L", "Party M", "Party N", "Party O", "Party P", "Party Q", "Party R", "Party S", "Party T", "Party U", "Party V", "Party W", "Party X", "Party Y", "Party Z"]
    }
    
    func toggle(_ key: String, chartView : ChartViewBase)
    {
        switch key
        {

        case "Toggle Highlight":
            
            chartView.data?.highlightEnabled = !(chartView.data?.isHighlightEnabled)!
            chartView.needsDisplay = true
            
        case "Toggle Values" :
            for  i in 0..<chartView.data!.dataSets.count
            {
                let set = chartView.data!.dataSets[i]
                set.drawValuesEnabled = !set.isDrawValuesEnabled
            }
            chartView.needsDisplay = true
            
        case "linear":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.linear )
            
        case "easeInQuad":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeOutQuad )
        case "easeOutQuad":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInQuad )
        case "easeInOutQuad":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInOutQuad )
        case "easeInCubic":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInCubic )
        case "easeOutCubic":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeOutCubic )
        case "easeInOutCubic":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInOutCubic )
            
        case "easeInQuart":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInQuart )
        case "easeOutQuart":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeOutQuart )
        case "easeInOutQuart":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInOutQuart )

        case "easeInQuint":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInQuint )
        case "easeOutQuint":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeOutQuint )
        case "easeInOutQuint":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInOutQuint )

        case "easeInSine":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInSine )
        case "easeOutSine":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeOutSine )
        case "easeInOutSine":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInOutSine )

        case "easeInExpo":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInExpo )
        case "easeOutExpo":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeOutExpo )
        case "easeInOutExpo":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInOutExpo )

        case "easeInCirc":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInCirc )
        case "easeOutCirc":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeOutCirc )
        case "easeInOutCirc":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInOutCirc )
        
        case "easeInElastic":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInElastic )
        case "easeOutElastic":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeOutElastic )
        case "easeInOutElastic":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInOutElastic )

        case "easeInBack":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInBack )
        case "easeOutBack":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeOutBack )
        case "easeInOutBack":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInOutBack )

        case "easeInBounce":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInBounce )
        case "easeOutBounce":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeOutBounce )
        case "easeInOutBounce":
            chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption:.easeInOutBounce )

        case "Animate X":
            chartView.animate(xAxisDuration: 3.0)
        case "Animate X":
            chartView.animate(xAxisDuration: 3.0)
 
        case "Animate X":
            chartView.animate(xAxisDuration: 3.0)
            
        case "Animate Y" :
            chartView.animate(yAxisDuration: 3.0)
            
        case "Animate XY":
            chartView.animate(xAxisDuration: 3.0, yAxisDuration: 3.0)
            
        case "Save to Camera Roll":
            
            let myAlert:NSAlert = NSAlert()
            myAlert.messageText = "Save To Gallery not implemented on macOS."
            myAlert.runModal()
            
            //            NSImageWriteToSavedPhotosAlbum(chartView.getChartImage(withTransparent: false), nil, nil, nil)
            break
            
        case "Toggle PinchZoom":
            let barLineChart: BarLineChartViewBase? = (chartView as? BarLineChartViewBase)
            barLineChart?.pinchZoomEnabled = !(barLineChart?.isPinchZoomEnabled)!
            chartView.needsDisplay = true
            
        case "Toggle auto scale min/max":
            
            let barLineChart: BarLineChartViewBase? = (chartView as? BarLineChartViewBase)
            barLineChart?.autoScaleMinMaxEnabled = !(barLineChart?.isAutoScaleMinMaxEnabled)!
            chartView.notifyDataSetChanged()
            
        case "Toggle Data":
            /*          self.shouldHideData = !self.shouldHideData
             self.updateChartData()*/
            break
            
        case "toggleBarBorders":
            
            
  /*          for set: IBarChartDataSet & NSObject in chartView.data.dataSets
            {
                if ([set conformsToProtocol : @protocol(IBarChartDataSet)])
                {
                    set.barBorderWidth = set.barBorderWidth == 1.0 ? 0.0 : 1.0
                }
            }
            chartView.needsDisplay = true*/
            
            
            break
        default:
            print("Type is something else")
        }
    }
    
    func setupPieChartView(_ chartView: PieChartView)
    {
        chartView.usePercentValuesEnabled = true
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.holeRadiusPercent = 0.58
        chartView.transparentCircleRadiusPercent = 0.61
        chartView.chartDescription?.enabled = false
        //        chartView.setExtraOffsetsWithLeft(5.0, top: 10.0, right: 5.0, bottom: 5.0)
        chartView.drawCenterTextEnabled = true
        
        let paragraphStyle: NSMutableParagraphStyle = NSParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let centerText: NSMutableAttributedString = NSMutableAttributedString(string: "Charts\nby Daniel Cohen Gindi")
        centerText.setAttributes([NSFontAttributeName: NSFont(name: "HelveticaNeue-Light", size: 15.0)!, NSParagraphStyleAttributeName: paragraphStyle], range: NSMakeRange(0, centerText.length))
        
        centerText.addAttributes([NSFontAttributeName: NSFont(name: "HelveticaNeue-Light", size: 13.0)!, NSForegroundColorAttributeName: NSColor.gray], range: NSMakeRange(10, centerText.length - 10))
        
        
        centerText.addAttributes([NSFontAttributeName: NSFont(name: "HelveticaNeue-LightItalic", size: 13.0)!, NSForegroundColorAttributeName: NSColor(red: 51 / 255.0, green: 181 / 255.0, blue: 229 / 255.0, alpha: 1.0)], range: NSMakeRange(centerText.length - 19, 19))
        
        chartView.centerAttributedText = centerText
        
        chartView.drawHoleEnabled = true
        chartView.rotationAngle = 0.0
        chartView.rotationEnabled = true
        chartView.highlightPerTapEnabled = true
        
        let l = chartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.drawInside = false
        l.xEntrySpace = 7.0
        l.yEntrySpace = 0.0
        l.yOffset = 0.0
    }
}




