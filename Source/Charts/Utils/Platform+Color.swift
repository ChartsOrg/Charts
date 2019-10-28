//
//  Platform+Color.swift
//  Charts
//
//  Created by Jacob Christie on 2019-10-15.
//

#if canImport(UIKit)
import UIKit
public typealias Color = UIColor
#endif

#if canImport(AppKit)
import AppKit
public typealias Color = NSColor

@available(macOS 10.14, *)
private extension NSColor
{
    static var label: NSColor { .labelColor }
}
#endif

extension Color
{
    static var labelOrBlack: Color {
        if #available(iOS 13, tvOS 13, *), #available(macOS 10.14, *)
        {
            return .label
        }
        else
        {
            return .black
        }
    }
}
