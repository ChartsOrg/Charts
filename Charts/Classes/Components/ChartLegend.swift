//
//  ChartLegend.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 24/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif


open class ChartLegend: ChartComponentBase
{
    /// This property is deprecated - Use `position`, `horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.
    @available(*, deprecated:1.0, message:"Use `position`, `horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.")
    @objc(ChartLegendPosition)
    public enum Position: Int
    {
        case rightOfChart
        case rightOfChartCenter
        case rightOfChartInside
        case leftOfChart
        case leftOfChartCenter
        case leftOfChartInside
        case belowChartLeft
        case belowChartRight
        case belowChartCenter
        case aboveChartLeft
        case aboveChartRight
        case aboveChartCenter
        case piechartCenter
    }
    
    @objc(ChartLegendForm)
    public enum Form: Int
    {
        case square
        case circle
        case line
    }
    
    @objc(ChartLegendHorizontalAlignment)
    public enum HorizontalAlignment: Int
    {
        case left
        case center
        case right
    }
    
    @objc(ChartLegendVerticalAlignment)
    public enum VerticalAlignment: Int
    {
        case top
        case center
        case bottom
    }
    
    @objc(ChartLegendOrientation)
    public enum Orientation: Int
    {
        case horizontal
        case vertical
    }
    
    @objc(ChartLegendDirection)
    public enum Direction: Int
    {
        case leftToRight
        case rightToLeft
    }

    /// the legend colors array, each color is for the form drawn at the same index
    open var colors = [NSUIColor?]()
    
    // the legend text array. a nil label will start a group.
    open var labels = [String?]()
    
    internal var _extraColors = [NSUIColor?]()
    internal var _extraLabels = [String?]()
    
    /// colors that will be appended to the end of the colors array after calculating the legend.
    open var extraColors: [NSUIColor?] { return _extraColors; }
    
    /// labels that will be appended to the end of the labels array after calculating the legend. a nil label will start a group.
    open var extraLabels: [String?] { return _extraLabels; }
    
    /// Are the legend labels/colors a custom value or auto calculated? If false, then it's auto, if true, then custom.
    /// 
    /// **default**: false (automatic legend)
    private var _isLegendCustom = false
    
    /// This property is deprecated - Use `position`, `horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.
    @available(*, deprecated:1.0, message:"Use `position`, `horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.")
    open var position: Position
    {
        get
        {
            if orientation == .vertical && horizontalAlignment == .center && verticalAlignment == .center
            {
                return .piechartCenter
            }
            else if orientation == .horizontal
            {
                if verticalAlignment == .top
                {
                    return horizontalAlignment == .left ? .aboveChartLeft : (horizontalAlignment == .right ? .aboveChartRight : .aboveChartCenter)
                }
                else
                {
                    return horizontalAlignment == .left ? .belowChartLeft : (horizontalAlignment == .right ? .belowChartRight : .belowChartCenter)
                }
            }
            else
            {
                if horizontalAlignment == .left
                {
                    return verticalAlignment == .top && drawInside ? .leftOfChartInside : (verticalAlignment == .center ? .leftOfChartCenter : .leftOfChart)
                }
                else
                {
                    return verticalAlignment == .top && drawInside ? .rightOfChartInside : (verticalAlignment == .center ? .rightOfChartCenter : .rightOfChart)
                }
            }
        }
        set
        {
            switch newValue
            {
            case .leftOfChart: fallthrough
            case .leftOfChartInside: fallthrough
            case .leftOfChartCenter:
                horizontalAlignment = .left
                verticalAlignment = newValue == .leftOfChartCenter ? .center : .top
                orientation = .vertical
                
            case .rightOfChart: fallthrough
            case .rightOfChartInside: fallthrough
            case .rightOfChartCenter:
                horizontalAlignment = .right
                verticalAlignment = newValue == .rightOfChartCenter ? .center : .top
                orientation = .vertical
                
            case .aboveChartLeft: fallthrough
            case .aboveChartCenter: fallthrough
            case .aboveChartRight:
                horizontalAlignment = newValue == .aboveChartLeft ? .left : (newValue == .aboveChartRight ? .right : .center)
                verticalAlignment = .top
                orientation = .horizontal
                
            case .belowChartLeft: fallthrough
            case .belowChartCenter: fallthrough
            case .belowChartRight:
                horizontalAlignment = newValue == .belowChartLeft ? .left : (newValue == .belowChartRight ? .right : .center)
                verticalAlignment = .bottom
                orientation = .horizontal
                
            case .piechartCenter:
                horizontalAlignment = .center
                verticalAlignment = .center
                orientation = .vertical
            }
            
            drawInside = newValue == .leftOfChartInside || newValue == .rightOfChartInside
        }
    }
    
