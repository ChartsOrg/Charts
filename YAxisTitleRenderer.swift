//
//  YAxisRendererRadarChart.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class YAxisTitleRenderer: YAxisRenderer {
    
    private let titleLabelPadding: CGFloat = 10
    open var title: String? = "Bar X Title"
    open var titleFont: UIFont?
    
    open override func renderAxisLabels(context: CGContext) {
        super.renderAxisLabels(context: context)
        guard let title = title else {
            return
        }
        let attributes: [NSAttributedString.Key: Any] = [
            .font: titleFont ?? axis.labelFont,
            .foregroundColor: axis.labelTextColor
        ]
        
        
        renderTitle(title: title,
                    attributes: attributes,
                    inContext: context,
                    x: titleLabelPadding)
    }
    
    func renderTitle(title: String,
                     attributes: [NSAttributedString.Key: Any],
                     inContext context: CGContext,
                     x: CGFloat) {
 
        
        // Determine the chart title's y-position.
        let titleSize = title.size(withAttributes: attributes)
        let verticalTitleSize = CGSize(width: titleSize.height, height: titleSize.width)
        let point = CGPoint(x: x, y: (viewPortHandler.chartHeight - verticalTitleSize.height) / 2)
        
        // Render the chart title.
        context.drawText(title,
                         at: point,
                         anchor: .zero,
                         angleRadians: .pi / -2,
                         attributes: attributes)
        
    }
}
