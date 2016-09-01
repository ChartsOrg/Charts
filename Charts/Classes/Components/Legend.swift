//
//  Legend.swift
//  Charts
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

@objc(ChartLegend)
public class Legend: ComponentBase
{
    /// This property is deprecated - Use `position`, `horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.
    @available(*, deprecated=1.0, message="Use `position`, `horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.")
    @objc(ChartLegendPosition)
    public enum Position: Int
    {
        case RightOfChart
        case RightOfChartCenter
        case RightOfChartInside
        case LeftOfChart
        case LeftOfChartCenter
        case LeftOfChartInside
        case BelowChartLeft
        case BelowChartRight
        case BelowChartCenter
        case AboveChartLeft
        case AboveChartRight
        case AboveChartCenter
        case PiechartCenter
    }
    
    @objc(ChartLegendForm)
    public enum Form: Int
    {
        /// Avoid drawing a form
        case None
        
        /// Do not draw the a form, but leave space for it
        case Empty
        
        /// Use default (default dataset's form to the legend's form)
        case Default
        
        /// Draw a square
        case Square
        
        /// Draw a circle
        case Circle
        
        /// Draw a horizontal line
        case Line
    }
    
    @objc(ChartLegendHorizontalAlignment)
    public enum HorizontalAlignment: Int
    {
        case Left
        case Center
        case Right
    }
    
    @objc(ChartLegendVerticalAlignment)
    public enum VerticalAlignment: Int
    {
        case Top
        case Center
        case Bottom
    }
    
    @objc(ChartLegendOrientation)
    public enum Orientation: Int
    {
        case Horizontal
        case Vertical
    }
    
    @objc(ChartLegendDirection)
    public enum Direction: Int
    {
        case LeftToRight
        case RightToLeft
    }
    
    /// The legend entries array
    public var entries = [LegendEntry]()
    
    /// Entries that will be appended to the end of the auto calculated entries after calculating the legend.
    /// (if the legend has already been calculated, you will need to call notifyDataSetChanged() to let the changes take effect)
    public var extraEntries = [LegendEntry]()
    
    /// Are the legend labels/colors a custom value or auto calculated? If false, then it's auto, if true, then custom.
    /// 
    /// **default**: false (automatic legend)
    private var _isLegendCustom = false
    
    /// This property is deprecated - Use `position`, `horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.
    @available(*, deprecated=1.0, message="Use `position`, `horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.")
    public var position: Position
    {
        get
        {
            if orientation == .Vertical && horizontalAlignment == .Center && verticalAlignment == .Center
            {
                return .PiechartCenter
            }
            else if orientation == .Horizontal
            {
                if verticalAlignment == .Top
                {
                    return horizontalAlignment == .Left ? .AboveChartLeft : (horizontalAlignment == .Right ? .AboveChartRight : .AboveChartCenter)
                }
                else
                {
                    return horizontalAlignment == .Left ? .BelowChartLeft : (horizontalAlignment == .Right ? .BelowChartRight : .BelowChartCenter)
                }
            }
            else
            {
                if horizontalAlignment == .Left
                {
                    return verticalAlignment == .Top && drawInside ? .LeftOfChartInside : (verticalAlignment == .Center ? .LeftOfChartCenter : .LeftOfChart)
                }
                else
                {
                    return verticalAlignment == .Top && drawInside ? .RightOfChartInside : (verticalAlignment == .Center ? .RightOfChartCenter : .RightOfChart)
                }
            }
        }
        set
        {
            switch newValue
            {
            case .LeftOfChart: fallthrough
            case .LeftOfChartInside: fallthrough
            case .LeftOfChartCenter:
                horizontalAlignment = .Left
                verticalAlignment = newValue == .LeftOfChartCenter ? .Center : .Top
                orientation = .Vertical
                
            case .RightOfChart: fallthrough
            case .RightOfChartInside: fallthrough
            case .RightOfChartCenter:
                horizontalAlignment = .Right
                verticalAlignment = newValue == .RightOfChartCenter ? .Center : .Top
                orientation = .Vertical
                
            case .AboveChartLeft: fallthrough
            case .AboveChartCenter: fallthrough
            case .AboveChartRight:
                horizontalAlignment = newValue == .AboveChartLeft ? .Left : (newValue == .AboveChartRight ? .Right : .Center)
                verticalAlignment = .Top
                orientation = .Horizontal
                
            case .BelowChartLeft: fallthrough
            case .BelowChartCenter: fallthrough
            case .BelowChartRight:
                horizontalAlignment = newValue == .BelowChartLeft ? .Left : (newValue == .BelowChartRight ? .Right : .Center)
                verticalAlignment = .Bottom
                orientation = .Horizontal
                
            case .PiechartCenter:
                horizontalAlignment = .Center
                verticalAlignment = .Center
                orientation = .Vertical
            }
            
            drawInside = newValue == .LeftOfChartInside || newValue == .RightOfChartInside
        }
    }
    
