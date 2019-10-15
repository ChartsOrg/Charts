import Foundation

#if canImport(UIKit)
import UIKit

internal func accessibilityPostLayoutChangedNotification(withElement element: Any? = nil)
{
    UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: element)
}

internal func accessibilityPostScreenChangedNotification(withElement element: Any? = nil)
{
    UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: element)
}

/// A simple abstraction over UIAccessibilityElement and NSAccessibilityElement.
open class NSUIAccessibilityElement: UIAccessibilityElement
{
    private weak var containerView: UIView?

    final var isHeader: Bool = false
    {
        didSet { accessibilityTraits = isHeader ? .header : .none }
    }

    final var isSelected: Bool = false
    {
        didSet { accessibilityTraits = isSelected ? .selected : .none }
    }

    override public init(accessibilityContainer container: Any)
    {
        // We can force unwrap since all chart views are subclasses of UIView
        containerView = (container as! UIView)
        super.init(accessibilityContainer: container)
    }

    override open var accessibilityFrame: CGRect
    {
        get { super.accessibilityFrame }
        set
        {
            guard let containerView = containerView else { return }
            super.accessibilityFrame = containerView.convert(newValue, to: UIScreen.main.coordinateSpace)
        }
    }
}

extension View
{
    /// An array of accessibilityElements that is used to implement UIAccessibilityContainer internally.
    /// Subclasses **MUST** override this with an array of such elements.
    @objc
    open func accessibilityChildren() -> [Any]? { nil }

    public final override var isAccessibilityElement: Bool
    {
        get { return false } // Return false here, so we can make individual elements accessible
        set { }
    }

    open override func accessibilityElementCount() -> Int
    {
        accessibilityChildren()?.count ?? 0
    }

    open override func accessibilityElement(at index: Int) -> Any?
    {
        accessibilityChildren()?[index]
    }

    open override func index(ofAccessibilityElement element: Any) -> Int
    {
        guard let axElement = element as? NSUIAccessibilityElement else { return NSNotFound }
        return (accessibilityChildren() as? [NSUIAccessibilityElement])?
            .firstIndex(of: axElement) ?? NSNotFound
    }
}

#endif

#if canImport(AppKit)
import AppKit

internal func accessibilityPostLayoutChangedNotification(withElement element: Any? = nil)
{
    guard let validElement = element else { return }
    NSAccessibility.post(element: validElement, notification: .layoutChanged)
}

internal func accessibilityPostScreenChangedNotification(withElement element: Any? = nil)
{
    // Placeholder
}

/// A simple abstraction over UIAccessibilityElement and NSAccessibilityElement.
open class NSUIAccessibilityElement: NSAccessibilityElement
{
    private weak var containerView: NSView?

    final var isHeader: Bool = false
    {
        didSet { setAccessibilityRole(isHeader ? .staticText : .none) }
    }

    final var isSelected: Bool = false
    {
        didSet { setAccessibilitySelected(isSelected) }
    }

    open var accessibilityLabel: String
    {
        get { accessibilityLabel() ?? "" }
        set { setAccessibilityLabel(newValue) }
    }

    open var accessibilityFrame: NSRect
    {
        get { accessibilityFrame() }
        set
        {
            guard let containerView = containerView else { return }

            let bounds = NSAccessibility.screenRect(fromView: containerView, rect: newValue)

            // This works, but won't auto update if the window is resized or moved.
            // setAccessibilityFrame(bounds)

            // using FrameInParentSpace allows for automatic updating of frame when windows are moved and resized.
            // However, there seems to be a bug right now where using it causes an offset in the frame.
            // This is a slightly hacky workaround that calculates the offset and removes it from frame calculation.
            setAccessibilityFrameInParentSpace(bounds)
            let axFrame = accessibilityFrame()
            let widthOffset = abs(axFrame.origin.x - bounds.origin.x)
            let heightOffset = abs(axFrame.origin.y - bounds.origin.y)
            let rect = NSRect(x: bounds.origin.x - widthOffset,
                              y: bounds.origin.y - heightOffset,
                              width: bounds.width,
                              height: bounds.height)
            setAccessibilityFrameInParentSpace(rect)
        }
    }

    public init(accessibilityContainer container: Any)
    {
        // We can force unwrap since all chart views are subclasses of NSView
        containerView = (container as! NSView)

        super.init()

        setAccessibilityParent(containerView)
        setAccessibilityRole(.row)
    }
}

/// - Note: setAccessibilityRole(.list) is called at init. See Platform.swift.
extension View: NSAccessibilityGroup
{
    open override func accessibilityLabel() -> String?
    {
        "Chart View"
    }

    open override func accessibilityRows() -> [Any]?
    {
        accessibilityChildren()
    }
}

#endif
