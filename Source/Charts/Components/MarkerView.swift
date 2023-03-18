//
//  ChartMarkerView.swift
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

#if canImport(AppKit)
import AppKit
#endif

@objc(ChartMarkerView)
open class MarkerView: NSUIView, Marker
{
    open var offset: CGPoint = CGPoint()
    
    @objc open weak var chartView: ChartViewBase? {
        didSet {
            didAddToChart(chartView)
        }
    }
    
    open func offsetForDrawing(atPoint point: CGPoint) -> CGPoint
    {
        guard let chart = chartView else { return self.offset }
        
        var offset = self.offset
        
        let width = self.bounds.size.width
        let height = self.bounds.size.height
        
        if point.x + offset.x < 0.0
        {
            offset.x = -point.x
        }
        else if point.x + width + offset.x > chart.bounds.size.width
        {
            offset.x = chart.bounds.size.width - point.x - width
        }
        
        if point.y + offset.y < 0
        {
            offset.y = -point.y
        }
        else if point.y + height + offset.y > chart.bounds.size.height
        {
            offset.y = chart.bounds.size.height - point.y - height
        }
        
        return offset
    }
    
    open func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        // Do nothing here...
    }
    
    open func draw(context: CGContext, point: CGPoint)
    {
        let offset = self.offsetForDrawing(atPoint: point)
        
        context.saveGState()
        context.translateBy(x: point.x + offset.x,
                              y: point.y + offset.y)
        NSUIGraphicsPushContext(context)
        self.nsuiLayer?.render(in: context)
        NSUIGraphicsPopContext()
        context.restoreGState()
    }
    
    @objc
    open class func viewFromXib(in bundle: Bundle = .main) -> Self?
    {
        #if !os(OSX)
        
        return bundle.loadNibNamed(
            String(describing: self),
            owner: nil,
            options: nil)?
            .compactMap { $0 as? Self }
            .first
        #else
        
        var loadedObjects: NSArray? = NSArray()
        
        if bundle.loadNibNamed(
            NSNib.Name(String(describing: self)),
            owner: nil,
            topLevelObjects: &loadedObjects),
           let view = loadedObjects?.compactMap({ $0 as? Self }).first
        {
            view.wantsLayer = true
            return view
        }
        
        return nil
        #endif
    }
    
    @objc
    open func didAddToChart(_ chartView: ChartViewBase?) {
        #if os(OSX)
        removeFromSuperview()
        
        // Need to add MarkerView to a view in order to allow it to render out of visible area
        guard let chartView else { return }

        var parentView: NSView = chartView
        while let grandparentView = parentView.superview {
            parentView = grandparentView
        }
        parentView.addSubview(self)
        
        // Constrain MarkerView to off-screen, since it's only being used to render in `draw()` function
        // and not to display directly as NSView
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: 100.0),
            topAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 100.0)
        ])

        #endif
    }
}
