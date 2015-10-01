import Foundation

// Memoizes the given closure, only calling the passed
// closure once; even if repeat calls to the returned closure
internal func memoizedClosure<T>(closure: () throws -> T) -> (Bool) throws -> T {
    var cache: T?
    return ({ withoutCaching in
        if (withoutCaching || cache == nil) {
            cache = try closure()
        }
        return cache!
    })
}

/// Expression represents the closure of the value inside expect(...).
/// Expressions are memoized by default. This makes them safe to call
/// evaluate() multiple times without causing a re-evaluation of the underlying
/// closure.
///
/// @warning Since the closure can be any code, Objective-C code may choose
///          to raise an exception. Currently, Expression does not memoize
///          exception raising.
///
/// This provides a common consumable API for matchers to utilize to allow
/// Nimble to change internals to how the captured closure is managed.
public struct Expression<T> {
    internal let _expression: (Bool) throws -> T?
    internal let _withoutCaching: Bool
    public let location: SourceLocation
    public let isClosure: Bool

    /// Creates a new expression struct. Normally, expect(...) will manage this
    /// creation process. The expression is memoized.
    ///
    /// @param expression The closure that produces a given value.
    /// @param location The source location that this closure originates from.
    /// @param isClosure A bool indicating if the captured expression is a
    ///                  closure or internally produced closure. Some matchers
    ///                  may require closures. For example, toEventually()
    ///                  requires an explicit closure. This gives Nimble
    ///                  flexibility if @autoclosure behavior changes between
    ///                  Swift versions. Nimble internals always sets this true.
    public init(expression: () throws -> T?, location: SourceLocation, isClosure: Bool = true) {
        self._expression = memoizedClosure(expression)
        self.location = location
        self._withoutCaching = false
        self.isClosure = isClosure
    }

    /// Creates a new expression struct. Normally, expect(...) will manage this
    /// creation process.
    ///
    /// @param expression The closure that produces a given value.
    /// @param location The source location that this closure originates from.
    /// @param withoutCaching Indicates if the struct should memoize the given
    ///                       closure's result. Subsequent evaluate() calls will
    ///                       not call the given closure if this is true.
    /// @param isClosure A bool indicating if the captured expression is a
    ///                  closure or internally produced closure. Some matchers
    ///                  may require closures. For example, toEventually()
    ///                  requires an explicit closure. This gives Nimble
    ///                  flexibility if @autoclosure behavior changes between
    ///                  Swift versions. Nimble internals always sets this true.
    public init(memoizedExpression: (Bool) throws -> T?, location: SourceLocation, withoutCaching: Bool, isClosure: Bool = true) {
        self._expression = memoizedExpression
        self.location = location
        self._withoutCaching = withoutCaching
        self.isClosure = isClosure
    }

    /// Returns a new Expression from the given expression. Identical to a map()
    /// on this type. This should be used only to typecast the Expression's
    /// closure value.
    ///
    /// The returned expression will preserve location and isClosure.
    ///
    /// @param block The block that can cast the current Expression value to a
    ///              new type.
    public func cast<U>(block: (T?) throws -> U?) -> Expression<U> {
        return Expression<U>(expression: ({ try block(self.evaluate()) }), location: self.location, isClosure: self.isClosure)
    }

    public func evaluate() throws -> T? {
        return try self._expression(_withoutCaching)
    }

    public func withoutCaching() -> Expression<T> {
        return Expression(memoizedExpression: self._expression, location: location, withoutCaching: true, isClosure: isClosure)
    }
}
