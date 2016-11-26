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
open class Legend: ComponentBase
{
    /// This property is deprecated - Use `horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.
    @available(*, deprecated: 1.0, message: "Use `horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.")
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
        /// Avoid drawing a form
        case none
        
        /// Do not draw the a form, but leave space for it
        case empty
        
        /// Use default (default dataset's form to the legend's form)
        case `default`
        
        /// Draw a square
        case square
        
        /// Draw a circle
        case circle
        
        /// Draw a horizontal line
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
    
    /// The legend entries array
    open var entries = [LegendEntry]()
    
    /// Entries that will be appended to the end of the auto calculated entries after calculating the legend.
    /// (if the legend has already been calculated, you will need to call notifyDataSetChanged() to let the changes take effect)
    open var extraEntries = [LegendEntry]()
    
    /// Are the legend labels/colors a custom value or auto calculated? If false, then it's auto, if true, then custom.
    /// 
    /// **default**: false (automatic legend)
    fileprivate var _isLegendCustom = false
    
    /// This property is deprecated - Use `horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.
    @available(*, deprecated: 1.0, message: "Use `horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.")
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

    /// The form/shape of the legend forms
    open var form = Form.square
    
    /// The size of the legend forms
    open var formSize = CGFloat(8.0)
    
    /// The line width for forms that consist of lines
    open var formLineWidth = CGFloat(3.0)
    
    /// Line dash configuration for shapes that consist of lines.
    ///
    /// This is how much (in pixels) into the dash pattern are we starting from.
    open var formLineDashPhase: CGFloat = 0.0
    
    /// Line dash configuration for shapes that consist of lines.
    ///
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    open var formLineDashLengths: [CGFloat]?
    
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
    
    public init(entries: [LegendEntry])
    {
        super.init()
        
        self.entries = entries
    }
    
