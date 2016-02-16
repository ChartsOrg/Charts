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
	public typealias NSUIPinchGestureRecognizer = UIPinchGestureRecognizer
	public typealias NSUIRotationGestureRecognizer = UIRotationGestureRecognizer
	public typealias NSUIScreen = UIScreen

	public typealias NSUIDisplayLink = CADisplayLink

	public class NSUIView: UIView {
		public final override func touchesBegan(touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
			self.nsuiTouchesBegan(touches, withEvent: event)
		}

		public final override func touchesMoved(touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
			self.nsuiTouchesMoved(touches, withEvent: event)
		}

		public final override func touchesEnded(touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
			self.nsuiTouchesEnded(touches, withEvent: event)
		}

		public final override func touchesCancelled(touches: Set<NSUITouch>?, withEvent event: NSUIEvent?) {
			self.nsuiTouchesCancelled(touches, withEvent: event)
		}

		public func nsuiTouchesBegan(touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
			super.touchesBegan(touches, withEvent: event!)
		}

		public func nsuiTouchesMoved(touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
			super.touchesMoved(touches, withEvent: event!)
		}

		public func nsuiTouchesEnded(touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
			super.touchesEnded(touches, withEvent: event!)
		}

		public func nsuiTouchesCancelled(touches: Set<NSUITouch>?, withEvent event: NSUIEvent?) {
			super.touchesCancelled(touches, withEvent: event!)
		}

		public func nsuiGestureRecognizerShouldBegin(gestureRecognizer: NSUIGestureRecognizer) -> Bool {
			return true
		}

		var nsuiLayer: CALayer? {
			return self.layer
		}
	}

	extension UIView {
		var nsuiGestureRecognizers: [NSUIGestureRecognizer]? {
			return self.gestureRecognizers
		}
	}

	func NSUIGraphicsGetCurrentContext() -> CGContextRef? {
		return UIGraphicsGetCurrentContext()
	}

	func NSUIGraphicsGetImageFromCurrentImageContext() -> NSUIImage! {
		return UIGraphicsGetImageFromCurrentImageContext()
	}

	func NSUIGraphicsPushContext(context: CGContextRef) {
		UIGraphicsPushContext(context)
	}

	func NSUIGraphicsPopContext() {
		UIGraphicsPopContext()
	}

	func NSUIGraphicsEndImageContext() {
		UIGraphicsEndImageContext()
	}

	func NSUIImagePNGRepresentation(image: NSUIImage) -> NSData? {
		return UIImagePNGRepresentation(image)
	}

	func NSUIImageJPEGRepresentation(image: NSUIImage, _ quality: CGFloat = 0.8) -> NSData? {
		return UIImageJPEGRepresentation(image, quality)
	}

	func NSUIMainScreen() -> NSUIScreen? {
		return NSUIScreen.mainScreen()
	}

	func NSUIGraphicsBeginImageContextWithOptions(size: CGSize, _ opaque: Bool, _ scale: CGFloat) {
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
	public typealias NSUIPinchGestureRecognizer = NSPressGestureRecognizer
	public typealias NSUIRotationGestureRecognizer = NSRotationGestureRecognizer
	public typealias NSUIScreen = NSScreen

	/** On OS X there is no CADisplayLink. Use a 60 fps timer to render the animations. */
	public class NSUIDisplayLink {
		let timer: NSTimer

		init(target: AnyObject, selector: Selector) {
			// Set a timer for 60 fps
			timer = NSTimer(timeInterval: 1.0 / 60.0, target: target, selector: selector, userInfo: nil, repeats: true)
		}

		func addToRunLoop(runloop: NSRunLoop, forMode: String) {
			runloop.addTimer(self.timer, forMode: forMode)
		}

		func removeFromRunLoop(runloop: NSRunLoop, forMode: String) {
			self.timer.invalidate()
		}
	}

	/** The 'tap' gesture is mapped to clicks. */
	extension NSUITapGestureRecognizer {
		func numberOfTouches() -> Int {
			return 1
		}

		var numberOfTapsRequired: Int {
			get {
				return self.numberOfClicksRequired
			}
			set {
				self.numberOfClicksRequired = newValue
			}
		}
	}

	extension NSUIPanGestureRecognizer {
		func numberOfTouches() -> Int {
			return 1
		}

		func locationOfTouch(touch: Int, inView: NSView?) -> NSPoint {
			return super.locationInView(inView)
		}
	}

	extension NSUIRotationGestureRecognizer {
		/// FIXME
		var velocity: CGFloat {
			return 0.1
		}
	}

	extension NSView {
		var nsuiGestureRecognizers: [NSGestureRecognizer]? {
			return self.gestureRecognizers
		}
	}

	public class NSUIView: NSView {
		public override var flipped: Bool {
			return true
		}

		func setNeedsDisplay() {
			self.setNeedsDisplayInRect(self.bounds)
		}

		public final override func touchesBeganWithEvent(event: NSEvent) {
			self.nsuiTouchesBegan(event.touchesMatchingPhase(.Any, inView: self), withEvent: event)
		}

		public final override func touchesEndedWithEvent(event: NSEvent) {
			self.nsuiTouchesEnded(event.touchesMatchingPhase(.Any, inView: self), withEvent: event)
		}

		public final override func touchesMovedWithEvent(event: NSEvent) {
			self.nsuiTouchesMoved(event.touchesMatchingPhase(.Any, inView: self), withEvent: event)
		}

		public override func touchesCancelledWithEvent(event: NSEvent) {
			self.nsuiTouchesCancelled(event.touchesMatchingPhase(.Any, inView: self), withEvent: event)
		}

		public func nsuiTouchesBegan(touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
			super.touchesBeganWithEvent(event!)
		}

		public func nsuiTouchesMoved(touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
			super.touchesMovedWithEvent(event!)
		}

		public func nsuiTouchesEnded(touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
			super.touchesEndedWithEvent(event!)
		}

		public func nsuiTouchesCancelled(touches: Set<NSUITouch>?, withEvent event: NSUIEvent?) {
			super.touchesCancelledWithEvent(event!)
		}

		public func nsuiGestureRecognizerShouldBegin(gestureRecognizer: NSUIGestureRecognizer) -> Bool {
			return true
		}

		var backgroundColor: NSUIColor? = NSUIColor.clearColor()

		var nsuiLayer: CALayer? {
			return self.layer
		}
	}

	extension NSFont {
		var lineHeight: CGFloat {
			// Not sure if this is right, but it looks okay
			return self.boundingRectForFont.size.height
		}
	}

	extension NSScreen {
		var scale: CGFloat {
			return self.backingScaleFactor
		}
	}

	extension NSImage {
		var CGImage: CGImageRef? {
			/// FIXME
			return nil
		}
	}

	extension NSTouch {
		/** Touch locations on OS X are relative to the trackpad, whereas on iOS they are actually *on* the view. */
		func locationInView(view: NSView) -> NSPoint {
			let n = self.normalizedPosition
			let b = view.bounds
			return NSPoint(x: b.origin.x + b.size.width * n.x, y: b.origin.y + b.size.height * n.y)
		}
	}

	extension NSScrollView {
		/// FIXME
		var scrollEnabled: Bool {
			get {
				return true
			}
			set {
				// Do nothing
			}
		}
	}

	func NSUIGraphicsGetCurrentContext() -> CGContextRef? {
		return NSGraphicsContext.currentContext()?.CGContext
	}

	func NSUIGraphicsPushContext(context: CGContextRef) {
		let address = unsafeAddressOf(context)
		let ptr: UnsafeMutablePointer<CGContext> = UnsafeMutablePointer(UnsafePointer<CGContext>(address))
		let cx = NSGraphicsContext(graphicsPort: ptr, flipped: true)
		NSGraphicsContext.saveGraphicsState()
		NSGraphicsContext.setCurrentContext(cx)
	}

	func NSUIGraphicsPopContext() {
		NSGraphicsContext.restoreGraphicsState()
	}

	func NSUIImagePNGRepresentation(image: NSUIImage) -> NSData? {
		image.lockFocus()
		let rep = NSBitmapImageRep(focusedViewRect: NSMakeRect(0, 0, image.size.width, image.size.height))
		image.unlockFocus()
		return rep?.representationUsingType(.NSPNGFileType, properties: [:])
	}

	func NSUIImageJPEGRepresentation(image: NSUIImage, _ quality: CGFloat = 0.9) -> NSData? {
		image.lockFocus()
		let rep = NSBitmapImageRep(focusedViewRect: NSMakeRect(0, 0, image.size.width, image.size.height))
		image.unlockFocus()
		return rep?.representationUsingType(.NSJPEGFileType, properties: [NSImageCompressionFactor: quality])
	}

	private var imageContextStack: [CGFloat] = []

	func NSUIGraphicsBeginImageContextWithOptions(size: CGSize, _ opaque: Bool, _ scale: CGFloat) {
		var scale = scale
		if scale == 0.0 {
			scale = NSScreen.mainScreen()?.backingScaleFactor ?? 1.0
		}

		let width = Int(size.width * scale)
		let height = Int(size.height * scale)

		if width > 0 && height > 0 {
			imageContextStack.append(scale)

			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let ctx = CGBitmapContextCreate(nil, width, height, 8, 4*width, colorSpace, (opaque ?  CGImageAlphaInfo.NoneSkipFirst.rawValue : CGImageAlphaInfo.PremultipliedFirst.rawValue))
			CGContextConcatCTM(ctx, CGAffineTransformMake(1, 0, 0, -1, 0, CGFloat(height)))
			CGContextScaleCTM(ctx, scale, scale)
			NSUIGraphicsPushContext(ctx!)
		}
	}

	func NSUIGraphicsGetImageFromCurrentImageContext() -> NSUIImage? {
		if !imageContextStack.isEmpty {
			let ctx = NSUIGraphicsGetCurrentContext()
			let scale = imageContextStack.last!
			if let theCGImage = CGBitmapContextCreateImage(ctx) {
				let size = CGSizeMake(CGFloat(CGBitmapContextGetWidth(ctx)) / scale, CGFloat(CGBitmapContextGetHeight(ctx)) / scale)
				let image = NSImage(CGImage: theCGImage, size: size)
				return image
			}
		}
		return nil
	}

	func NSUIGraphicsEndImageContext() {
		if imageContextStack.last != nil {
			imageContextStack.removeLast()
			NSUIGraphicsPopContext()
		}
	}

	func NSUIMainScreen() -> NSUIScreen? {
		return NSUIScreen.mainScreen()
	}

#endif