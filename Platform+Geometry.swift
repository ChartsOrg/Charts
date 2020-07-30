//
//  Platform+Geometry.swift
//  Charts
//
//  Created by Van on 31.07.2020.
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

// MARK: - UIKit
#if canImport(UIKit)
import UIKit

public typealias NSUIEdgeInsets = UIEdgeInsets

#endif

// MARK: - AppKit
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public typealias NSUIEdgeInsets = NSEdgeInsets

extension NSUIEdgeInsets
{
    static public let zero = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
}

extension CGRect {
    func inset(by insets: NSEdgeInsets) -> CGRect
    {
        //https://github.com/github/Archimedes/blob/063bcccf1abc7b53871d21d790bce06718c38ec0/Archimedes/MEDEdgeInsets.m
        return CGRect(origin: CGPoint(x: origin.x + insets.left, y: origin.y + insets.bottom),
                      size: CGSize(width: width - insets.left - insets.right, height: height - insets.top - insets.bottom))
    }
}

#endif
