//
//  NegativeStackedBarChartViewController.m
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 17/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import "NegativeStackedBarChartViewController.h"
#import "ChartsDemo-Swift.h"

@interface NegativeStackedBarChartViewController () <ChartViewDelegate>

@property (nonatomic, strong) IBOutlet HorizontalBarChartView *chartView;

@end

@implementation NegativeStackedBarChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Stacked Bar Chart Negative";
    
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"toggleHighlightArrow", @"label": @"Toggle Highlight Arrow"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
                     @{@"key": @"toggleData", @"label": @"Toggle Data"},
                     @{@"key": @"toggleBarBorders", @"label": @"Show Bar Borders"},
                     ];
    
    NSNumberFormatter *customFormatter = [[NSNumberFormatter alloc] init];
    customFormatter.negativePrefix = @"";
    customFormatter.positiveSuffix = @"m";
    customFormatter.negativeSuffix = @"m";
    customFormatter.minimumSignificantDigits = 1;
    customFormatter.minimumFractionDigits = 1;
    
    _chartView.delegate = self;
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"You need to provide data for the chart.";
    
    _chartView.drawBarShadowEnabled = NO;
    _chartView.drawValueAboveBarEnabled = YES;
    
    // scaling can now only be done on x- and y-axis separately
    _chartView.pinchZoomEnabled = NO;
    
    _chartView.drawBarShadowEnabled = NO;
    _chartView.drawValueAboveBarEnabled = YES;
    
    _chartView.leftAxis.enabled = NO;
    _chartView.rightAxis.axisMaxValue = 25.0;
    _chartView.rightAxis.axisMinValue = -25.0;
    _chartView.rightAxis.drawGridLinesEnabled = NO;
    _chartView.rightAxis.drawZeroLineEnabled = YES;
    _chartView.rightAxis.labelCount = 7;
    _chartView.rightAxis.valueFormatter = customFormatter;
    _chartView.rightAxis.labelFont = [UIFont systemFontOfSize:9.f];
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBothSided;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.drawAxisLineEnabled = NO;
    _chartView.rightAxis.labelFont = [UIFont systemFontOfSize:9.f];
    
    ChartLegend *l = _chartView.legend;
    l.position = ChartLegendPositionBelowChartRight;
    l.formSize = 8.f;
    l.formToTextSpace = 4.f;
    l.xEntrySpace = 6.f;
    
    [self updateChartData];
}

- (void)updateChartData
{
    if (self.shouldHideData)
    {
        _chartView.data = nil;
        return;
    }
    
    [self setChartData];
}

- (void)setChartData
{
    NSMutableArray *yValues = [NSMutableArray array];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-10, @10 ] xIndex: 0]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-12, @13 ] xIndex: 1]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-15, @15 ] xIndex: 2]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-17, @17 ] xIndex: 3]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-19, @20 ] xIndex: 4]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-19, @19 ] xIndex: 5]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-16, @16 ] xIndex: 6]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-13, @14 ] xIndex: 7]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-10, @11 ] xIndex: 8]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-5, @6 ] xIndex: 9]];
    [yValues addObject:[[BarChartDataEntry alloc] initWithValues:@[ @-1, @2 ] xIndex: 10]];
    
    BarChartDataSet *set = nil;
    if (_chartView.data.dataSetCount > 0)
    {
        set = (BarChartDataSet *)_chartView.data.dataSets[0];
        set.yVals = yValues;
        [_chartView notifyDataSetChanged];
    }
    else
    {
        set = [[BarChartDataSet alloc] initWithYVals:yValues label:@"Age Distribution"];
        set.valueFormatter = _chartView.rightAxis.valueFormatter;
        set.valueFont = [UIFont systemFontOfSize:7.f];
        set.axisDependency = AxisDependencyRight;
        set.barSpace = 0.4f;
        set.colors = @[
                       [UIColor colorWithRed:67/255.f green:67/255.f blue:72/255.f alpha:1.f],
                       [UIColor colorWithRed:124/255.f green:181/255.f blue:236/255.f alpha:1.f]
                       ];
        set.stackLabels = @[
                            @"Men", @"Women"
                            ];
        
        NSArray *xVals = @[ @"0-10", @"10-20", @"20-30", @"30-40", @"40-50", @"50-60", @"60-70", @"70-80", @"80-90", @"90-100", @"100+" ];
        
        BarChartData *data = [[BarChartData alloc] initWithXVals:xVals dataSet:set];
        _chartView.data = data;
        [_chartView setNeedsDisplay];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)optionTapped:(NSString *)key
{
    [super handleOption:key forChartView:_chartView];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected, stack-index %ld", (long)highlight.stackIndex);
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
