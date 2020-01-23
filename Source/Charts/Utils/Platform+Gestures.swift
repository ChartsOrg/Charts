//
//  Platform+Gestures.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

// MARK: - UIKit
#if canImport(UIKit)
import UIKit

public typealias NSUIGestureRecognizer = UIGestureRecognizer
public typealias NSUIGestureRecognizerState = UIGestureRecognizer.State
public typealias NSUIGestureRecognizerDelegate = UIGestureRecognizerDelegate
public typealias NSUITapGestureRecognizer = UITapGestureRecognizer
public typealias NSUIPanGestureRecognizer = UIPanGestureRecognizer

extension NSUITapGestureRecognizer
{
    @objc final func nsuiNumberOfTouches() -> Int
    {
        return numberOfTouches
    }

    @objc final var nsuiNumberOfTapsRequired: Int
        {
        get
        {
            return self.numberOfTapsRequired
        }
        set
        {
            self.numberOfTapsRequired = newValue
        }
    }
}

extension NSUIPanGestureRecognizer
{
    @objc final func nsuiNumberOfTouches() -> Int
    {
        return numberOfTouches
    }

    @objc final func nsuiLocationOfTouch(_ touch: Int, inView: UIView?) -> CGPoint
    {
        return super.location(ofTouch: touch, in: inView)
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

extension NSUIPinchGestureRecognizer
{
    @objc final var nsuiScale: CGFloat
        {
        get
        {
            return scale
        }
        set
        {
            scale = newValue
        }
    }

    @objc final func nsuiLocationOfTouch(_ touch: Int, inView: UIView?) -> CGPoint
    {
        return super.location(ofTouch: touch, in: inView)
    }
}
#endif
#endif

// MARK: - AppKit
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public typealias NSUIGestureRecognizer = NSGestureRecognizer
public typealias NSUIGestureRecognizerState = NSGestureRecognizer.State
public typealias NSUIGestureRecognizerDelegate = NSGestureRecognizerDelegate
public typealias NSUITapGestureRecognizer = NSClickGestureRecognizer
public typealias NSUIPanGestureRecognizer = NSPanGestureRecognizer
public typealias NSUIPinchGestureRecognizer = NSMagnificationGestureRecognizer
public typealias NSUIRotationGestureRecognizer = NSRotationGestureRecognizer

/** The 'tap' gesture is mapped to clicks. */
extension NSUITapGestureRecognizer
{
    final func nsuiNumberOfTouches() -> Int
    {
        return 1
    }

    final var nsuiNumberOfTapsRequired: Int
        {
        get
        {
            return self.numberOfClicksRequired
        }
        set
        {
            self.numberOfClicksRequired = newValue
        }
    }
}

extension NSUIPanGestureRecognizer
{
    final func nsuiNumberOfTouches() -> Int
    {
        return 1
    }

    /// FIXME: Currently there are no more than 1 touch in OSX gestures, and not way to create custom touch gestures.
    final func nsuiLocationOfTouch(_ touch: Int, inView: NSView?) -> NSPoint
    {
        return super.location(in: inView)
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
    final var nsuiScale: CGFloat
        {
        get
        {
            return magnification + 1.0
        }
        set
        {
            magnification = newValue - 1.0
        }
    }

    /// FIXME: Currently there are no more than 1 touch in OSX gestures, and not way to create custom touch gestures.
    final func nsuiLocationOfTouch(_ touch: Int, inView view: NSView?) -> NSPoint
    {
        return super.location(in: view)
    }
}
#endif
