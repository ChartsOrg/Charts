//
//  DataSetProtocol.swift
//  Charts
//
//  Created by Jacob Christie on 2018-03-18.
//

import Foundation

public protocol DataSetProtocol: Collection, ExpressibleByArrayLiteral where Element: DataEntryProtocol, Index == Int {

    associatedtype Backing: Collection where Backing.Element == Element
    associatedtype Style: DataSetStyleOptions
    associatedtype DrawingOptions: DataSetDrawingOptions

    var elements: Backing { get set }

    /// Use this method to tell the data set that the underlying data has changed
    mutating func notifyDataSetChanged()

    /// Calculates the minimum and maximum x and y values (_xMin, _xMax, _yMin, yMax).
    func calcMinMax()

    /// Calculates the min and max y-values from the Entry closest to the given fromX to the Entry closest to the given toX value.
    /// This is only needed for the autoScaleMinMax feature.
    func calcMinMaxY(fromX: Double, toX: Double)

    /// - returns: The minimum y-value this DataSet holds
    var yMin: Double { get set }

    /// - returns: The maximum y-value this DataSet holds
    var yMax: Double { get set }

    /// - returns: The number of y-values this DataSet represents
    var count: Int { get }

    /// - returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specified x-value is found, this method returns the Entry at the closest x-value according to the rounding.
    /// nil if no Entry object at that x-value.
    /// - parameter xValue: the x-value
    /// - parameter closestToY: If there are multiple y-values for the specified x-value,
    /// - parameter rounding: determine whether to round up/down/closest if there is no Entry matching the provided x-value
    func entry(forXValue xValue: Double,
               closestToY yValue: Double,
               rounding: ChartDataSetRounding) -> ChartDataEntry?

    /// - returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specified x-value is found, this method returns the Entry at the closest x-value.
    /// nil if no Entry object at that x-value.
    /// - parameter xValue: the x-value
    /// - parameter closestToY: If there are multiple y-values for the specified x-value,
    func entry(forXValue xValue: Double,
               closestToY yValue: Double) -> ChartDataEntry?

    /// - returns: All Entry objects found at the given x-value with binary search.
    /// An empty array if no Entry object at that x-value.
    func entries(forXValue xValue: Double) -> [ChartDataEntry]

    /// - returns: The array-index of the specified entry.
    /// If the no Entry at the specified x-value is found, this method returns the index of the Entry at the closest x-value according to the rounding.
    ///
    /// - parameter xValue: x-value of the entry to search for
    /// - parameter closestToY: If there are multiple y-values for the specified x-value,
    /// - parameter rounding: Rounding method if exact value was not found
    func entryIndex(x xValue: Double,
                    closestToY yValue: Double,
                    rounding: ChartDataSetRounding) -> Int

    /// Returns the first index where the specified value appears in the collection.
    ///
    /// - Complexity: O(_log(n)_), where _n_ is the size of the array.
    func index(of element: Element) -> Index?

    /// Adds an Entry to the DataSet dynamically.
    ///
    /// *optional feature, can return `false` ifnot implemented*
    ///
    /// Entries are added to the end of the list.
    /// - parameter e: the entry to add
    /// - returns: `true` if the entry was added successfully, `false` ifthis feature is not supported
    func addEntry(_ e: ChartDataEntry) -> Bool

    /// Inserts a new element into the array, preserving the sort order.
    ///
    /// - Returns: the index where the new element was inserted.
    /// - Complexity: O(_n_) where _n_ is the size of the array. O(_log n_) if the new
    /// element can be appended, i.e. if it is ordered last in the resulting array.
    @discardableResult
    mutating func insert(_ newElement: Element) -> Index

    /// Inserts all elements from `elements` into `self`, preserving the sort order.
    ///
    /// This can be faster than inserting the individual elements one after another because
    /// we only need to re-sort once.
    ///
    /// - Complexity: O(_n * log(n)_) where _n_ is the size of the resulting array.
    mutating func insert<S: Sequence>(contentsOf newElements: S) where S.Iterator.Element == Element

    /// Removes and returns the element at the specified position.
    ///
    /// - Parameter index: The position of the element to remove. `index` must be a valid index of the array.
    /// - Returns: The element at the specified index.
    /// - Complexity: O(_n_), where _n_ is the length of the array.
    @discardableResult
    mutating func remove(at index: Int) -> Element

    /// Removes the elements in the specified subrange from the array.
    ///
    /// - Parameter bounds: The range of the array to be removed. The
    ///   bounds of the range must be valid indices of the array.
    ///
    /// - Complexity: O(_n_), where _n_ is the length of the array.
    mutating func removeSubrange(_ bounds: Range<Int>)

    /// Removes the elements in the specified subrange from the array.
    ///
    /// - Parameter bounds: The range of the array to be removed. The
    ///   bounds of the range must be valid indices of the array.
    ///
    /// - Complexity: O(_n_), where _n_ is the length of the array.
    mutating func removeSubrange(_ bounds: ClosedRange<Int>)

    /// Removes the elements in the specified subrange from the array.
    ///
    /// - Parameter bounds: The range of the array to be removed. The
    ///   bounds of the range must be valid indices of the array.
    ///
    /// - Complexity: O(_n_), where _n_ is the length of the array.
    mutating func removeSubrange(_ bounds: CountableRange<Int>)

    /// Removes the elements in the specified subrange from the array.
    ///
    /// - Parameter bounds: The range of the array to be removed. The
    ///   bounds of the range must be valid indices of the array.
    ///
    /// - Complexity: O(_n_), where _n_ is the length of the array.
    mutating func removeSubrange(_ bounds: CountableClosedRange<Int>)