    /// The horizontal alignment of the legend
    public var horizontalAlignment: HorizontalAlignment = HorizontalAlignment.Left
    
    /// The vertical alignment of the legend
    public var verticalAlignment: VerticalAlignment = VerticalAlignment.Bottom
    
    /// The orientation of the legend
    public var orientation: Orientation = Orientation.Horizontal
    
    /// Flag indicating whether the legend will draw inside the chart or outside
    public var drawInside: Bool = false
    
    /// Flag indicating whether the legend will draw inside the chart or outside
    public var isDrawInsideEnabled: Bool { return drawInside }
    
    /// The text direction of the legend
    public var direction: Direction = Direction.LeftToRight

    public var font: NSUIFont = NSUIFont.systemFontOfSize(10.0)
    public var textColor = NSUIColor.blackColor()

    /// The form/shape of the legend forms
    public var form = Form.Square
    
    /// The size of the legend forms
    public var formSize = CGFloat(8.0)
    
    /// The line width for forms that consist of lines
    public var formLineWidth = CGFloat(3.0)
    
    /// Line dash configuration for shapes that consist of lines.
    ///
    /// This is how much (in pixels) into the dash pattern are we starting from.
    public var formLineDashPhase: CGFloat = 0.0
    
    /// Line dash configuration for shapes that consist of lines.
    ///
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    public var formLineDashLengths: [CGFloat]?
    
    public var xEntrySpace = CGFloat(6.0)
    public var yEntrySpace = CGFloat(0.0)
    public var formToTextSpace = CGFloat(5.0)
    public var stackSpace = CGFloat(3.0)
    
    public var calculatedLabelSizes = [CGSize]()
    public var calculatedLabelBreakPoints = [Bool]()
    public var calculatedLineSizes = [CGSize]()
    
    public override init()
    {
        super.init()
        
        self.xOffset = 5.0
        self.yOffset = 3.0
    }
    
    public init(entries: [LegendEntry])
    {
        super.init()
        
        self.entries = entries
    }
    
    public func getMaximumEntrySize(font: NSUIFont) -> CGSize
    {
        var maxW = CGFloat(0.0)
        var maxH = CGFloat(0.0)
        
        var maxFormSize: CGFloat = 0.0

        for entry in entries
        {
            let formSize = isnan(entry.formSize) ? self.formSize : entry.formSize
            if formSize > maxFormSize
            {
                maxFormSize = formSize
            }
            
            guard let label = entry.label
                else { continue }
            
            let size = (label as NSString!).sizeWithAttributes([NSFontAttributeName: font])
            
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
            width: maxW + maxFormSize + formToTextSpace,
            height: maxH
        )
    }

    public var neededWidth = CGFloat(0.0)
    public var neededHeight = CGFloat(0.0)
    public var textWidthMax = CGFloat(0.0)
    public var textHeightMax = CGFloat(0.0)
    
    /// flag that indicates if word wrapping is enabled
    /// this is currently supported only for `orientation == Horizontal`.
    /// you may want to set maxSizePercent when word wrapping, to set the point where the text wraps.
    /// 
    /// **default**: false
    public var wordWrapEnabled = true
    
    /// if this is set, then word wrapping the legend is enabled.
    public var isWordWrapEnabled: Bool { return wordWrapEnabled }

    /// The maximum relative size out of the whole chart view in percent.
    /// If the legend is to the right/left of the chart, then this affects the width of the legend.
    /// If the legend is to the top/bottom of the chart, then this affects the height of the legend.
    /// 
    /// **default**: 0.95 (95%)
    public var maxSizePercent: CGFloat = 0.95
    
