//
//  CustomDrawChartDataSetProtocol.swift
//  Charts
//
//  Created by JustLee on 2021/4/1.
//

import UIKit

///custom graphics type
@objc public enum CustomGraphicsDrawType: Int
{
    case lineSegment = 0
    case threeWaves
    case rectangle
    case lineHorizontal
    case fibonacciPeriod
}

/// graphics location path type
public enum CustomGraphicsPositionType: Int
{
    case singleLine
    case extendLine
    case multiLines
    case closedGraphics
}


extension CustomGraphicsDrawType
{
    var calculatePathType: CustomGraphicsPositionType
    {
        switch self {
           
        case .lineSegment:
            return .singleLine
            
        case .threeWaves:
            return .multiLines
            
        case .lineHorizontal:
            return .extendLine
            
        case .rectangle:
            return .closedGraphics
            
        case .fibonacciPeriod:
            return .multiLines
        }
    }

    ///the point count with basic graphics need
    var completeRequiredPointCount: Int
    {
        switch self {
        case .lineSegment:
            return 2
        case .threeWaves:
            return 4
        case .rectangle:
            return 2
        case .lineHorizontal:
            return 1
        case .fibonacciPeriod:
            return 2
        }
    }
    
    ///some graphics need supply point, as the rectangle need 2 point, but has 4 in totally
    var needSupplyGraphicsPoint: Bool
    {
        switch self {
        case .lineSegment, .threeWaves, .fibonacciPeriod, .lineHorizontal:
            return false
        case .rectangle:
            return true
        default:
            return false
        }
    }
}

/// some function for drawing
public protocol CustomDrawChartDataSetDrawingProtocol
{
    /// the entry count is equal to the remaining point
    var dataSetCompletedCustomDraw: Bool { get }
    
    ///supply point with out basic entry point, such as rectangle need fill 2 extra entry
    func supplyGraphicsRemainingPoints()
    
    ///update the whole graphics with move a single entry
    func correctGraphicsOtherPoints(entry: CustomDrawChartDataEntry)
    
    /// the surplus point with basic graphics need
    var remainingPointCount: Int { get }
    
    var finished: Bool { get }
}

/// locate the graphics with touch point, calculate whether the touch point is in the path
public protocol CustomDrawChartDataSetLocationProtocol
{
    /// the minimum error percent scale with screen y range
    var minimumYRangeErrorScale: CGFloat { get }
    
    /// the graphics location path width
    var graphicsPathWidth: CGFloat { get }
    
    /// locate dataset or entry
    /// - Parameters:
    ///   - touchPoint: touchPoint description
    ///   - yRange: you can set the min error distance scale
    func locateTouchEntry(touchPoint: CGPoint, yRange: CGFloat) -> CustomDrawChartDataEntry?
    
    /// calculate whether the touch point is in graphics path
    /// - Parameters:
    ///   - touchPoint: touchPoint
    func calculatePositionInGraphics(touchPoint: CGPoint) -> Bool
    
    /// generate a bezier path through points
    /// - Parameter points: points
    func appendClosedGraphicsPath(points: [CGPoint])
    
    /// generate a line bezier path through points
    /// - Parameters:
    ///   - points: points
    func appendSingleLinePath(points: [CGPoint])
    
    /// clear
    func clearGraphicsPath()
}

/// moving
public protocol CustomDrawChartDataSetMoveProtocol
{
    /// moving the whole graphics
    /// - Parameters:
    ///   - translation: CGPoint(x distance, y distance)
    func totalGraphicsMove(translation: CGPoint)
    
    /// moving the entry
    /// - Parameters:
    ///   - translation: CGPoint(x distance, y distance)
    func singleEntryMove(entry: CustomDrawChartDataEntry?, translation: CGPoint)

}

//base property for custom drawing, combined all of the needed protocol
public protocol CustomDrawChartDataSetProtocol: LineChartDataSetProtocol,
                                                CustomDrawChartDataSetDrawingProtocol,
                                                CustomDrawChartDataSetLocationProtocol,
                                                CustomDrawChartDataSetMoveProtocol
{
    /// graphics type
    var customDrawLineType: CustomGraphicsDrawType { get set }

    /// graphics path
    var customDrawLinePaths: [UIBezierPath] { get set }
    
    /// color, may be use the original dataSet.colors
    var customDrawLineColor: NSUIColor { get set }
}
