import Foundation

/** This file provides a thin abstraction layer atop of UIKit (iOS, tvOS) and Cocoa (OS X). The two APIs are very much 
 alike, and for the chart library's usage of the APIs it is often sufficient to typealias one to the other. The NSUI*
 types are aliased to either their UI* implementation (on iOS) or their NS* implementation (on OS X). */
#if canImport(UIKit)
import UIKit

public typealias Font = UIFont
public typealias Image = UIImage
public typealias ScrollView = UIScrollView
public typealias Screen = UIScreen
public typealias DisplayLink = CADisplayLink

open class View: UIView
{
    @objc
    var nsuiLayer: CALayer? { self.layer }
}

func NSUIMainScreen() -> Screen? { Screen.main }

#endif

#if canImport(AppKit)
import AppKit

public typealias Font = NSFont
public typealias Image = NSImage
public typealias ScrollView = NSScrollView
public typealias Screen = NSScreen

/** On OS X there is no CADisplayLink. Use a 60 fps timer to render the animations. */
public class DisplayLink
{
    private var timer: Timer?
    private var displayLink: CVDisplayLink?
    private var _timestamp: CFTimeInterval = 0.0

    private weak var _target: AnyObject?
    private var _selector: Selector

    public var timestamp: CFTimeInterval
    {
        return _timestamp
    }

		init(target: Any, selector: Selector)
    {
        _target = target as AnyObject
        _selector = selector

        if CVDisplayLinkCreateWithActiveCGDisplays(&displayLink) == kCVReturnSuccess
        {

            CVDisplayLinkSetOutputCallback(displayLink!, { (displayLink, inNow, inOutputTime, flagsIn, flagsOut, userData) -> CVReturn in

                let _self = unsafeBitCast(userData, to: DisplayLink.self)
                    
                _self._timestamp = CFAbsoluteTimeGetCurrent()
                _self._target?.performSelector(onMainThread: _self._selector, with: _self, waitUntilDone: false)
                    
                return kCVReturnSuccess
                }, Unmanaged.passUnretained(self).toOpaque())
        }
        else
        {
            timer = Timer(timeInterval: 1.0 / 60.0, target: target, selector: selector, userInfo: nil, repeats: true)
        }
		}

    deinit
    {
        stop()
    }

    open func add(to runloop: RunLoop, forMode mode: RunLoop.Mode)
    {
        if displayLink != nil
        {
            CVDisplayLinkStart(displayLink!)
        }
        else if timer != nil
        {
            runloop.add(timer!, forMode: mode)
        }
    }

    open func remove(from: RunLoop, forMode: RunLoop.Mode)
    {
        stop()
    }

    private func stop()
    {
        if displayLink != nil
        {
            CVDisplayLinkStop(displayLink!)
        }
        if timer != nil
        {
            timer?.invalidate()
        }
    }
}

extension NSScrollView
{
    /// NOTE: Unable to disable scrolling in macOS
    var isScrollEnabled: Bool
    {
        get { true }
        set { }
    }
}

open class View: NSView
{
    /// A private constant to set the accessibility role during initialization.
    /// It ensures parity with the iOS element ordering as well as numbered counts of chart components.
    /// (See Platform+Accessibility for details)
    private let role: NSAccessibility.Role = .list

    public override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        setAccessibilityRole(role)
    }

    required public init?(coder decoder: NSCoder)
    {
        super.init(coder: decoder)
        setAccessibilityRole(role)
    }

    public final override var isFlipped: Bool { true }

    func setNeedsDisplay()
    {
        self.setNeedsDisplay(self.bounds)
    }


    open var backgroundColor: Color?
    {
        get { layer?.backgroundColor.flatMap(NSColor.init) }
        set
        {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }

    final var nsuiLayer: CALayer? { self.layer }
}

extension NSFont
{
    var lineHeight: CGFloat
    {
        // Not sure if this is right, but it looks okay
        self.boundingRectForFont.size.height
    }
}

extension NSScreen
{
    final var scale: CGFloat { self.backingScaleFactor }
}

extension NSImage
{
    var cgImage: CGImage?
    {
        self.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
}

func NSUIMainScreen() -> Screen? { Screen.main }

#endif