    public func calculateDimensions(labelFont labelFont: NSUIFont, viewPortHandler: ViewPortHandler)
    {
        let maxEntrySize = getMaximumEntrySize(labelFont)
        let defaultFormSize = self.formSize
        let stackSpace = self.stackSpace
        let formToTextSpace = self.formToTextSpace
        let xEntrySpace = self.xEntrySpace
        let yEntrySpace = self.yEntrySpace
        let wordWrapEnabled = self.wordWrapEnabled
        let entries = self.entries
        let entryCount = entries.count
        
        textWidthMax = maxEntrySize.width
        textHeightMax = maxEntrySize.height
        
        switch orientation
        {
        case .Vertical:
            
            var maxWidth = CGFloat(0.0)
            var width = CGFloat(0.0)
            var maxHeight = CGFloat(0.0)
            let labelLineHeight = labelFont.lineHeight
            
            var wasStacked = false
            
            for i in 0 ..< entryCount
            {
                let e = entries[i]
                let drawingForm = e.form != .None
                let formSize = isnan(e.formSize) ? defaultFormSize : e.formSize
                let label = e.label
                
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
                
                if label != nil
                {
                    let size = (label as NSString!).sizeWithAttributes([NSFontAttributeName: labelFont])
                    
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
                    
                    if i < entryCount - 1
                    {
                        maxHeight += labelLineHeight + yEntrySpace
                    }
                }
                else
                {
                    wasStacked = true
                    width += formSize
                    
                    if i < entryCount - 1
                    {
                        width += stackSpace
                    }
                }
                
                maxWidth = max(maxWidth, width)
            }
            
            neededWidth = maxWidth
            neededHeight = maxHeight
            
        case .Horizontal:
            
            let labelLineHeight = labelFont.lineHeight
            
            let contentWidth: CGFloat = viewPortHandler.contentWidth * maxSizePercent
            
            // Prepare arrays for calculated layout
            if (calculatedLabelSizes.count != entryCount)
            {
                calculatedLabelSizes = [CGSize](count: entryCount, repeatedValue: CGSize())
            }
            
            if (calculatedLabelBreakPoints.count != entryCount)
            {
                calculatedLabelBreakPoints = [Bool](count: entryCount, repeatedValue: false)
            }
            
            calculatedLineSizes.removeAll(keepCapacity: true)
            
            // Start calculating layout
            
            let labelAttrs = [NSFontAttributeName: labelFont]
            var maxLineWidth: CGFloat = 0.0
            var currentLineWidth: CGFloat = 0.0
            var requiredWidth: CGFloat = 0.0
            var stackedStartIndex: Int = -1
            
            for i in 0 ..< entryCount
            {
                let e = entries[i]
                let drawingForm = e.form != .None
                let label = e.label
                
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
                if label != nil
                {
                    calculatedLabelSizes[i] = (label as NSString!).sizeWithAttributes(labelAttrs)
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
                
                if label != nil || i == entryCount - 1
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
                    
                    if (i == entryCount - 1)
                    { // Add last line size to array
                        calculatedLineSizes.append(CGSize(width: currentLineWidth, height: labelLineHeight))
                        maxLineWidth = max(maxLineWidth, currentLineWidth)
                    }
                }
                
                stackedStartIndex = label != nil ? -1 : stackedStartIndex
            }
            
            neededWidth = maxLineWidth
            neededHeight = labelLineHeight * CGFloat(calculatedLineSizes.count) +
                yEntrySpace * CGFloat(calculatedLineSizes.count == 0 ? 0 : (calculatedLineSizes.count - 1))
        }
        
        neededWidth += xOffset
        neededHeight += yOffset
    }
    
    /// MARK: - Custom legend
    
    /// Sets a custom legend's entries array.
    /// * A nil label will start a group.
    /// This will disable the feature that automatically calculates the legend entries from the datasets.
    /// Call `resetCustom(...)` to re-enable automatic calculation (and then `notifyDataSetChanged()` is needed).
    public func setCustom(entries entries: [LegendEntry])
    {
        self.entries = entries
        _isLegendCustom = true
    }
    
    /// Calling this will disable the custom legend entries (set by `setLegend(...)`). Instead, the entries will again be calculated automatically (after `notifyDataSetChanged()` is called).
    public func resetCustom()
    {
        _isLegendCustom = false
    }
    
