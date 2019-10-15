//
//  Platform+Color.swift
//  Charts
//
//  Created by Jacob Christie on 2019-10-15.
//

#if canImport(UIKit)
import UIKit

public typealias NSUIColor = UIColor
extension UIColor {
    @available(iOS, introduced: 8.0, obsoleted: 13.0)
    @available(tvOS, introduced: 9.0, obsoleted: 13.0)
    static var label: UIColor { .black }
}
#endif

#if canImport(AppKit)

import AppKit

public typealias NSUIColor = NSColor
extension NSColor {
    @available(macOS, introduced: 10.11, obsoleted: 10.14)
    static var label: NSColor { .black }
}
#endif