    open func getMaximumEntrySize(withFont font: NSUIFont) -> CGSize
    {
        var maxW = CGFloat(0.0)
        var maxH = CGFloat(0.0)
        
        var maxFormSize: CGFloat = 0.0

        for entry in entries
        {
            let formSize = entry.formSize.isNaN ? self.formSize : entry.formSize
            if formSize > maxFormSize
            {
                maxFormSize = formSize
            }
            
            guard let label = entry.label
                else { continue }
            
            let size = (label as NSString!).size(attributes: [NSFontAttributeName: font])
            
            if size.width > maxW
            {
                maxW = size.width
            }
            if size.height > maxH
            {
                maxH = size.height
            }
        }
        
        return CGSize(
            width: maxW + maxFormSize + formToTextSpace,
            height: maxH
        )
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
    
    /// if this is set, then word wrapping the legend is enabled.
    open var isWordWrapEnabled: Bool { return wordWrapEnabled }

    /// The maximum relative size out of the whole chart view in percent.
    /// If the legend is to the right/left of the chart, then this affects the width of the legend.
    /// If the legend is to the top/bottom of the chart, then this affects the height of the legend.
    /// 
    /// **default**: 0.95 (95%)
    open var maxSizePercent: CGFloat = 0.95
    
    open func calculateDimensions(labelFont: NSUIFont, viewPortHandler: ViewPortHandler)
    {
        let maxEntrySize = getMaximumEntrySize(withFont: labelFont)
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
        case .vertical:
            
            var maxWidth = CGFloat(0.0)
            var width = CGFloat(0.0)
            var maxHeight = CGFloat(0.0)
            let labelLineHeight = labelFont.lineHeight
            
            var wasStacked = false
            
            for i in 0 ..< entryCount
            {
                let e = entries[i]
                let drawingForm = e.form != .none
                let formSize = e.formSize.isNaN ? defaultFormSize : e.formSize
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
                    let size = (label as NSString!).size(attributes: [NSFontAttributeName: labelFont])
                    
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
            
        case .horizontal:
            
            let labelLineHeight = labelFont.lineHeight
            
            let contentWidth: CGFloat = viewPortHandler.contentWidth * maxSizePercent
            
            // Prepare arrays for calculated layout
            if calculatedLabelSizes.count != entryCount
            {
                calculatedLabelSizes = [CGSize](repeating: CGSize(), count: entryCount)
            }
            
            if calculatedLabelBreakPoints.count != entryCount
            {
                calculatedLabelBreakPoints = [Bool](repeating: false, count: entryCount)
            }
            
            calculatedLineSizes.removeAll(keepingCapacity: true)
            
            // Start calculating layout
            
            let labelAttrs = [NSFontAttributeName: labelFont]
            var maxLineWidth: CGFloat = 0.0
            var currentLineWidth: CGFloat = 0.0
            var requiredWidth: CGFloat = 0.0
            var stackedStartIndex: Int = -1
            
            for i in 0 ..< entryCount
            {
                let e = entries[i]
                let drawingForm = e.form != .none
                let label = e.label
                
                calculatedLabelBreakPoints[i] = false
                
                if stackedStartIndex == -1
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
                    calculatedLabelSizes[i] = (label as NSString!).size(attributes: labelAttrs)
                    requiredWidth += drawingForm ? formToTextSpace + formSize : 0.0
                    requiredWidth += calculatedLabelSizes[i].width
                }
                else
                {
                    calculatedLabelSizes[i] = CGSize()
                    requiredWidth += drawingForm ? formSize : 0.0
                    
                    if stackedStartIndex == -1
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
                    
                    if i == entryCount - 1
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
    open func setCustom(entries: [LegendEntry])
    {
        self.entries = entries
        _isLegendCustom = true
    }
    
    /// Calling this will disable the custom legend entries (set by `setLegend(...)`). Instead, the entries will again be calculated automatically (after `notifyDataSetChanged()` is called).
    open func resetCustom()
    {
        _isLegendCustom = false
    }
    
    /// **default**: false (automatic legend)
    /// - returns: `true` if a custom legend entries has been set
    open var isLegendCustom: Bool
    {
        return _isLegendCustom
    }
    
    // MARK: - Deprecated stuff
    
    /// This property is deprecated - Use `entries`.
    @available(*, deprecated: 1.0, message: "Use `entries`.")
    open var colors: [NSUIColor?]
    {
        get
        {
            var old = [NSUIColor?]()
            for e in entries
            {
                old.append(
                    e.form == .none ? nil :
                        (e.form == .empty ? NSUIColor.clear :
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
                    entries[i].form = .none
                }
                else if newValue[i] == NSUIColor.clear
                {
                    entries[i].form = .empty
                }
            }
        }
    }
    
    /// This property is deprecated - Use `entries`.
    @available(*, deprecated: 1.0, message: "Use `entries`.")
    open var labels: [String?]
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
    @available(*, deprecated: 1.0, message: "Use `extraEntries`.")
    open var extraColors: [NSUIColor?]
    {
        get
        {
            var old = [NSUIColor?]()
            for e in extraEntries
            {
                old.append(
                    e.form == .none ? nil :
                        (e.form == .empty ? NSUIColor.clear :
                            e.formColor))
            }
            return old
        }
        set
        {
            if extraEntries.count > newValue.count
            {
                extraEntries.removeSubrange(newValue.count ..< extraEntries.count)
            }
            
            for i in 0 ..< newValue.count
            {
                extraEntries[i].formColor = newValue[i]
                
                if newValue[i] == nil
                {
                    extraEntries[i].form = .none
                }
                else if newValue[i] == NSUIColor.clear
                {
                    extraEntries[i].form = .empty
                }
            }
        }
    }
    
    /// This property is deprecated - Use `extraEntries`.
    @available(*, deprecated: 1.0, message: "Use `extraEntries`.")
    open var extraLabels: [String?]
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
                extraEntries.removeSubrange(newValue.count ..< extraEntries.count)
            }
            
            for i in 0 ..< newValue.count
            {
                extraEntries[i].label = newValue[i]
            }
        }
    }
    
    /// This constructor is deprecated - Use `init(entries:)`
    @available(*, deprecated: 1.0, message: "Use `init(entries:)`")
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
                entry.form = .none
            }
            else if entry.formColor == NSUIColor.clear
            {
                entry.form = .empty
            }
            
            entries.append(entry)
        }
        
