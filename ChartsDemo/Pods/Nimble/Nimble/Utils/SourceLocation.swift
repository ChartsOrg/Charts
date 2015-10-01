import Foundation


public class SourceLocation : NSObject {
    public let file: String
    public let line: UInt

    override init() {
        file = "Unknown File"
        line = 0
    }

    init(file: String, line: UInt) {
        self.file = file
        self.line = line
    }

    override public var description: String {
        return "\(file):\(line)"
    }
}