    /// Removes the specified number of elements from the beginning of the
    /// array.
    ///
    /// - Parameter n: The number of elements to remove from the array.
    ///   `n` must be greater than or equal to zero and must not exceed the
    ///   number of elements in the array.
    ///
    /// - Complexity: O(_n_), where _n_ is the length of the array.
    mutating func removeFirst(_ n: Int)

    /// Removes and returns the first element of the array.
    ///
    /// - Precondition: The array must not be empty.
    /// - Returns: The removed element.
    /// - Complexity: O(_n_), where _n_ is the length of the collection.
    @discardableResult
    mutating func removeFirst() -> Element

    /// Removes and returns the last element of the array.
    ///
    /// - Precondition: The collection must not be empty.
    /// - Returns: The last element of the collection.
    /// - Complexity: O(1)
    @discardableResult
    mutating func removeLast() -> Element

    /// Removes the given number of elements from the end of the array.
    ///
    /// - Parameter n: The number of elements to remove. `n` must be greater
    ///   than or equal to zero, and must be less than or equal to the number of
    ///   elements in the array.
    /// - Complexity: O(1).
    mutating func removeLast(_ n: Int)

    /// Removes all elements from the array.
    ///
    /// - Parameter keepCapacity: Pass `true` to keep the existing capacity of
    ///   the array after removing its elements. The default value is `false`.
    ///
    /// - Complexity: O(_n_), where _n_ is the length of the array.
    mutating func removeAll(keepingCapacity keepCapacity: Bool)

    /// Removes an element from the array. If the array contains multiple
    /// instances of `element`, this method only removes the first one.
    ///
    /// - Complexity: O(_n_), where _n_ is the size of the array.
    mutating func remove(_ element: Element)

    /// Removes the Entry object closest to the given x-value from the DataSet.
    ///
    /// *optional feature, can return `false` ifnot implemented*
    ///
    /// - parameter x: the x-value to remove
    /// - returns: `true` if the entry was removed successfully, `false` ifthe entry does not exist or if this feature is not supported
    func removeEntry(x: Double) -> Bool

    /// Removes the first Entry (at index 0) of this DataSet from the entries array.
    ///
    /// *optional feature, can return `false` ifnot implemented*
    ///
    /// - returns: `true` if the entry was removed successfully, `false` ifthe entry does not exist or if this feature is not supported
    func removeFirst() -> Bool

    /// Removes the last Entry (at index 0) of this DataSet from the entries array.
    ///
    /// *optional feature, can return `false` ifnot implemented*
    ///
    /// - returns: `true` if the entry was removed successfully, `false` ifthe entry does not exist or if this feature is not supported
    func removeLast() -> Bool

    /// Checks if this DataSet contains the specified Entry.
    ///
    /// - returns: `true` if contains the entry, `false` ifnot.
    func contains(_ element: Element) -> Bool

    // MARK: - Styling functions and accessors

    /// The label string that describes the DataSet.
    var label: String? { get }

    var style: Style { get set }

    var drawingOptions: DrawingOptions { get set }
}

// MARK: - SortedArray

extension DataSetProtocol where Backing == SortedArray<Element> {

    public var xMin: Double {
        return elements.first?.x ?? .greatestFiniteMagnitude
    }

    public var xMax: Double {
        return elements.last?.x ?? -.greatestFiniteMagnitude
    }

    public mutating func notifyDataSetChanged() {
        calcMinMax()
    }

    
    @discardableResult
    public mutating func insert(_ newElement: Element) -> Index {
        return elements.insert(newElement)
    }

    public mutating func insert<S: Sequence>(contentsOf newElements: S) where S.Iterator.Element == Element {
        elements.insert(contentsOf: newElements)
    }

    public var startIndex: Index {
        return elements.startIndex
    }

    public var endIndex: Index {
        return elements.endIndex
    }

    public subscript(index: Index) -> Element {
        get {
            return elements[index]
        }
    }

    public func index(after i: Index) -> Index {
        return elements.index(after: i)
    }

    public func index(before i: Index) -> Index {
        return elements.index(before: i)
    }

    public func index(of element: Element) -> Index? {
        return elements.index(of: element)
    }

    /// Returns a Boolean value indicating whether the sequence contains the given element.
    ///
    /// - Complexity: O(_log(n)_), where _n_ is the size of the array.
    public func contains(_ element: Element) -> Bool {
        return elements.contains(element)
    }


    // MARK: - SortedArray: Removing Elements

    @discardableResult
    public mutating func remove(at index: Int) -> Element {
        return elements.remove(at: index)
    }

    public mutating func removeSubrange(_ bounds: Range<Int>) {
        elements.removeSubrange(bounds)
    }

    public mutating func removeSubrange(_ bounds: ClosedRange<Int>) {
        elements.removeSubrange(bounds)
    }

    public mutating func removeSubrange(_ bounds: CountableRange<Int>) {
        elements.removeSubrange(bounds)
    }

    public mutating func removeSubrange(_ bounds: CountableClosedRange<Int>) {
        elements.removeSubrange(bounds)
    }

    public mutating func removeFirst(_ n: Int) {
        elements.removeFirst(n)
    }

    @discardableResult
    public mutating func removeFirst() -> Element {
        return elements.removeFirst()
    }

    @discardableResult
    public mutating func removeLast() -> Element {
        return elements.removeLast()
    }

    public mutating func removeLast(_ n: Int) {
        elements.removeLast(n)
    }

    public mutating func removeAll(keepingCapacity keepCapacity: Bool = true) {
        elements.removeAll(keepingCapacity: keepCapacity)
    }

    public mutating func remove(_ element: Element) {
        guard let index = index(of: element) else { return }
        elements.remove(at: index)
    }

    // TODO:
    func removeEntry(x: Double) -> Bool {
        return false
    }
}
