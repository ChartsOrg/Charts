//
//  Platform+Touch Handling.swift
//  Charts
//
//  Created by Jacob Christie on 2019-10-15.
//

#if canImport(UIKit)
import UIKit

public typealias NSUIEvent = UIEvent
public typealias NSUITouch = UITouch

@objc
extension NSUIView {
    public final override func touchesBegan(_ touches: Set<NSUITouch>, with event: NSUIEvent?)
    {
        self.nsuiTouchesBegan(touches, withEvent: event)
    }

    public final override func touchesMoved(_ touches: Set<NSUITouch>, with event: NSUIEvent?)
    {
        self.nsuiTouchesMoved(touches, withEvent: event)
    }

    public final override func touchesEnded(_ touches: Set<NSUITouch>, with event: NSUIEvent?)
    {
        self.nsuiTouchesEnded(touches, withEvent: event)
    }

    public final override func touchesCancelled(_ touches: Set<NSUITouch>, with event: NSUIEvent?)
    {
        self.nsuiTouchesCancelled(touches, withEvent: event)
    }

    open func nsuiTouchesBegan(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.touchesBegan(touches, with: event!)
    }

    open func nsuiTouchesMoved(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.touchesMoved(touches, with: event!)
    }

    open func nsuiTouchesEnded(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.touchesEnded(touches, with: event!)
    }

    open func nsuiTouchesCancelled(_ touches: Set<NSUITouch>?, withEvent event: NSUIEvent?)
    {
        super.touchesCancelled(touches!, with: event!)
    }
}
#endif


#if canImport(AppKit)
import AppKit

public typealias NSUIEvent = NSEvent
public typealias NSUITouch = NSTouch

@objc
extension NSUIView
{
    public final override func touchesBegan(with event: NSEvent)
    {
        self.nsuiTouchesBegan(event.touches(matching: .any, in: self), withEvent: event)
    }

    public final override func touchesEnded(with event: NSEvent)
    {
        self.nsuiTouchesEnded(event.touches(matching: .any, in: self), withEvent: event)
    }

    public final override func touchesMoved(with event: NSEvent)
    {
        self.nsuiTouchesMoved(event.touches(matching: .any, in: self), withEvent: event)
    }

    open override func touchesCancelled(with event: NSEvent)
    {
        self.nsuiTouchesCancelled(event.touches(matching: .any, in: self), withEvent: event)
    }

    open func nsuiTouchesBegan(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.touchesBegan(with: event!)
    }

    open func nsuiTouchesMoved(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.touchesMoved(with: event!)
    }

    open func nsuiTouchesEnded(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.touchesEnded(with: event!)
    }

    open func nsuiTouchesCancelled(_ touches: Set<NSUITouch>?, withEvent event: NSUIEvent?)
    {
        super.touchesCancelled(with: event!)
    }
}

#endif
