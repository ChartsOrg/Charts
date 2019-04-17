//
//  CustomBarChartXAxis.swift
//  medclinik.humagine.profile.crashlytics
//
//  Created by Oussama Ayed on 3/21/19.
//  Copyright © 2019 360medlink. All rights reserved.
//
import Foundation
import CoreGraphics
#if !os(OSX)
import UIKit
#endif

public class CustomCombinedBarChartXAxis : XAxisRenderer  {
  
    public var highlight:Highlight?
    
    public var indexXAxis:Int?
    
    public  init(viewPortHandler: ViewPortHandler, xAxis: XAxis?, transformer: Transformer?,indexXAxis:Int?) {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: transformer)
        if let indexXaxis = indexXAxis {
            self.indexXAxis = indexXaxis
        }
    }

    /// draws the x-labels on the specified y-position
    override public func drawLabels(context: CGContext, pos: CGFloat, anchor: CGPoint) {
        guard
            let xAxis = self.axis as? XAxis,
            let transformer = self.transformer
            else { return }
        
        #if os(OSX)
        let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        #else
        let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        #endif
        paraStyle.alignment = .left
        
        var labelAttrs: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: xAxis.labelFont,
                                                          NSAttributedString.Key.foregroundColor: xAxis.labelTextColor,
                                                          NSAttributedString.Key.paragraphStyle: paraStyle]
        let labelRotationAngleRadians = xAxis.labelRotationAngle.DEG2RAD
        
        let centeringEnabled = xAxis.isCenterAxisLabelsEnabled
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        var labelMaxSize = CGSize()
        
        
        
        if xAxis.isWordWrapEnabled
        {
            labelMaxSize.width = xAxis.wordWrapWidthPercent * valueToPixelMatrix.a
        }
        
        let entries = xAxis.entries
        
        for i in stride(from: 0, to: entries.count, by: 1)
        {
            
            
            if let index = self.indexXAxis ,(i == index){
                labelAttrs = [NSAttributedString.Key.font: NSUIFont(name: "Helvetica-Bold", size: 14)!,
                              NSAttributedString.Key.foregroundColor: NSUIColor(red:0.18, green:0.73, blue:0.27, alpha:1),
                              NSAttributedString.Key.paragraphStyle: paraStyle]
                
            }else{
                labelAttrs = [NSAttributedString.Key.font: xAxis.labelFont,
                              NSAttributedString.Key.foregroundColor: NSUIColor.black,
                              NSAttributedString.Key.paragraphStyle: paraStyle]
            }
            
            if centeringEnabled
            {
                position.x = CGFloat(xAxis.centeredEntries[i])+0.5
            }
            else
            {
                position.x = CGFloat(entries[i])+0.5
            }
            
            position.y = 0.0
            position = position.applying(valueToPixelMatrix)
            
            if viewPortHandler.isInBoundsX(position.x)
            {
                let label = xAxis.valueFormatter?.stringForValue(xAxis.entries[i], axis: xAxis) ?? ""
                
                let labelns = label as NSString
                
                if xAxis.isAvoidFirstLastClippingEnabled
                {
                    // avoid clipping of the last
                    if i == xAxis.entryCount - 1 && xAxis.entryCount > 1
                    {
                        let width = labelns.boundingRect(with: labelMaxSize, options: .usesLineFragmentOrigin, attributes: labelAttrs, context: nil).size.width
                        
                        if width > viewPortHandler.offsetRight * 2.0
                            && position.x + width > viewPortHandler.chartWidth
                        {
                            position.x -= width / 2.0
                        }
                    }
                    else if i == 0
                    { // avoid clipping of the first
                        let width = labelns.boundingRect(with: labelMaxSize, options: .usesLineFragmentOrigin, attributes: labelAttrs, context: nil).size.width
                        position.x += width / 2.0
                    }
                }
                
                drawLabel(context: context,
                          formattedLabel: label,
                          x: position.x+0.5,
                          y: pos,
                          attributes: labelAttrs,
                          constrainedToSize: labelMaxSize,
                          anchor: anchor,
                          angleRadians: labelRotationAngleRadians)
            }
        }
       
    }
    
    // Best position indices - minimum "n" without overlapping
    private func findBestPositions(positions: [CGPoint], widths: [CGFloat], margin: CGFloat) -> [Int] {
        var n = 1
        var overlap = true
        
        // finding "n"
        while n < widths.count && overlap {
            overlap = doesOverlap(n: n, positions: positions, widths: widths, margin: margin)
            if overlap {
                n += 1
            }
        }
        
        var newPositions = [Int]()
        var i = 0
        // create result indices
        while i < positions.count {
            newPositions.append(i)
            i += n
        }
        
        return newPositions
    }
    
    // returns whether drawing only n-th labels will casue overlapping
    private func doesOverlap(n: Int, positions: [CGPoint], widths: [CGFloat], margin: CGFloat) -> Bool {
        var i = 0
        var newPositions = [CGPoint]()
        var newWidths = [CGFloat]()
        
        // getting only n-th records
        while i < positions.count {
            newPositions.append(positions[i])
            newWidths.append(widths[i])
            i += n
        }
        
        // overlap with next label checking
        for j in 0...newPositions.count - 2 {
            if newPositions[j].x + newWidths[j] + margin > newPositions[j+1].x {
                return true
            }
        }
        
        return false
    }
   
}
