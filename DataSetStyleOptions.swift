//
//  DataSetStyleOptions.swift
//  Charts
//
//  Created by Jacob Christie on 2018-03-19.
//

import Foundation

public protocol DataSetStyleOptions {

    /// List representing all colors that are used for drawing the actual values for this DataSet
    var valueColors: [NSUIColor] { get }

    /// All the colors that are used for this DataSet.
    /// Colors are reused as soon as the number of Entries the DataSet represents is higher than the size of the colors array.
    var colors: [NSUIColor] { get set }

    /// - returns: The color at the given index of the DataSet's color array.
    /// This prevents out-of-bounds by performing a modulus on the color index, so colours will repeat themselves.
    func color(at index: Int) -> NSUIColor

    /// Resets all colors of this DataSet and recreates the colors array.
    mutating func resetColors()

    /// Adds a new color to the colors array of the DataSet.
    /// - parameter color: the color to add
    mutating func addColor(_ color: NSUIColor)

    /// Sets the one and **only** color that should be used for this DataSet.
    /// Internally, this recreates the colors array and adds the specified color.
    /// - parameter color: the color to set
    mutating func setColor(_ color: NSUIColor)

    /// Offset of icons drawn on the chart.
    ///
    /// For all charts except Pie and Radar it will be ordinary (x offset, y offset).
    ///
    /// For Pie and Radar chart it will be (y offset, distance from center offset); so if you want icon to be rendered under value, you should increase X component of CGPoint, and if you want icon to be rendered closest to center, you should decrease y component of CGPoint.
    var iconsOffset: CGPoint { get set }

    /// Custom formatter that is used instead of the auto-formatter if set
    var valueFormatter: ValueFormatter { get set }

    /// Sets/get a single color for value text.
    /// Setting the color clears the colors array and adds a single color.
    /// Getting will return the first color in the array.
    var valueTextColor: NSUIColor { get set }

    /// - returns: The color at the specified index that is used for drawing the values inside the chart. Uses modulus internally.
    func valueTextColor(at index: Int) -> NSUIColor

    /// the font for the value-text labels
    var valueFont: NSUIFont { get set }

    /// The form to draw for this dataset in the legend.
    ///
    /// Return `.Default` to use the default legend form.
    var form: Legend.Form { get }

    /// The form size to draw for this dataset in the legend.
    ///
    /// Return `NaN` to use the default legend form size.
    var formSize: CGFloat { get }

    /// The line width for drawing the form of this dataset in the legend
    ///
    /// Return `NaN` to use the default legend form line width.
    var formLineWidth: CGFloat { get }

    /// Line dash configuration for legend shapes that consist of lines.
    ///
    /// This is how much (in pixels) into the dash pattern are we starting from.
    var formLineDashPhase: CGFloat { get }

    /// Line dash configuration for legend shapes that consist of lines.
    ///
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    var formLineDashLengths: [CGFloat]? { get }
}

extension DataSetStyleOptions {

    func color(at index: Int) -> NSUIColor {
        return colors[index % colors.count]
    }

    mutating func resetColors() {
        colors.removeAll()
    }

    mutating func addColor(_ color: NSUIColor) {
        colors.append(color)
    }

    mutating func setColor(_ color: NSUIColor) {
        colors.removeAll()
        colors.append(color)
    }

    func valueTextColor(at index: Int) -> NSUIColor {
        return valueColors[index % valueColors.count]
    }
}