    /// **default**: false (automatic legend)
    /// - returns: `true` if a custom legend entries has been set
    public var isLegendCustom: Bool
    {
        return _isLegendCustom
    }
    
    // MARK: - Deprecated stuff
    
    /// This property is deprecated - Use `entries`.
    @available(*, deprecated=1.0, message="Use `entries`.")
    public var colors: [NSUIColor?]
    {
        get
        {
            var old = [NSUIColor?]()
            for e in entries
            {
                old.append(
                    e.form == .None ? nil :
                        (e.form == .Empty ? NSUIColor.clearColor() :
                        e.formColor))
            }
            return old
        }
        set
        {
            for i in 0 ..< newValue.count
            {
                if entries.count <= i
                {
                    entries.append(LegendEntry())
                }
                entries[i].formColor = newValue[i]
                
                if newValue[i] == nil
                {
                    entries[i].form = .None
                }
                else if newValue[i] == NSUIColor.clearColor()
                {
                    entries[i].form = .Empty
                }
            }
        }
    }
    
    /// This property is deprecated - Use `entries`.
    @available(*, deprecated=1.0, message="Use `entries`.")
    public var labels: [String?]
    {
        get
        {
            var old = [String?]()
            for e in entries
            {
                old.append(e.label)
            }
            return old
        }
        set
        {
            for i in 0 ..< newValue.count
            {
                if entries.count <= i
                {
                    entries.append(LegendEntry())
                }
                entries[i].label = newValue[i]
            }
        }
    }
    
    
    /// This property is deprecated - Use `extraEntries`.
    @available(*, deprecated=1.0, message="Use `extraEntries`.")
    public var extraColors: [NSUIColor?]
    {
        get
        {
            var old = [NSUIColor?]()
            for e in extraEntries
            {
                old.append(
                    e.form == .None ? nil :
                        (e.form == .Empty ? NSUIColor.clearColor() :
                            e.formColor))
            }
            return old
        }
        set
        {
            if extraEntries.count > newValue.count
            {
                extraEntries.removeRange(newValue.count ..< extraEntries.count)
            }
            
            for i in 0 ..< newValue.count
            {
                extraEntries[i].formColor = newValue[i]
                
                if newValue[i] == nil
                {
                    extraEntries[i].form = .None
                }
                else if newValue[i] == NSUIColor.clearColor()
                {
                    extraEntries[i].form = .Empty
                }
            }
        }
    }
    
    /// This property is deprecated - Use `extraEntries`.
    @available(*, deprecated=1.0, message="Use `extraEntries`.")
    public var extraLabels: [String?]
    {
        get
        {
            var old = [String?]()
            for e in extraEntries
            {
                old.append(e.label)
            }
            return old
        }
        set
        {
            if extraEntries.count > newValue.count
            {
                extraEntries.removeRange(newValue.count ..< extraEntries.count)
            }
            
            for i in 0 ..< newValue.count
            {
                extraEntries[i].label = newValue[i]
            }
        }
    }
    
    /// This constructor is deprecated - Use `init(entries:)`
    @available(*, deprecated=1.0, message="Use `init(entries:)`")
    public init(colors: [NSUIColor?], labels: [String?])
    {
        super.init()
        
        var entries = [LegendEntry]()
        
        for i in 0 ..< min(colors.count, labels.count)
        {
            let entry = LegendEntry()
            entry.formColor = colors[i]
            entry.label = labels[i]
            
            if entry.formColor == nil
            {
                entry.form = .None
            }
            else if entry.formColor == NSUIColor.clearColor()
            {
                entry.form = .Empty
            }
            
            entries.append(entry)
        }
        
        self.entries = entries
    }
    
    /// This constructor is deprecated - Use `init(entries:)`
    @available(*, deprecated=1.0, message="Use `init(entries:)`")
    public init(colors: [NSObject], labels: [NSObject])
    {
        super.init()
        
        var entries = [LegendEntry]()
        
        for i in 0 ..< min(colors.count, labels.count)
        {
            let entry = LegendEntry()
            entry.formColor = colors[i] as? NSUIColor
            entry.label = labels[i] as? String
            
            if entry.formColor == nil
            {
                entry.form = .None
            }
            else if entry.formColor == NSUIColor.clearColor()
            {
                entry.form = .Empty
            }
            
            entries.append(entry)
        }
        
        self.entries = entries
    }
    
