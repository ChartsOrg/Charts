//
//  Platform+Touch Handling.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#if canImport(UIKit)
    import UIKit

    public typealias NSUIEvent = UIEvent
    public typealias NSUITouch = UITouch

    @objc
    extension NSUIView {
        override public final func touchesBegan(_ touches: Set<NSUITouch>, with event: NSUIEvent?) {
            nsuiTouchesBegan(touches, withEvent: event)
        }

        override public final func touchesMoved(_ touches: Set<NSUITouch>, with event: NSUIEvent?) {
            nsuiTouchesMoved(touches, withEvent: event)
        }

        override public final func touchesEnded(_ touches: Set<NSUITouch>, with event: NSUIEvent?) {
            nsuiTouchesEnded(touches, withEvent: event)
        }

        override public final func touchesCancelled(_ touches: Set<NSUITouch>, with event: NSUIEvent?) {
            nsuiTouchesCancelled(touches, withEvent: event)
        }

        open func nsuiTouchesBegan(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
            super.touchesBegan(touches, with: event!)
        }

        open func nsuiTouchesMoved(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
            super.touchesMoved(touches, with: event!)
        }

        open func nsuiTouchesEnded(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
            super.touchesEnded(touches, with: event!)
        }

        open func nsuiTouchesCancelled(_ touches: Set<NSUITouch>?, withEvent event: NSUIEvent?) {
            super.touchesCancelled(touches!, with: event!)
        }
    }

    extension UIView {
        final var nsuiGestureRecognizers: [NSUIGestureRecognizer]? {
            return gestureRecognizers
        }
    }
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit

    public typealias NSUIEvent = NSEvent
    public typealias NSUITouch = NSTouch

    @objc
    extension NSUIView {
        override public final func touchesBegan(with event: NSEvent) {
            nsuiTouchesBegan(event.touches(matching: .any, in: self), withEvent: event)
        }

        override public final func touchesEnded(with event: NSEvent) {
            nsuiTouchesEnded(event.touches(matching: .any, in: self), withEvent: event)
        }

        override public final func touchesMoved(with event: NSEvent) {
            nsuiTouchesMoved(event.touches(matching: .any, in: self), withEvent: event)
        }

        override open func touchesCancelled(with event: NSEvent) {
            nsuiTouchesCancelled(event.touches(matching: .any, in: self), withEvent: event)
        }

        open func nsuiTouchesBegan(_: Set<NSUITouch>, withEvent event: NSUIEvent?) {
            super.touchesBegan(with: event!)
        }

        open func nsuiTouchesMoved(_: Set<NSUITouch>, withEvent event: NSUIEvent?) {
            super.touchesMoved(with: event!)
        }

        open func nsuiTouchesEnded(_: Set<NSUITouch>, withEvent event: NSUIEvent?) {
            super.touchesEnded(with: event!)
        }

        open func nsuiTouchesCancelled(_: Set<NSUITouch>?, withEvent event: NSUIEvent?) {
            super.touchesCancelled(with: event!)
        }
    }

    extension NSTouch {
        /** Touch locations on OS X are relative to the trackpad, whereas on iOS they are actually *on* the view. */
        func locationInView(view: NSView) -> NSPoint {
            let n = normalizedPosition
            let b = view.bounds
            return NSPoint(
                x: b.origin.x + b.size.width * n.x,
                y: b.origin.y + b.size.height * n.y
            )
        }
    }
#endif
