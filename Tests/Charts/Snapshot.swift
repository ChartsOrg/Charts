import CoreGraphics

public struct Snapshot
{
    public static let tolerance: CGFloat = 0.01
    
    public static func identifier(_ size: CGSize) -> String {
        #if os(tvOS)
        let identifier = "tvOS"
        #elseif os(iOS)
        let identifier = "iOS"
        #elseif os(OSX)
        let identifier = "macOS"
        #else
        let identifier = ""
        #endif
        
        return "\(identifier)_\(size.width)_\(size.height)"
    }
}
