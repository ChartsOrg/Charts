//
//  TransformerHorizontalBarChart.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

@objc(ChartTransformerHorizontalBarChart)
public class TransformerHorizontalBarChart: Transformer
{
    /// Prepares the matrix that contains all offsets.
    public override func prepareMatrixOffset(inverted: Bool)
    {
        if (!inverted)
        {
            _matrixOffset = CGAffineTransformMakeTranslation(_viewPortHandler.offsetLeft, _viewPortHandler.chartHeight - _viewPortHandler.offsetBottom)
        }
        else
        {
            _matrixOffset = CGAffineTransformMakeScale(-1.0, 1.0)
            _matrixOffset = CGAffineTransformTranslate(_matrixOffset,
                -(_viewPortHandler.chartWidth - _viewPortHandler.offsetRight),
                _viewPortHandler.chartHeight - _viewPortHandler.offsetBottom)
        }
    }
}