    /// The horizontal alignment of the legend
    open var horizontalAlignment: HorizontalAlignment = HorizontalAlignment.left
    
    /// The vertical alignment of the legend
    open var verticalAlignment: VerticalAlignment = VerticalAlignment.bottom
    
    /// The orientation of the legend
    open var orientation: Orientation = Orientation.horizontal
    
    /// Flag indicating whether the legend will draw inside the chart or outside
    open var drawInside: Bool = false
    
    /// Flag indicating whether the legend will draw inside the chart or outside
    open var isDrawInsideEnabled: Bool { return drawInside }
    
    /// The text direction of the legend
    open var direction: Direction = Direction.leftToRight

    open var font: NSUIFont = NSUIFont.systemFont(ofSize: 10.0)
    open var textColor = NSUIColor.black
    open var form = Form.square
    open var formSize = CGFloat(8.0)
    open var formLineWidth = CGFloat(1.5)
    
    open var xEntrySpace = CGFloat(6.0)
    open var yEntrySpace = CGFloat(0.0)
    open var formToTextSpace = CGFloat(5.0)
    open var stackSpace = CGFloat(3.0)
    
    open var calculatedLabelSizes = [CGSize]()
    open var calculatedLabelBreakPoints = [Bool]()
    open var calculatedLineSizes = [CGSize]()
    
    public override init()
    {
        super.init()
        
        self.xOffset = 5.0
        self.yOffset = 3.0
    }
    
    public init(colors: [NSUIColor?], labels: [String?])
    {
        super.init()
        
        self.colors = colors
        self.labels = labels
    }
    
    public init(colors: [NSObject], labels: [NSObject])
    {
        super.init()
        
        self.colorsObjc = colors
        self.labelsObjc = labels
    }
    
    open func getMaximumEntrySize(_ font: NSUIFont) -> CGSize
    {
        var maxW = CGFloat(0.0)
        var maxH = CGFloat(0.0)
        
        var labels = self.labels
        for i in 0 ..< labels.count
        {
            if (labels[i] == nil)
            {
                continue
            }
            
            let size = (labels[i] as NSString!).size(attributes: [NSFontAttributeName: font])
            
            if (size.width > maxW)
            {
                maxW = size.width
            }
            if (size.height > maxH)
            {
                maxH = size.height
            }
        }
        
        return CGSize(
            width: maxW + formSize + formToTextSpace,
            height: maxH
        )
    }
    
    open func getLabel(_ index: Int) -> String?
    {
        return labels[index]
    }
    
    /// This function is deprecated - Please read `neededWidth`/`neededHeight` after `calculateDimensions` was called.
    @available(*, deprecated:1.0, message:"Please read `neededWidth`/`neededHeight` after `calculateDimensions` was called.")
    open func getFullSize(_ labelFont: NSUIFont) -> CGSize
    {
        return CGSize(width: neededWidth, height: neededHeight)
    }

    open var neededWidth = CGFloat(0.0)
    open var neededHeight = CGFloat(0.0)
    open var textWidthMax = CGFloat(0.0)
    open var textHeightMax = CGFloat(0.0)
    
    /// flag that indicates if word wrapping is enabled
    /// this is currently supported only for `orientation == Horizontal`.
    /// you may want to set maxSizePercent when word wrapping, to set the point where the text wraps.
    /// 
    /// **default**: false
    open var wordWrapEnabled = true

    /// The maximum relative size out of the whole chart view in percent.
    /// If the legend is to the right/left of the chart, then this affects the width of the legend.
    /// If the legend is to the top/bottom of the chart, then this affects the height of the legend.
    /// 
    /// **default**: 0.95 (95%)
    open var maxSizePercent: CGFloat = 0.95
    