    /// This property is deprecated - Use `extraEntries`
    @available(*, deprecated=1.0, message="Use `extraEntries`")
    public var extraColorsObjc: [NSObject]
    {
        return ChartUtils.bridgedObjCGetNSUIColorArray(swift: extraColors)
    }
    
    /// This property is deprecated - Use `extraLabels`
    @available(*, deprecated=1.0, message="Use `extraLabels`")
    public var extraLabelsObjc: [NSObject]
    {
        return ChartUtils.bridgedObjCGetStringArray(swift: extraLabels)
    }
    
    /// This property is deprecated - Use `colors`
    @available(*, deprecated=1.0, message="Use `colors`")
    public var colorsObjc: [NSObject]
    {
        get { return ChartUtils.bridgedObjCGetNSUIColorArray(swift: colors) }
        set { self.colors = ChartUtils.bridgedObjCGetNSUIColorArray(objc: newValue) }
    }
    
    /// This property is deprecated - Use `labels`
    @available(*, deprecated=1.0, message="Use `labels`")
    public var labelsObjc: [NSObject]
    {
        get { return ChartUtils.bridgedObjCGetStringArray(swift: labels) }
        set { self.labels = ChartUtils.bridgedObjCGetStringArray(objc: newValue) }
    }
    
    /// This function is deprecated - Use `entries`
    @available(*, deprecated=1.0, message="Use `entries`")
    public func getLabel(index: Int) -> String?
    {
        return entries[index].label
    }
    
    /// This function is deprecated - Use `Use `extra(entries:)`
    @available(*, deprecated=1.0, message="Use `extra(entries:)`")
    public func setExtra(colors colors: [NSUIColor?], labels: [String?])
    {
        var entries = [LegendEntry]()
        
        for i in 0 ..< min(colors.count, labels.count)
        {
            let entry = LegendEntry()
            entry.formColor = colors[i]
            entry.label = labels[i]
            
            if entry.formColor == nil
            {
                entry.form = .None
            }
            else if entry.formColor == NSUIColor.clearColor()
            {
                entry.form = .Empty
            }
            
            entries.append(entry)
        }
        
        self.extraEntries = entries
    }
    
    /// This function is deprecated - Use `Use `extra(entries:)`
    @available(*, deprecated=1.0, message="Use `extra(entries:)`")
    public func setExtra(colors colors: [NSObject], labels: [NSObject])
    {
        var entries = [LegendEntry]()
        
        for i in 0 ..< min(colors.count, labels.count)
        {
            let entry = LegendEntry()
            entry.formColor = colors[i] as? NSUIColor
            entry.label = labels[i] as? String
            
            if entry.formColor == nil
            {
                entry.form = .None
            }
            else if entry.formColor == NSUIColor.clearColor()
            {
                entry.form = .Empty
            }
            
            entries.append(entry)
        }
        
        self.extraEntries = entries
    }
    
    /// This function is deprecated - Use `Use `setCustom(entries:)`
    @available(*, deprecated=1.0, message="Use `setCustom(entries:)`")
    public func setCustom(colors colors: [NSUIColor?], labels: [String?])
    {
        var entries = [LegendEntry]()
        
        for i in 0 ..< min(colors.count, labels.count)
        {
            let entry = LegendEntry()
            entry.formColor = colors[i]
            entry.label = labels[i]
            
            if entry.formColor == nil
            {
                entry.form = .None
            }
            else if entry.formColor == NSUIColor.clearColor()
            {
                entry.form = .Empty
            }
            
            entries.append(entry)
        }
        
        setCustom(entries: entries)
    }
    
    /// This function is deprecated - Use `Use `setCustom(entries:)`
    @available(*, deprecated=1.0, message="Use `setCustom(entries:)`")
    public func setCustom(colors colors: [NSObject], labels: [NSObject])
    {
        var entries = [LegendEntry]()
        
        for i in 0 ..< min(colors.count, labels.count)
        {
            let entry = LegendEntry()
            entry.formColor = colors[i] as? NSUIColor
            entry.label = labels[i] as? String
            
            if entry.formColor == nil
            {
                entry.form = .None
            }
            else if entry.formColor == NSUIColor.clearColor()
            {
                entry.form = .Empty
            }
            
            entries.append(entry)
        }
        
        setCustom(entries: entries)
    }
}
