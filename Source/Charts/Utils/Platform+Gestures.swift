//
//  Platform+Gestures.swift
//  
//
//  Created by Jacob Christie on 2019-10-15.
//

// MARK: - UIKit
#if canImport(UIKit)
import UIKit

public typealias NSUIGestureRecognizer = UIGestureRecognizer
public typealias NSUIGestureRecognizerState = UIGestureRecognizer.State
public typealias NSUIGestureRecognizerDelegate = UIGestureRecognizerDelegate
public typealias NSUITapGestureRecognizer = UITapGestureRecognizer
public typealias NSUIPanGestureRecognizer = UIPanGestureRecognizer

extension UIView
{
    @objc
    final var nsuiGestureRecognizers: [NSUIGestureRecognizer]?
    {
        self.gestureRecognizers
    }
}

#if !os(tvOS)
public typealias NSUIPinchGestureRecognizer = UIPinchGestureRecognizer
public typealias NSUIRotationGestureRecognizer = UIRotationGestureRecognizer

extension NSUIRotationGestureRecognizer
{
    @objc final var nsuiRotation: CGFloat
    {
        get { return rotation }
        set { rotation = newValue }
    }
}
#endif
#endif

// MARK: - AppKit
#if canImport(AppKit)
import AppKit

public typealias NSUIGestureRecognizer = NSGestureRecognizer
public typealias NSUIGestureRecognizerState = NSGestureRecognizer.State
public typealias NSUIGestureRecognizerDelegate = NSGestureRecognizerDelegate
public typealias NSUITapGestureRecognizer = NSClickGestureRecognizer
public typealias NSUIPanGestureRecognizer = NSPanGestureRecognizer
public typealias NSUIPinchGestureRecognizer = NSMagnificationGestureRecognizer
public typealias NSUIRotationGestureRecognizer = NSRotationGestureRecognizer

extension NSView
{
    @objc
    final var nsuiGestureRecognizers: [NSGestureRecognizer]?
    {
        self.gestureRecognizers
    }
}

/** The 'tap' gesture is mapped to clicks. */
extension NSUITapGestureRecognizer
{
    final var numberOfTapsRequired: Int
    {
        get { numberOfClicksRequired }
        set { numberOfClicksRequired = newValue }
    }
}

extension NSUIPanGestureRecognizer
{
    final var numberOfTouches: Int { 1 }

    /// FIXME: Currently there are no more than 1 touch in OSX gestures, and not way to create custom touch gestures.
    final func location(ofTouch touch: Int, in view: NSView?) -> CGPoint
    {
        location(in: view)
    }
}

extension NSUIRotationGestureRecognizer
{
    /// FIXME: Currently there are no velocities in OSX gestures, and not way to create custom touch gestures.
    final var velocity: CGFloat
    {
        return 0.1
    }

    final var nsuiRotation: CGFloat
    {
        get { return -rotation }
        set { rotation = -newValue }
    }
}

extension NSUIPinchGestureRecognizer
{
    final var scale: CGFloat
    {
        get { magnification + 1.0 }
        set { magnification = newValue - 1.0 }
    }

    /// FIXME: Currently there are no more than 1 touch in OSX gestures, and not way to create custom touch gestures.
    final func location(ofTouch touch: Int, in view: NSView?) -> CGPoint
    {
        location(in: view)
    }
}
#endif