    open func calculateDimensions(labelFont: NSUIFont, viewPortHandler: ChartViewPortHandler)
    {
        let maxEntrySize = getMaximumEntrySize(labelFont)
        textWidthMax = maxEntrySize.width
        textHeightMax = maxEntrySize.height
        
        switch orientation
        {
        case .vertical:
            
            var maxWidth = CGFloat(0.0)
            var width = CGFloat(0.0)
            var maxHeight = CGFloat(0.0)
            let labelLineHeight = labelFont.lineHeight
            
            var labels = self.labels
            let count = labels.count
            var wasStacked = false
            
            for i in 0 ..< count
            {
                let drawingForm = colors[i] != nil
                
                if !wasStacked
                {
                    width = 0.0
                }
                
                if drawingForm
                {
                    if wasStacked
                    {
                        width += stackSpace
                    }
                    width += formSize
                }
                
                if labels[i] != nil
                {
                    let size = (labels[i] as NSString!).size(attributes: [NSFontAttributeName: labelFont])
                    
                    if drawingForm && !wasStacked
                    {
                        width += formToTextSpace
                    }
                    else if wasStacked
                    {
                        maxWidth = max(maxWidth, width)
                        maxHeight += labelLineHeight + yEntrySpace
                        width = 0.0
                        wasStacked = false
                    }
                    
                    width += size.width
                    
                    if (i < count - 1)
                    {
                        maxHeight += labelLineHeight + yEntrySpace
                    }
                }
                else
                {
                    wasStacked = true
                    width += formSize
                    
                    if (i < count - 1)
                    {
                        width += stackSpace
                    }
                }
                
                maxWidth = max(maxWidth, width)
            }
            
            neededWidth = maxWidth
            neededHeight = maxHeight
            
        case .horizontal:
            
            var labels = self.labels
            var colors = self.colors
            let labelCount = labels.count
            
            let labelLineHeight = labelFont.lineHeight
            let formSize = self.formSize
            let formToTextSpace = self.formToTextSpace
            let xEntrySpace = self.xEntrySpace
            let stackSpace = self.stackSpace
            let wordWrapEnabled = self.wordWrapEnabled
            
            let contentWidth: CGFloat = viewPortHandler.contentWidth * maxSizePercent
            
            // Prepare arrays for calculated layout
            if (calculatedLabelSizes.count != labelCount)
            {
                calculatedLabelSizes = [CGSize](repeating: CGSize(), count: labelCount)
            }
            
            if (calculatedLabelBreakPoints.count != labelCount)
            {
                calculatedLabelBreakPoints = [Bool](repeating: false, count: labelCount)
            }
            
            calculatedLineSizes.removeAll(keepingCapacity: true)
            
            // Start calculating layout
            
            let labelAttrs = [NSFontAttributeName: labelFont]
            var maxLineWidth: CGFloat = 0.0
            var currentLineWidth: CGFloat = 0.0
            var requiredWidth: CGFloat = 0.0
            var stackedStartIndex: Int = -1
            
            for i in 0 ..< labelCount
            {
                let drawingForm = colors[i] != nil
                
                calculatedLabelBreakPoints[i] = false
                
                if (stackedStartIndex == -1)
                {
                    // we are not stacking, so required width is for this label only
                    requiredWidth = 0.0
                }
                else
                {
                    // add the spacing appropriate for stacked labels/forms
                    requiredWidth += stackSpace
                }
                
                // grouped forms have null labels
                if (labels[i] != nil)
                {
                    calculatedLabelSizes[i] = (labels[i] as NSString!).size(attributes: labelAttrs)
                    requiredWidth += drawingForm ? formToTextSpace + formSize : 0.0
                    requiredWidth += calculatedLabelSizes[i].width
                }
                else
                {
                    calculatedLabelSizes[i] = CGSize()
                    requiredWidth += drawingForm ? formSize : 0.0
                    
                    if (stackedStartIndex == -1)
                    {
                        // mark this index as we might want to break here later
                        stackedStartIndex = i
                    }
                }
                
                if (labels[i] != nil || i == labelCount - 1)
                {
                    let requiredSpacing = currentLineWidth == 0.0 ? 0.0 : xEntrySpace
                    
                    if (!wordWrapEnabled || // No word wrapping, it must fit.
                        currentLineWidth == 0.0 || // The line is empty, it must fit.
                        (contentWidth - currentLineWidth >= requiredSpacing + requiredWidth)) // It simply fits
                    {
                        // Expand current line
                        currentLineWidth += requiredSpacing + requiredWidth
                    }
                    else
                    { // It doesn't fit, we need to wrap a line
                        
                        // Add current line size to array
                        calculatedLineSizes.append(CGSize(width: currentLineWidth, height: labelLineHeight))
                        maxLineWidth = max(maxLineWidth, currentLineWidth)
                        
                        // Start a new line
                        calculatedLabelBreakPoints[stackedStartIndex > -1 ? stackedStartIndex : i] = true
                        currentLineWidth = requiredWidth
                    }
                    
                    if (i == labelCount - 1)
                    { // Add last line size to array
                        calculatedLineSizes.append(CGSize(width: currentLineWidth, height: labelLineHeight))
                        maxLineWidth = max(maxLineWidth, currentLineWidth)
                    }
                }
                
                stackedStartIndex = labels[i] != nil ? -1 : stackedStartIndex
            }
            
            neededWidth = maxLineWidth
            neededHeight = labelLineHeight * CGFloat(calculatedLineSizes.count) +
                yEntrySpace * CGFloat(calculatedLineSizes.count == 0 ? 0 : (calculatedLineSizes.count - 1))
        }
    }
    
