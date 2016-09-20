import Foundation

/** This file provides a thin abstraction layer atop of UIKit (iOS, tvOS) and Cocoa (OS X). The two APIs are very much 
alike, and for the chart library's usage of the APIs it is often sufficient to typealias one to the other. The NSUI*
types are aliased to either their UI* implementation (on iOS) or their NS* implementation (on OS X). */
#if os(iOS) || os(tvOS)
	import UIKit
	
	public typealias NSUIFont = UIFont
	public typealias NSUIColor = UIColor
	public typealias NSUIEvent = UIEvent
	public typealias NSUITouch = UITouch
	public typealias NSUIImage = UIImage
	public typealias NSUIScrollView = UIScrollView
	public typealias NSUIGestureRecognizer = UIGestureRecognizer
	public typealias NSUIGestureRecognizerState = UIGestureRecognizerState
	public typealias NSUIGestureRecognizerDelegate = UIGestureRecognizerDelegate
	public typealias NSUITapGestureRecognizer = UITapGestureRecognizer
	public typealias NSUIPanGestureRecognizer = UIPanGestureRecognizer
#if !os(tvOS)
    public typealias NSUIPinchGestureRecognizer = UIPinchGestureRecognizer
    public typealias NSUIRotationGestureRecognizer = UIRotationGestureRecognizer
#endif
    public typealias NSUIScreen = UIScreen

	public typealias NSUIDisplayLink = CADisplayLink
    
    extension NSUITapGestureRecognizer
    {
        final func nsuiNumberOfTouches() -> Int
        {
            return numberOfTouches()
        }
        
        final var nsuiNumberOfTapsRequired: Int
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
        final func nsuiNumberOfTouches() -> Int
        {
            return numberOfTouches()
        }
        
        final func nsuiLocationOfTouch(touch: Int, inView: UIView?) -> CGPoint
        {
            return super.locationOfTouch(touch, inView: inView)
        }
    }
    
#if !os(tvOS)
    extension NSUIRotationGestureRecognizer
    {
        final var nsuiRotation: CGFloat
        {
            get { return rotation }
            set { rotation = newValue }
        }
    }
#endif
    
#if !os(tvOS)
    extension NSUIPinchGestureRecognizer
    {
        final var nsuiScale: CGFloat
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
        
        final func nsuiLocationOfTouch(touch: Int, inView: UIView?) -> CGPoint
        {
            return super.locationOfTouch(touch, inView: inView)
        }
    }