        self.entries = entries
    }
    
    /// This constructor is deprecated - Use `init(entries:)`
    @available(*, deprecated: 1.0, message: "Use `init(entries:)`")
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
                entry.form = .none
            }
            else if entry.formColor == NSUIColor.clear
            {
                entry.form = .empty
            }
            
            entries.append(entry)
        }
        
        self.entries = entries
    }
    
    /// This property is deprecated - Use `extraEntries`
    @available(*, deprecated: 1.0, message: "Use `extraEntries`")
    open var extraColorsObjc: [NSObject]
    {
        return ChartUtils.bridgedObjCGetNSUIColorArray(swift: extraColors)
    }
    
    /// This property is deprecated - Use `extraLabels`
    @available(*, deprecated: 1.0, message: "Use `extraLabels`")
    open var extraLabelsObjc: [NSObject]
    {
        return ChartUtils.bridgedObjCGetStringArray(swift: extraLabels)
    }
    
    /// This property is deprecated - Use `colors`
    @available(*, deprecated: 1.0, message: "Use `colors`")
    open var colorsObjc: [NSObject]
    {
        get { return ChartUtils.bridgedObjCGetNSUIColorArray(swift: colors) }
        set { self.colors = ChartUtils.bridgedObjCGetNSUIColorArray(objc: newValue) }
    }
    
    /// This property is deprecated - Use `labels`
    @available(*, deprecated: 1.0, message: "Use `labels`")
    open var labelsObjc: [NSObject]
    {
        get { return ChartUtils.bridgedObjCGetStringArray(swift: labels) }
        set { self.labels = ChartUtils.bridgedObjCGetStringArray(objc: newValue) }
    }
    
    /// This function is deprecated - Use `entries`
    @available(*, deprecated: 1.0, message: "Use `entries`")
    open func getLabel(_ index: Int) -> String?
    {
        return entries[index].label
    }
    
    /// This function is deprecated - Use `Use `extra(entries:)`
    @available(*, deprecated: 1.0, message: "Use `extra(entries:)`")
    open func setExtra(colors: [NSUIColor?], labels: [String?])
    {
        var entries = [LegendEntry]()
        
        for i in 0 ..< min(colors.count, labels.count)
        {
            let entry = LegendEntry()
            entry.formColor = colors[i]
            entry.label = labels[i]
            
            if entry.formColor == nil
            {
                entry.form = .none
            }
            else if entry.formColor == NSUIColor.clear
            {
                entry.form = .empty
            }
            
            entries.append(entry)
        }
        
        self.extraEntries = entries
    }
    
    /// This function is deprecated - Use `Use `extra(entries:)`
    @available(*, deprecated: 1.0, message: "Use `extra(entries:)`")
    open func setExtra(colors: [NSObject], labels: [NSObject])
    {
        var entries = [LegendEntry]()
        
        for i in 0 ..< min(colors.count, labels.count)
        {
            let entry = LegendEntry()
            entry.formColor = colors[i] as? NSUIColor
            entry.label = labels[i] as? String
            
            if entry.formColor == nil
            {
                entry.form = .none
            }
            else if entry.formColor == NSUIColor.clear
            {
                entry.form = .empty
            }
            
            entries.append(entry)
        }
        
        self.extraEntries = entries
    }
    
    /// This function is deprecated - Use `Use `setCustom(entries:)`
    @available(*, deprecated: 1.0, message: "Use `setCustom(entries:)`")
    open func setCustom(colors: [NSUIColor?], labels: [String?])
    {
        var entries = [LegendEntry]()
        
        for i in 0 ..< min(colors.count, labels.count)
        {
            let entry = LegendEntry()
            entry.formColor = colors[i]
            entry.label = labels[i]
            
            if entry.formColor == nil
            {
                entry.form = .none
            }
            else if entry.formColor == NSUIColor.clear
            {
                entry.form = .empty
            }
            
            entries.append(entry)
        }
        
        setCustom(entries: entries)
    }
    
    /// This function is deprecated - Use `Use `setCustom(entries:)`
    @available(*, deprecated: 1.0, message: "Use `setCustom(entries:)`")
    open func setCustom(colors: [NSObject], labels: [NSObject])
    {
        var entries = [LegendEntry]()
        
        for i in 0 ..< min(colors.count, labels.count)
        {
            let entry = LegendEntry()
            entry.formColor = colors[i] as? NSUIColor
            entry.label = labels[i] as? String
            
            if entry.formColor == nil
            {
                entry.form = .none
            }
            else if entry.formColor == NSUIColor.clear
            {
                entry.form = .empty
            }
            
            entries.append(entry)
        }
        
        setCustom(entries: entries)
    }
}