    /// MARK: - Custom legend
    
    /// colors and labels that will be appended to the end of the auto calculated colors and labels after calculating the legend.
    /// (if the legend has already been calculated, you will need to call notifyDataSetChanged() to let the changes take effect)
    open func setExtra(colors: [NSUIColor?], labels: [String?])
    {
        self._extraLabels = labels
        self._extraColors = colors
    }
    
    /// Sets a custom legend's labels and colors arrays.
    /// The colors count should match the labels count.
    /// * Each color is for the form drawn at the same index.
    /// * A nil label will start a group.
    /// * A nil color will avoid drawing a form, and a clearColor will leave a space for the form.
    /// This will disable the feature that automatically calculates the legend labels and colors from the datasets.
    /// Call `resetCustom(...)` to re-enable automatic calculation (and then `notifyDataSetChanged()` is needed).
    open func setCustom(colors: [NSUIColor?], labels: [String?])
    {
        self.labels = labels
        self.colors = colors
        _isLegendCustom = true
    }
    
    /// Calling this will disable the custom legend labels (set by `setLegend(...)`). Instead, the labels will again be calculated automatically (after `notifyDataSetChanged()` is called).
    open func resetCustom()
    {
        _isLegendCustom = false
    }
    
    /// **default**: false (automatic legend)
    /// - returns: true if a custom legend labels and colors has been set
    open var isLegendCustom: Bool
    {
        return _isLegendCustom
    }
    
    /// MARK: - ObjC compatibility
    
    /// colors that will be appended to the end of the colors array after calculating the legend.
    open var extraColorsObjc: [NSObject] { return ChartUtils.bridgedObjCGetNSUIColorArray(swift: _extraColors); }
    
    /// labels that will be appended to the end of the labels array after calculating the legend. a nil label will start a group.
    open var extraLabelsObjc: [NSObject] { return ChartUtils.bridgedObjCGetStringArray(swift: _extraLabels); }
    
    /// the legend colors array, each color is for the form drawn at the same index
    /// (ObjC bridging functions, as Swift 1.2 does not bridge optionals in array to `NSNull`s)
    open var colorsObjc: [NSObject]
    {
        get { return ChartUtils.bridgedObjCGetNSUIColorArray(swift: colors); }
        set { self.colors = ChartUtils.bridgedObjCGetNSUIColorArray(objc: newValue); }
    }
    
    // the legend text array. a nil label will start a group.
    /// (ObjC bridging functions, as Swift 1.2 does not bridge optionals in array to `NSNull`s)
    open var labelsObjc: [NSObject]
    {
        get { return ChartUtils.bridgedObjCGetStringArray(swift: labels); }
        set { self.labels = ChartUtils.bridgedObjCGetStringArray(objc: newValue); }
    }
    
    /// colors and labels that will be appended to the end of the auto calculated colors and labels after calculating the legend.
    /// (if the legend has already been calculated, you will need to call `notifyDataSetChanged()` to let the changes take effect)
    open func setExtra(colors: [NSObject], labels: [NSObject])
    {
        if (colors.count != labels.count)
        {
            fatalError("ChartLegend:setExtra() - colors array and labels array need to be of same size")
        }
        
        self._extraLabels = ChartUtils.bridgedObjCGetStringArray(objc: labels)
        self._extraColors = ChartUtils.bridgedObjCGetNSUIColorArray(objc: colors)
    }
    
    /// Sets a custom legend's labels and colors arrays.
    /// The colors count should match the labels count.
    /// * Each color is for the form drawn at the same index.
    /// * A nil label will start a group.
    /// * A nil color will avoid drawing a form, and a clearColor will leave a space for the form.
    /// This will disable the feature that automatically calculates the legend labels and colors from the datasets.
    /// Call `resetLegendToAuto(...)` to re-enable automatic calculation, and then if needed - call `notifyDataSetChanged()` on the chart to make it refresh the data.
    open func setCustom(colors: [NSObject], labels: [NSObject])
    {
        if (colors.count != labels.count)
        {
            fatalError("ChartLegend:setCustom() - colors array and labels array need to be of same size")
        }
        
        self.labelsObjc = labels
        self.colorsObjc = colors
        _isLegendCustom = true
    }
}
