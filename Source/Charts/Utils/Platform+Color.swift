//
//  Platform+Color.swift
//  Charts
//
//  Created by Jacob Christie on 2019-10-15.
//

#if canImport(UIKit)
import UIKit

public typealias NSUIColor = UIColor
private func fetchLabelColor() -> UIColor
{
    if #available(iOS 13, tvOS 13, *)
    {
        return .label
    }
    else
    {
        return .black
    }
}
private let labelColor: UIColor = fetchLabelColor()

extension UIColor
{
    static var labelOrBlack: UIColor { labelColor }
}
#endif

#if canImport(AppKit)

import AppKit

public typealias NSUIColor = NSColor
private func fetchLabelColor() -> NSColor
{
    if #available(macOS 10.14, *)
    {
        return .labelColor
    }
    else
    {
        return .black
    }
}
private let labelColor: NSColor = fetchLabelColor()

extension NSColor
{
    static var labelOrBlack: NSColor { labelColor }
}
#endif