#endif

	public class NSUIView: UIView
    {
		public final override func touchesBegan(touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
        {
			self.nsuiTouchesBegan(touches, withEvent: event)
		}

		public final override func touchesMoved(touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
        {
			self.nsuiTouchesMoved(touches, withEvent: event)
		}

		public final override func touchesEnded(touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
        {
			self.nsuiTouchesEnded(touches, withEvent: event)
		}

		public final override func touchesCancelled(touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
        {
			self.nsuiTouchesCancelled(touches, withEvent: event)
		}

		public func nsuiTouchesBegan(touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
        {
			super.touchesBegan(touches, withEvent: event!)
		}

		public func nsuiTouchesMoved(touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
        {
			super.touchesMoved(touches, withEvent: event!)
		}

		public func nsuiTouchesEnded(touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
        {
			super.touchesEnded(touches, withEvent: event!)
		}

		public func nsuiTouchesCancelled(touches: Set<NSUITouch>?, withEvent event: NSUIEvent?)
        {
			super.touchesCancelled(touches!, withEvent: event!)
		}

		var nsuiLayer: CALayer?
        {
			return self.layer
		}
	}

	extension UIView
    {
		final var nsuiGestureRecognizers: [NSUIGestureRecognizer]?
        {
			return self.gestureRecognizers
		}
    }
    
    extension UIScreen
    {
        final var nsuiScale: CGFloat
        {
            return self.scale
        }
    }

    func NSUIGraphicsGetCurrentContext() -> CGContextRef?
    {
		return UIGraphicsGetCurrentContext()
	}

    func NSUIGraphicsGetImageFromCurrentImageContext() -> NSUIImage!
    {
		return UIGraphicsGetImageFromCurrentImageContext()
	}

	func NSUIGraphicsPushContext(context: CGContextRef)
    {
		UIGraphicsPushContext(context)
	}

	func NSUIGraphicsPopContext()
    {
		UIGraphicsPopContext()
	}

	func NSUIGraphicsEndImageContext()
    {
		UIGraphicsEndImageContext()
	}

	func NSUIImagePNGRepresentation(image: NSUIImage) -> NSData?
    {
		return UIImagePNGRepresentation(image)
	}

	func NSUIImageJPEGRepresentation(image: NSUIImage, _ quality: CGFloat = 0.8) -> NSData?
    {
		return UIImageJPEGRepresentation(image, quality)
	}

	func NSUIMainScreen() -> NSUIScreen?
    {
		return NSUIScreen.mainScreen()
	}

	func NSUIGraphicsBeginImageContextWithOptions(size: CGSize, _ opaque: Bool, _ scale: CGFloat)
    {
		UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
	}

#endif

#if os(OSX)
	import Cocoa
	import Quartz

	public typealias NSUIFont = NSFont
	public typealias NSUIColor = NSColor
	public typealias NSUIEvent = NSEvent
	public typealias NSUITouch = NSTouch
	public typealias NSUIImage = NSImage
	public typealias NSUIScrollView = NSScrollView
	public typealias NSUIGestureRecognizer = NSGestureRecognizer
	public typealias NSUIGestureRecognizerState = NSGestureRecognizerState
	public typealias NSUIGestureRecognizerDelegate = NSGestureRecognizerDelegate
	public typealias NSUITapGestureRecognizer = NSClickGestureRecognizer
	public typealias NSUIPanGestureRecognizer = NSPanGestureRecognizer
	public typealias NSUIPinchGestureRecognizer = NSMagnificationGestureRecognizer
	public typealias NSUIRotationGestureRecognizer = NSRotationGestureRecognizer
	public typealias NSUIScreen = NSScreen

	/** On OS X there is no CADisplayLink. Use a 60 fps timer to render the animations. */
	public class NSUIDisplayLink
    {
        private var timer: NSTimer?
        private var displayLink: CVDisplayLink?
        private var _timestamp: CFTimeInterval = 0.0
        
        private weak var _target: AnyObject?
        private var _selector: Selector
        
        public var timestamp: CFTimeInterval
        {
            return _timestamp
        }

		init(target: AnyObject, selector: Selector)
        {
            _target = target
            _selector = selector
            
            if CVDisplayLinkCreateWithActiveCGDisplays(&displayLink) == kCVReturnSuccess
            {
                CVDisplayLinkSetOutputCallback(displayLink!, { (displayLink, inNow, inOutputTime, flagsIn, flagsOut, userData) -> CVReturn in
                    
                    let _self = unsafeBitCast(userData, NSUIDisplayLink.self)
                    
                    _self._timestamp = CFAbsoluteTimeGetCurrent()
                    _self._target?.performSelectorOnMainThread(_self._selector, withObject: _self, waitUntilDone: false)
                    
                    return kCVReturnSuccess
                    }, UnsafeMutablePointer(unsafeAddressOf(self)))
            }
            else
            {
                timer = NSTimer(timeInterval: 1.0 / 60.0, target: target, selector: selector, userInfo: nil, repeats: true)
            }
		}
        
        deinit
        {
            stop()
        }

		public func addToRunLoop(runloop: NSRunLoop, forMode: String)
        {
            if displayLink != nil
            {
                CVDisplayLinkStart(displayLink!)
            }
            else if timer != nil
            {
                runloop.addTimer(timer!, forMode: forMode)
            }
		}

		public func removeFromRunLoop(runloop: NSRunLoop, forMode: String)
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
		final func nsuiLocationOfTouch(touch: Int, inView: NSView?) -> NSPoint
        {
			return super.locationInView(inView)
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
        final func nsuiLocationOfTouch(touch: Int, inView: NSView?) -> NSPoint
        {
            return super.locationInView(inView)
        }
    }

	extension NSView
    {
		final var nsuiGestureRecognizers: [NSGestureRecognizer]?
        {
			return self.gestureRecognizers
		}
	}

	public class NSUIView: NSView
    {
		public final override var flipped: Bool
        {
			return true
		}

		func setNeedsDisplay()
        {
			self.setNeedsDisplayInRect(self.bounds)
		}

		public final override func touchesBeganWithEvent(event: NSEvent)
        {
			self.nsuiTouchesBegan(event.touchesMatchingPhase(.Any, inView: self), withEvent: event)
		}

		public final override func touchesEndedWithEvent(event: NSEvent)
        {
			self.nsuiTouchesEnded(event.touchesMatchingPhase(.Any, inView: self), withEvent: event)
		}

		public final override func touchesMovedWithEvent(event: NSEvent)
        {
			self.nsuiTouchesMoved(event.touchesMatchingPhase(.Any, inView: self), withEvent: event)
		}

		public override func touchesCancelledWithEvent(event: NSEvent)
        {
			self.nsuiTouchesCancelled(event.touchesMatchingPhase(.Any, inView: self), withEvent: event)
		}

		public func nsuiTouchesBegan(touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
        {
			super.touchesBeganWithEvent(event!)
		}

		public func nsuiTouchesMoved(touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
        {
			super.touchesMovedWithEvent(event!)
		}

		public func nsuiTouchesEnded(touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
        {
			super.touchesEndedWithEvent(event!)
		}

		public func nsuiTouchesCancelled(touches: Set<NSUITouch>?, withEvent event: NSUIEvent?)
        {
			super.touchesCancelledWithEvent(event!)
        }
        
		var backgroundColor: NSUIColor?
        {
            get
            {
                return self.layer?.backgroundColor == nil
                    ? nil
                    : NSColor(CGColor: self.layer!.backgroundColor!)
            }
            set
            {
                self.layer?.backgroundColor = newValue == nil ? nil : newValue!.CGColor
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
		var CGImage: CGImageRef?
        {
            return self.CGImageForProposedRect(nil, context: nil, hints: nil)
		}
	}

	extension NSTouch
    {
		/** Touch locations on OS X are relative to the trackpad, whereas on iOS they are actually *on* the view. */
		func locationInView(view: NSView) -> NSPoint
        {
			let n = self.normalizedPosition
			let b = view.bounds
			return NSPoint(x: b.origin.x + b.size.width * n.x, y: b.origin.y + b.size.height * n.y)
		}
	}

	extension NSScrollView
    {
		var scrollEnabled: Bool
        {
			get
            {
				return true
			}
            set
            {
                // FIXME: We can't disable  scrolling it on OSX
            }
		}
	}

	func NSUIGraphicsGetCurrentContext() -> CGContextRef?
    {
		return NSGraphicsContext.currentContext()?.CGContext
	}

	func NSUIGraphicsPushContext(context: CGContextRef)
    {
		let address = unsafeAddressOf(context)
		let ptr: UnsafeMutablePointer<CGContext> = UnsafeMutablePointer(UnsafePointer<CGContext>(address))
		let cx = NSGraphicsContext(graphicsPort: ptr, flipped: true)
		NSGraphicsContext.saveGraphicsState()
		NSGraphicsContext.setCurrentContext(cx)
	}

	func NSUIGraphicsPopContext()
    {
		NSGraphicsContext.restoreGraphicsState()
	}

	func NSUIImagePNGRepresentation(image: NSUIImage) -> NSData?
    {
		image.lockFocus()
		let rep = NSBitmapImageRep(focusedViewRect: NSMakeRect(0, 0, image.size.width, image.size.height))
		image.unlockFocus()
		return rep?.representationUsingType(.JPEG, properties: [:])
	}

	func NSUIImageJPEGRepresentation(image: NSUIImage, _ quality: CGFloat = 0.9) -> NSData?
    {
		image.lockFocus()
		let rep = NSBitmapImageRep(focusedViewRect: NSMakeRect(0, 0, image.size.width, image.size.height))
		image.unlockFocus()
		return rep?.representationUsingType(.JPEG, properties: [NSImageCompressionFactor: quality])
	}

	private var imageContextStack: [CGFloat] = []

	func NSUIGraphicsBeginImageContextWithOptions(size: CGSize, _ opaque: Bool, _ scale: CGFloat)
    {
		var scale = scale
		if scale == 0.0
        {
			scale = NSScreen.mainScreen()?.backingScaleFactor ?? 1.0
		}

		let width = Int(size.width * scale)
		let height = Int(size.height * scale)

		if width > 0 && height > 0
        {
			imageContextStack.append(scale)

			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let ctx = CGBitmapContextCreate(nil, width, height, 8, 4*width, colorSpace, (opaque ?  CGImageAlphaInfo.NoneSkipFirst.rawValue : CGImageAlphaInfo.PremultipliedFirst.rawValue))
			CGContextConcatCTM(ctx!, CGAffineTransformMake(1, 0, 0, -1, 0, CGFloat(height)))
			CGContextScaleCTM(ctx!, scale, scale)
			NSUIGraphicsPushContext(ctx!)
		}
	}

	func NSUIGraphicsGetImageFromCurrentImageContext() -> NSUIImage?
    {
		if !imageContextStack.isEmpty
        {
			let ctx = NSUIGraphicsGetCurrentContext()
			let scale = imageContextStack.last!
			if let theCGImage = CGBitmapContextCreateImage(ctx!)
            {
				let size = CGSizeMake(CGFloat(CGBitmapContextGetWidth(ctx!)) / scale, CGFloat(CGBitmapContextGetHeight(ctx!)) / scale)
				let image = NSImage(CGImage: theCGImage, size: size)
				return image
			}
		}
		return nil
	}

	func NSUIGraphicsEndImageContext()
    {
		if imageContextStack.last != nil
        {
			imageContextStack.removeLast()
			NSUIGraphicsPopContext()
		}
	}

	func NSUIMainScreen() -> NSUIScreen?
    {
		return NSUIScreen.mainScreen()
	}

#endif
