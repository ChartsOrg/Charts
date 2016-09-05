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
            return numberOfTouches
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
            return numberOfTouches
        }
        
        final func nsuiLocationOf(touch: Int, in view: UIView?) -> CGPoint
        {
            return super.location(ofTouch: touch, in: view)
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
        
        final func nsuiLocationOf(touch: Int, in view: UIView?) -> CGPoint
        {
            return super.location(ofTouch: touch, in: view)
        }
    }
#endif

	open class NSUIView: UIView
    {
		open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
        {
			self.nsuiTouchesBegan(touches, with: event)
		}

		open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
        {
			self.nsuiTouchesMoved(touches, with: event)
		}

		open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
        {
			self.nsuiTouchesEnded(touches, with: event)
		}

		open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
        {
			self.nsuiTouchesCancelled(touches, with: event)
		}

		open func nsuiTouchesBegan(_ touches: Set<NSUITouch>, with event: NSUIEvent?)
        {
			super.touchesBegan(touches, with: event!)
		}

		open func nsuiTouchesMoved(_ touches: Set<NSUITouch>, with event: NSUIEvent?)
        {
			super.touchesMoved(touches, with: event!)
		}

		open func nsuiTouchesEnded(_ touches: Set<NSUITouch>, with event: NSUIEvent?)
        {
			super.touchesEnded(touches, with: event!)
		}

		open func nsuiTouchesCancelled(_ touches: Set<NSUITouch>?, with event: NSUIEvent?)
        {
			super.touchesCancelled(touches ?? [], with: event!)
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

    func NSUIGraphicsGetCurrentContext() -> CGContext?
    {
		return UIGraphicsGetCurrentContext()
	}

    func NSUIGraphicsGetImageFromCurrentImageContext() -> NSUIImage!
    {
		return UIGraphicsGetImageFromCurrentImageContext()
	}

	func NSUIGraphicsPushContext(_ context: CGContext)
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

	func NSUIImagePNGRepresentation(image: NSUIImage) -> Data?
    {
		return UIImagePNGRepresentation(image)
	}

	func NSUIImageJPEGRepresentation(image: NSUIImage, _ quality: CGFloat = 0.8) -> Data?
    {
		return UIImageJPEGRepresentation(image, quality)
	}

	func NSUIMainScreen() -> NSUIScreen?
    {
		return NSUIScreen.main
	}

	func NSUIGraphicsBeginImageContextWithOptions(size: CGSize, _ opaque: Bool, _ scale: CGFloat)
    {
		UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
	}

	extension NSUIFont
    {
		static var nsuiSystemFontSize: CGFloat
        {
			return NSUIFont.systemFontSize
		}
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

	extension NSUIFont
    {
		static var nsuiSystemFontSize: CGFloat
        {
			return NSUIFont.systemFontSize()
		}
	}

	/** On OS X there is no CADisplayLink. Use a 60 fps timer to render the animations. */
	open class NSUIDisplayLink
    {
        private var timer: Timer?
        private var displayLink: CVDisplayLink?
        private var _timestamp: CFTimeInterval = 0.0
        
        private weak var _target: AnyObject?
        private var _selector: Selector
        
        open var timestamp: CFTimeInterval
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

		open func add(to runloop: RunLoop, forMode: RunLoopMode)
        {
            if displayLink != nil
            {
                CVDisplayLinkStart(displayLink!)
            }
            else if timer != nil
            {
                runloop.add(timer!, forMode: forMode)
            }
		}

		open func remove(from runloop: RunLoop, forMode: RunLoopMode)
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
		final func nsuiLocationOf(touch: Int, in: NSView?) -> NSPoint
        {
			return super.location(in: view)
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
        final func nsuiLocationOf(touch: Int, in view: NSView?) -> NSPoint
        {
            return super.location(in: view)
        }
    }

	extension NSView
    {
		final var nsuiGestureRecognizers: [NSGestureRecognizer]?
        {
			return self.gestureRecognizers
		}
	}

	open class NSUIView: NSView
    {
		open override var isFlipped: Bool
        {
			return true
		}

		func setNeedsDisplay()
        {
			self.setNeedsDisplay(self.bounds)
		}

		open override func touchesBegan(with event: NSEvent)
        {
			self.nsuiTouchesBegan(event.touches(matching: .any, in: self), with: event)
		}

		open override func touchesEnded(with event: NSEvent)
        {
			self.nsuiTouchesEnded(event.touches(matching: .any, in: self), with: event)
		}

		open override func touchesMoved(with event: NSEvent)
        {
			self.nsuiTouchesMoved(event.touches(matching: .any, in: self), with: event)
		}

		open override func touchesCancelled(with event: NSEvent)
        {
			self.nsuiTouchesCancelled(event.touches(matching: .any, in: self), with: event)
		}

		open func nsuiTouchesBegan(_ touches: Set<NSUITouch>, with event: NSUIEvent?)
        {
			super.touchesBegan(with: event!)
		}

		open func nsuiTouchesMoved(_ touches: Set<NSUITouch>, with event: NSUIEvent?)
        {
			super.touchesMoved(with: event!)
		}

		open func nsuiTouchesEnded(_ touches: Set<NSUITouch>, with event: NSUIEvent?)
        {
			super.touchesEnded(with: event!)
		}

		open func nsuiTouchesCancelled(_ touches: Set<NSUITouch>?, with event: NSUIEvent?)
        {
			super.touchesCancelled(with: event!)
        }
        
		var backgroundColor: NSUIColor?
        {
            get
            {
                return self.layer?.backgroundColor == nil
                    ? nil
                    : NSColor(cgColor: self.layer!.backgroundColor!)
            }
            set
            {
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

	extension NSTouch
    {
		/** Touch locations on OS X are relative to the trackpad, whereas on iOS they are actually *on* the view. */
		func locationInView(_ view: NSView) -> NSPoint
        {
			let n = self.normalizedPosition
			let b = view.bounds
			return NSPoint(x: b.origin.x + b.size.width * n.x, y: b.origin.y + b.size.height * n.y)
		}
	}

	extension NSScrollView
    {
		var isScrollEnabled: Bool
        {
			get
            {
				return true
			}
            set
            {
                // FIXME: We can't disable scrolling it on OSX
            }
		}
	}

	func NSUIGraphicsGetCurrentContext() -> CGContext?
    {
		return NSGraphicsContext.current()?.cgContext
	}

	func NSUIGraphicsPushContext(_ context: CGContext)
    {
		let address = Unmanaged.passUnretained(context).toOpaque()
		let cx = NSGraphicsContext(graphicsPort: address, flipped: true)
		NSGraphicsContext.saveGraphicsState()
		NSGraphicsContext.setCurrent(cx)
	}

	func NSUIGraphicsPopContext()
    {
		NSGraphicsContext.restoreGraphicsState()
	}

	func NSUIImagePNGRepresentation(image: NSUIImage) -> Data?
    {
		image.lockFocus()
		let rep = NSBitmapImageRep(focusedViewRect: NSMakeRect(0, 0, image.size.width, image.size.height))
		image.unlockFocus()
		return rep?.representation(using: .PNG, properties: [:])
	}

	func NSUIImageJPEGRepresentation(image: NSUIImage, _ quality: CGFloat = 0.9) -> Data?
    {
		image.lockFocus()
		let rep = NSBitmapImageRep(focusedViewRect: NSMakeRect(0, 0, image.size.width, image.size.height))
		image.unlockFocus()
		return rep?.representation(using: .JPEG, properties: [NSImageCompressionFactor: quality])
	}

	private var imageContextStack: [CGFloat] = []

	func NSUIGraphicsBeginImageContextWithOptions(size: CGSize, _ opaque: Bool, _ scale: CGFloat)
    {
		var scale = scale
		if scale == 0.0
        {
			scale = NSScreen.main()?.backingScaleFactor ?? 1.0
		}

		let width = Int(size.width * scale)
		let height = Int(size.height * scale)

		if width > 0 && height > 0
        {
			imageContextStack.append(scale)

			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4*width, space: colorSpace, bitmapInfo: (opaque ?  CGImageAlphaInfo.noneSkipFirst.rawValue : CGImageAlphaInfo.premultipliedFirst.rawValue))
			ctx?.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(height)))
			ctx?.scaleBy(x: scale, y: scale)
			NSUIGraphicsPushContext(ctx!)
		}
	}

	func NSUIGraphicsGetImageFromCurrentImageContext() -> NSUIImage?
    {
		if !imageContextStack.isEmpty
        {
			let ctx = NSUIGraphicsGetCurrentContext()
			let scale = imageContextStack.last!
			if let theCGImage = ctx?.makeImage()
            {
				let size = CGSize(width: CGFloat((ctx?.width)!) / scale, height: CGFloat((ctx?.height)!) / scale)
				let image = NSImage(cgImage: theCGImage, size: size)
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
		return NSUIScreen.main()
	}

	extension NSParagraphStyle
    {
		// This, oddly, is different on iOS (default is a static function on OS X)
		static var `default`: NSParagraphStyle
        {
			return NSParagraphStyle.default()
		}
	}

	extension NSString
    {
		/** On OS X, only size(withAttributes:) exists. It is expected that OSX will catch up and also change to 
		size(attributes:). For now, use this as proxy. */
		@nonobjc func size(attributes: [String: AnyObject]?) -> NSSize
        {
			return self.size(withAttributes: attributes)
		}
	}

#endif
