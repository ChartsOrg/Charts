import Foundation

/** This file provides a thin abstraction layer atop of UIKit (iOS, tvOS) and Cocoa (OS X). The two APIs are very much 
 alike, and for the chart library's usage of the APIs it is often sufficient to typealias one to the other. The NSUI*
 types are aliased to either their UI* implementation (on iOS) or their NS* implementation (on OS X). */
#if os(iOS) || os(tvOS)
#if canImport(UIKit)
    import UIKit
#endif

public typealias NSUIFont = UIFont
public typealias NSUIImage = UIImage
public typealias NSUIScrollView = UIScrollView
public typealias NSUIScreen = UIScreen
public typealias NSUIDisplayLink = CADisplayLink

open class NSUIView: UIView
{
    @objc var nsuiLayer: CALayer?
    {
        return self.layer
    }
}

extension UIScrollView
{
    @objc var nsuiIsScrollEnabled: Bool
        {
        get { return isScrollEnabled }
        set { isScrollEnabled = newValue }
    }
}

extension UIScreen
{
    @objc final var nsuiScale: CGFloat
    {
        return self.scale
    }
}

func NSUIMainScreen() -> NSUIScreen?
{
    return NSUIScreen.main
}

#endif

#if os(OSX)
import Cocoa
import Quartz

public typealias NSUIFont = NSFont
public typealias NSUIImage = NSImage
public typealias NSUIScrollView = NSScrollView
public typealias NSUIScreen = NSScreen

/** On OS X there is no CADisplayLink. Use a 60 fps timer to render the animations. */
public class NSUIDisplayLink
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

                let _self = unsafeBitCast(userData, to: NSUIDisplayLink.self)
                    
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

extension NSView
{
    final var nsuiGestureRecognizers: [NSGestureRecognizer]?
    {
        return self.gestureRecognizers
    }
}

extension NSScrollView
{
    var nsuiIsScrollEnabled: Bool
    {
        get { return scrollEnabled }
        set { scrollEnabled = newValue }
    }
}

open class NSUIView: NSView
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

    public final override var isFlipped: Bool
    {
        return true
    }

    func setNeedsDisplay()
    {
        self.setNeedsDisplay(self.bounds)
    }


    open var backgroundColor: NSUIColor?
        {
        get
        {
            return self.layer?.backgroundColor == nil
                ? nil
                : NSColor(cgColor: self.layer!.backgroundColor!)
        }
        set
        {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue == nil ? nil : newValue!.cgColor
        }
    }

    final var nsuiLayer: CALayer?
    {
        return self.layer
    }
}

extension NSFont
{
    var lineHeight: CGFloat
    {
        // Not sure if this is right, but it looks okay
        return self.boundingRectForFont.size.height
    }
}

extension NSScreen
{
    final var nsuiScale: CGFloat
    {
        return self.backingScaleFactor
    }
}

extension NSImage
{
    var cgImage: CGImage?
    {
        return self.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
}

extension NSScrollView
{
    /// NOTE: Unable to disable scrolling in macOS
    var scrollEnabled: Bool
    {
        get
        {
            return true
        }
        set
        {
        }
    }
}

func NSUIMainScreen() -> NSUIScreen?
{
    return NSUIScreen.main
}

#endif
