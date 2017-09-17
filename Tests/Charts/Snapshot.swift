import CoreGraphics

public struct Snapshot
{
    public static let tolerance: CGFloat = 0.03
    
    public static func identifier(_ size: CGSize) -> String {
        
        let identifier: String
        
        #if os(tvOS)
            identifier = "tvOS"
        #elseif os(iOS)
            identifier = "iOS"
        #elseif os(OSX)
            identifier = "macOS"
        #else
            identifier = ""
        #endif
        
        return "\(identifier)_\(size.width)_\(size.height)"
    }
}
