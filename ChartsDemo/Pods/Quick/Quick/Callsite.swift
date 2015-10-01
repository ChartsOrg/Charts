/**
    An object encapsulating the file and line number at which
    a particular example is defined.
*/
final public class Callsite: NSObject {
    /**
        The absolute path of the file in which an example is defined.
    */
    public let file: String

    /**
        The line number on which an example is defined.
    */
    public let line: UInt

    internal init(file: String, line: UInt) {
        self.file = file
        self.line = line
    }
}

/**
    Returns a boolean indicating whether two Callsite objects are equal.
    If two callsites are in the same file and on the same line, they must be equal.
*/
public func ==(lhs: Callsite, rhs: Callsite) -> Bool {
    return lhs.file == rhs.file && lhs.line == rhs.line
}
