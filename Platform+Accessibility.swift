import Foundation

#if os(iOS) || os(tvOS)

internal func accessibilityPostLayoutChangedNotification(withElement element: Any? = nil)
{
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, element)
}

internal func accessibilityPostScreenChangedNotification(withElement element: Any? = nil)
{
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, element)
}

open class NSUIAccessibilityElement: UIAccessibilityElement
{
    private let containerView: UIView

    final var isHeader: Bool = false
    {
        didSet
        {
            accessibilityTraits = isHeader ? UIAccessibilityTraitHeader : UIAccessibilityTraitNone
        }
    }

    final var isSelected: Bool = false
        {
        didSet
        {
            accessibilityTraits = isSelected ? UIAccessibilityTraitSelected : UIAccessibilityTraitNone
        }
    }

    override init(accessibilityContainer container: Any)
    {
        // We can force unwrap since all chart views are subclasses of UIView
        containerView = container as! UIView
        super.init(accessibilityContainer: container)
    }

    override open var accessibilityFrame: CGRect
    {
        get
        {
            return super.accessibilityFrame
        }

        set
        {
            super.accessibilityFrame = containerView.convert(newValue, to: UIScreen.main.coordinateSpace)
        }
    }
}

extension NSUIView
{
    /// An array of accessibilityElements that is used to implement UIAccessibilityContainer internally.
    /// Subclasses **MUST** override this with an array of such elements.
    @objc open func accessibilityChildren() -> [Any]?
    {
        return nil
    }

    public final override var isAccessibilityElement: Bool
    {
        get { return false } // Return false here, so we can make individual elements accessible
        set { }
    }

    open override func accessibilityElementCount() -> Int
    {
        return accessibilityChildren()?.count ?? 0
    }

    open override func accessibilityElement(at index: Int) -> Any?
    {
        return accessibilityChildren()?[index]
    }

    open override func index(ofAccessibilityElement element: Any) -> Int
    {
        guard let axElement = element as? NSUIAccessibilityElement else { return -1 }
        return (accessibilityChildren() as? [NSUIAccessibilityElement])?.index(of: axElement) ?? -1
    }
}

#endif

#if os(OSX)

internal func accessibilityPostLayoutChangedNotification(withElement element: Any? = nil)
{
    guard let validElement = element else { return }
    NSAccessibilityPostNotification(validElement, .layoutChanged)
}

internal func accessibilityPostScreenChangedNotification(withElement element: Any? = nil)
{
    // Placeholder
}

open class NSUIAccessibilityElement: NSAccessibilityElement
{
    private let containerView: NSView

    final var isHeader: Bool = false
    {
        didSet
        {
            setAccessibilityRole(isHeader ? .staticText : .none)
        }
    }

    // TODO: Make isSelected toggle a selected state in conjunction with a .valueChanged notification
    /// A placeholder for parity with iOS. Has no effect.
    final var isSelected: Bool = false

    open var accessibilityLabel: String
    {
        get
        {
            return accessibilityLabel() ?? ""
        }

        set
        {
            setAccessibilityLabel(newValue)
        }
    }

    open var accessibilityFrame: NSRect
    {
        get
        {
            return accessibilityFrame()
        }

        set
        {
            let bounds = NSAccessibilityFrameInView(containerView, newValue)
            setAccessibilityFrame(bounds)
        }
    }

    init(accessibilityContainer container: Any)
    {
        // We can force unwrap since all chart views are subclasses of NSView
        containerView = container as! NSView

        super.init()

        setAccessibilityParent(containerView)
        setAccessibilityRole(.row)
    }

    open override func accessibilityParent() -> Any?
    {
        return super.accessibilityParent()
    }
}

/*
/// This would have been needed if the NSAccessibilityList protocol worked.
extension NSUIAccessibilityElement: NSAccessibilityRow
{
    open override func accessibilityChildren() -> [Any]?
    {
        return nil
    }

    open override func accessibilityIdentifier() -> String
    {
        return super.accessibilityIdentifier() ?? ""
    }

    open override func accessibilityIndex() -> Int
    {
        guard let parentChartView = containerView as? ChartViewBase else { return -1 }
        return (parentChartView.accessibilityChildren() as? [NSUIAccessibilityElement])?.index(of: self) ?? -1
    }
}
*/

/// NOTE: Using Swift makes all NSAccessibility methods required
/// Since the method signatures for accessibilityRows() differ between the NSAccessibilityTable and NSAccessibility protocols,
/// trying to override or create either causes a compiler error. Hence we resort to calling setAccessibilityRole(.list)
/// while making NSUIView an NSAccessibilityGroup.
extension NSUIView: NSAccessibilityGroup
{
    open override func accessibilityChildren() -> [Any]?
    {
        return nil
    }

    open override func accessibilityLabel() -> String?
    {
        return "Chart View"
    }

    open override func accessibilityRows() -> [Any]?
    {
        return accessibilityChildren()
    }
}

#endif
