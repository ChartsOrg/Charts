//
//  IGearChartDataSet
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

@objc
public protocol IGearChartDataSet: IChartDataSet
{
    // MARK: - Styling functions and accessors
    
    /// indicates the selection distance of a pie slice
    var selectionShift: CGFloat { get set }
    
    var xValuePosition: GearChartDataSet.ValuePosition { get set }
    var yValuePosition: GearChartDataSet.ValuePosition { get set }
    
    /// When valuePosition is OutsideSlice, indicates line color
    var valueLineColor: NSUIColor? { get set }
    
    /// When valuePosition is OutsideSlice, indicates line width
    var valueLineWidth: CGFloat { get set }
    
    /// When valuePosition is OutsideSlice, indicates offset as percentage out of the slice size
    var valueLinePart1OffsetPercentage: CGFloat { get set }
    
    /// When valuePosition is OutsideSlice, indicates length of first half of the line
    var valueLinePart1Length: CGFloat { get set }
    
    /// When valuePosition is OutsideSlice, indicates length of second half of the line
    var valueLinePart2Length: CGFloat { get set }
    
    /// When valuePosition is OutsideSlice, this allows variable line length
    var valueLineVariableLength: Bool { get set }
    
    /// the font for the slice-text labels
    var entryLabelFont: NSUIFont? { get set }
    
    /// the color for the slice-text labels
    var entryLabelColor: NSUIColor? { get set }
    
    /// the color of the background gear
    var bgGearColor: UIColor? { get set }
    
    /// the color of the gear
    var gearColor: UIColor? { get set }
    
    /// the gear line width
    var gearLineWidth: CGFloat { get set }
}
