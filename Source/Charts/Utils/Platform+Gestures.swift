//
//  Platform+Gestures.swift
//  
//
//  Created by Jacob Christie on 2019-10-15.
//

// MARK: - UIKit
#if canImport(UIKit)
import UIKit

public typealias GestureRecognizer = UIGestureRecognizer
public typealias GestureRecognizerState = UIGestureRecognizer.State
public typealias GestureRecognizerDelegate = UIGestureRecognizerDelegate
public typealias TapGestureRecognizer = UITapGestureRecognizer
public typealias PanGestureRecognizer = UIPanGestureRecognizer

extension UIView
{
    @objc
    final var nsuiGestureRecognizers: [GestureRecognizer]?
    {
        self.gestureRecognizers
    }
}

#if !os(tvOS)
public typealias PinchGestureRecognizer = UIPinchGestureRecognizer
public typealias RotationGestureRecognizer = UIRotationGestureRecognizer

extension RotationGestureRecognizer
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

public typealias GestureRecognizer = NSGestureRecognizer
public typealias GestureRecognizerState = NSGestureRecognizer.State
public typealias GestureRecognizerDelegate = NSGestureRecognizerDelegate
public typealias TapGestureRecognizer = NSClickGestureRecognizer
public typealias PanGestureRecognizer = NSPanGestureRecognizer
public typealias PinchGestureRecognizer = NSMagnificationGestureRecognizer
public typealias RotationGestureRecognizer = NSRotationGestureRecognizer

extension NSView
{
    @objc
    final var nsuiGestureRecognizers: [NSGestureRecognizer]?
    {
        self.gestureRecognizers
    }
}

/** The 'tap' gesture is mapped to clicks. */
extension TapGestureRecognizer
{
    final var numberOfTapsRequired: Int
    {
        get { numberOfClicksRequired }
        set { numberOfClicksRequired = newValue }
    }
}

extension PanGestureRecognizer
{
    final var numberOfTouches: Int { 1 }

    /// FIXME: Currently there are no more than 1 touch in OSX gestures, and not way to create custom touch gestures.
    final func location(ofTouch touch: Int, in view: NSView?) -> CGPoint
    {
        location(in: view)
    }
}

extension RotationGestureRecognizer
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

extension PinchGestureRecognizer
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
