//
//  Enums.h
//  Charts
//
//  Created by Pierre-Marc Airoldi on 2015-03-31.
//  Copyright (c) 2015 dcg. All rights reserved.
//

#ifndef Charts_Enums_h
#define Charts_Enums_h

typedef NS_ENUM(NSInteger, ChartEasingOption) {
    ChartEasingOptionLinear,
    ChartEasingOptionEaseInQuad,
    ChartEasingOptionEaseOutQuad,
    ChartEasingOptionEaseInOutQuad,
    ChartEasingOptionEaseInCubic,
    ChartEasingOptionEaseOutCubic,
    ChartEasingOptionEaseInOutCubic,
    ChartEasingOptionEaseInQuart,
    ChartEasingOptionEaseOutQuart,
    ChartEasingOptionEaseInOutQuart,
    ChartEasingOptionEaseInQuint,
    ChartEasingOptionEaseOutQuint,
    ChartEasingOptionEaseInOutQuint,
    ChartEasingOptionEaseInSine,
    ChartEasingOptionEaseOutSine,
    ChartEasingOptionEaseInOutSine,
    ChartEasingOptionEaseInExpo,
    ChartEasingOptionEaseOutExpo,
    ChartEasingOptionEaseInOutExpo,
    ChartEasingOptionEaseInCirc,
    ChartEasingOptionEaseOutCirc,
    ChartEasingOptionEaseInOutCirc,
    ChartEasingOptionEaseInElastic,
    ChartEasingOptionEaseOutElastic,
    ChartEasingOptionEaseInOutElastic,
    ChartEasingOptionEaseInBack,
    ChartEasingOptionEaseOutBack,
    ChartEasingOptionEaseInOutBack,
    ChartEasingOptionEaseInBounce,
    ChartEasingOptionEaseOutBounce,
    ChartEasingOptionEaseInOutBounce,
};

typedef NS_ENUM(NSInteger, ApproximatorType) {
    ApproximatorTypeNone,
    ApproximatorTypeRamerDouglasPeucker
};

typedef NS_ENUM(NSInteger, ChartLegendPosition) {
    ChartLegendPositionRightOfChart,
    ChartLegendPositionRightOfChartCenter,
    ChartLegendPositionRightOfChartInside,
    ChartLegendPositionLeftOfChart,
    ChartLegendPositionLeftOfChartCenter,
    ChartLegendPositionLeftOfChartInside,
    ChartLegendPositionBelowChartLeft,
    ChartLegendPositionBelowChartRight,
    ChartLegendPositionBelowChartCenter,
    ChartLegendPositionPiechartCenter,
};

typedef NS_ENUM(NSInteger, ChartLegendForm) {
    ChartLegendFormSquare,
    ChartLegendFormCircle,
    ChartLegendFormLine
};

typedef NS_ENUM(NSInteger, ChartLegendDirection) {
    ChartLegendDirectionLeftToRight,
    ChartLegendDirectionRightToLeft
};

typedef NS_ENUM(NSInteger, LabelPosition) {
    LabelPositionLeft,
    LabelPositionRight
};

typedef NS_ENUM(NSInteger, ImageFormat) {
    ImageFormatJPEG,
    ImageFormatPNG
};

typedef NS_ENUM(NSInteger, XAxisLabelPosition) {
    XAxisLabelPositionTop,
    XAxisLabelPositionBottom,
    XAxisLabelPositionBothSided,
    XAxisLabelPositionTopInside,
    XAxisLabelPositionBottomInside
};

typedef NS_ENUM(NSInteger, YAxisLabelPosition) {
    YAxisLabelPositionOutsideChart,
    YAxisLabelPositionInsideChart
};

typedef NS_ENUM(NSInteger, AxisDependency) {
    AxisDependencyLeft,
    AxisDependencyRight
};

typedef NS_ENUM(NSInteger, DrawOrder) {
    DrawOrderBar,
    DrawOrderLine,
    DrawOrderCandle,
    DrawOrderScatter
};

typedef NS_ENUM(NSInteger, ScatterShape) {
    ScatterShapeCross,
    ScatterShapeTriangle,
    ScatterShapeCircle,
    ScatterShapeSquare,
    ScatterShapeCustom
};

typedef NS_ENUM(NSInteger, ChartLimitLabelPosition) {
    ChartLimitLabelPositionLeft,
    ChartLimitLabelPositionRight
};

#endif
