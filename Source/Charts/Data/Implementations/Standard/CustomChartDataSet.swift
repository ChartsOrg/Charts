//
//  CustomChartDataSet.swift
//  Charts
//
//  Created by JustLee on 2021/4/1.
//

import UIKit

open class CustomDrawChartDataSet: LineChartDataSet, CustomDrawChartDataSetProtocol
{
    @objc open var customDrawLineType: CustomGraphicsDrawType = .lineSegment

    @objc open var customDrawLinePaths: [UIBezierPath] = [UIBezierPath]()
    
    @objc open var customDrawLineColor: NSUIColor = .black
    
    @objc open var minimumXErrorScale: CGFloat = 0.01
    
    @objc open var minimumYErrorScale: CGFloat = 0.01
    
    @objc open var graphicsPathWidth: CGFloat = 5.0
}

//Drawing
extension CustomDrawChartDataSet: CustomDrawChartDataSetDrawingProtocol
{
    public var dataSetCompletedCustomDraw: Bool {
        if customDrawLineType.completeRequiredPointCount == entries.count {
            if customDrawLineType.needSupplyGraphicsPoint {
                supplyGraphicsRemainingPoints()
            }
            
            return true
        }
        return false
    }

    open func supplyGraphicsRemainingPoints()
    {
        switch customDrawLineType {
            
        case .rectangle:
            let point_a1 = entries.first!
            let point_a3 = entries.last!
            let point_a2 = CustomDrawChartDataEntry(x: point_a1.x, y: point_a3.y)
            let point_a4 = CustomDrawChartDataEntry(x: point_a3.x, y: point_a1.y)
            replaceEntries([point_a1, point_a2, point_a3, point_a4])
        break
            
        default: break
            
        }
    }
    
    open func correctGraphicsOtherPoints(entry: CustomDrawChartDataEntry)
    {
        switch customDrawLineType {
        case .rectangle:
            let index = entries.firstIndex(of: entry)
            
            switch index {
            case 0:
                let point_a1 = entries[1]
                let point_a3 = entries[3]
                point_a1.resetValue(with: entry.x, y: point_a1.y)
                point_a3.resetValue(with: point_a3.x, y: entry.y)
                break
            case 1:
                let point_a0 = entries[0]
                let point_a2 = entries[2]
                point_a0.resetValue(with: entry.x, y: point_a0.y)
                point_a2.resetValue(with: point_a2.x, y: entry.y)
                break
                
            case 2:
                let point_a1 = entries[1]
                let point_a3 = entries[3]
                point_a3.resetValue(with: entry.x, y: point_a3.y)
                point_a1.resetValue(with: point_a1.x, y: entry.y)
                break
                
            case 3:
                let point_a0 = entries[0]
                let point_a2 = entries[2]
                point_a2.resetValue(with: entry.x, y: point_a2.y)
                point_a0.resetValue(with: point_a0.x, y: entry.y)
                break
            default:
                break
            }
            break
            
        default:
            break
        }
    }
    
    @objc open var remainingPointCount: Int
    {
        return self.customDrawLineType.completeRequiredPointCount - count
    }
    
    @objc open var finished: Bool
    {
        return remainingPointCount <= 0
    }
}


//move
extension CustomDrawChartDataSet: CustomDrawChartDataSetMoveProtocol
{
    public func totalGraphicsMove(translation: CGPoint)
    {
        entries.forEach {
            $0.changeValue(with: Double(translation.x), y: Double(translation.y))
        }
    }

    public func singleEntryMove(entry: CustomDrawChartDataEntry?, translation: CGPoint)
    {
        if let entry = entry {
            entry.changeValue(with: Double(translation.x), y: Double(translation.y))
            correctGraphicsOtherPoints(entry: entry)
        }
    }

    public func appendClosedGraphicsPath(points: [CGPoint])
    {
        if entries.count > 0 {
            customDrawLinePaths.append(UIBezierPath.closedGraphicsPath(points: points))
        }
    }

    public func appendSingleLinePath(points: [CGPoint])
    {
        if entries.count > 0 {
            customDrawLinePaths.append(UIBezierPath.singleLinePath(points: points, pathWidth: graphicsPathWidth))
        }
    }

    public func clearGraphicsPath()
    {
        customDrawLinePaths.removeAll()
    }
}

// location
extension CustomDrawChartDataSet: CustomDrawChartDataSetLocationProtocol {

    public func locateTouchEntry(touchPoint: CGPoint, xRange: CGFloat, yRange: CGFloat) -> CustomDrawChartDataEntry?
    {
        for closestEntry in entries {
            if fabs(closestEntry.x - Double(touchPoint.x)) < Double(xRange * minimumXErrorScale) && fabs(closestEntry.y - Double(touchPoint.y)) < Double(yRange * minimumYErrorScale) {
                return closestEntry as? CustomDrawChartDataEntry
            }
        }
        return nil
    }
    
    public func calculatePositionInGraphics(touchPoint: CGPoint) -> Bool
    {
        return customDrawLinePaths.filter { return $0.contains(touchPoint) }.count != 0
    }
}
