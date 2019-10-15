//
//  Platform+Touch Handling.swift
//  Charts
//
//  Created by Jacob Christie on 2019-10-15.
//

#if canImport(UIKit)
import UIKit

public typealias Event = UIEvent
public typealias Touch = UITouch

@objc
extension View {
    public final override func touchesBegan(_ touches: Set<Touch>, with event: Event?)
    {
        self.nsuiTouchesBegan(touches, withEvent: event)
    }

    public final override func touchesMoved(_ touches: Set<Touch>, with event: Event?)
    {
        self.nsuiTouchesMoved(touches, withEvent: event)
    }

    public final override func touchesEnded(_ touches: Set<Touch>, with event: Event?)
    {
        self.nsuiTouchesEnded(touches, withEvent: event)
    }

    public final override func touchesCancelled(_ touches: Set<Touch>, with event: Event?)
    {
        self.nsuiTouchesCancelled(touches, withEvent: event)
    }

    open func nsuiTouchesBegan(_ touches: Set<Touch>, withEvent event: Event?)
    {
        super.touchesBegan(touches, with: event!)
    }

    open func nsuiTouchesMoved(_ touches: Set<Touch>, withEvent event: Event?)
    {
        super.touchesMoved(touches, with: event!)
    }

    open func nsuiTouchesEnded(_ touches: Set<Touch>, withEvent event: Event?)
    {
        super.touchesEnded(touches, with: event!)
    }

    open func nsuiTouchesCancelled(_ touches: Set<Touch>?, withEvent event: Event?)
    {
        super.touchesCancelled(touches!, with: event!)
    }
}
#endif


#if canImport(AppKit)
import AppKit

public typealias Event = NSEvent
public typealias Touch = NSTouch

@objc
extension View
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

    open func nsuiTouchesBegan(_ touches: Set<Touch>, withEvent event: Event?)
    {
        super.touchesBegan(with: event!)
    }

    open func nsuiTouchesMoved(_ touches: Set<Touch>, withEvent event: Event?)
    {
        super.touchesMoved(with: event!)
    }

    open func nsuiTouchesEnded(_ touches: Set<Touch>, withEvent event: Event?)
    {
        super.touchesEnded(with: event!)
    }

    open func nsuiTouchesCancelled(_ touches: Set<Touch>?, withEvent event: Event?)
    {
        super.touchesCancelled(with: event!)
    }
}

#endif
