//
//  SinusBarChartViewController.m
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

#import "SinusBarChartViewController.h"
#import "ChartsDemo-Swift.h"

@interface SinusBarChartViewController () <ChartViewDelegate>

@property (nonatomic, strong) IBOutlet BarChartView *chartView;
@property (nonatomic, strong) IBOutlet UISlider *sliderX;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextX;

@end

@implementation SinusBarChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Sinus Bar Chart";
    
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
                     ];
    
    _chartView.delegate = self;
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"You need to provide data for the chart.";
    
    _chartView.drawBarShadowEnabled = NO;
    _chartView.drawValueAboveBarEnabled = YES;
    _chartView.maxVisibleValueCount = 60;
    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = NO;
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.f];
    xAxis.drawGridLinesEnabled = NO;
    xAxis.enabled = NO;
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.f];
    leftAxis.labelCount = 6;
    leftAxis.axisMinValue = -2.5;
    leftAxis.axisMaxValue = 2.5;
    leftAxis.granularityEnabled = true;
    leftAxis.granularity = 0.1;
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.drawGridLinesEnabled = NO;
    rightAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.f];
    rightAxis.labelCount = 6;
    rightAxis.axisMinValue = -2.5;
    rightAxis.axisMaxValue = 2.5;
    rightAxis.granularity = 0.1;
        
    ChartLegend *l = _chartView.legend;
    l.position = ChartLegendPositionBelowChartLeft;
    l.form = ChartLegendFormSquare;
    l.formSize = 9.0;
    l.font = [UIFont systemFontOfSize:11.f];
    l.xEntrySpace = 4.0;
    
    _sliderX.value = 150.0;
    [self slidersValueChanged:nil];
    
    [_chartView animateWithXAxisDuration:2.0 yAxisDuration:2.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateChartData
{
    if (self.shouldHideData)
    {
        _chartView.data = nil;
        return;
    }
    
    [self setDataCount:(_sliderX.value)];
}

- (void)setDataCount:(int)count
{
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        [xVals addObject:[@(i) stringValue]];
        [entries addObject:[[BarChartDataEntry alloc] initWithValue:sinf(M_PI * (i % 128) / 64.0) xIndex:i]];
    }
    
    BarChartDataSet *set = nil;
    if (_chartView.data.dataSetCount > 0)
    {
        set = (BarChartDataSet *)_chartView.data.dataSets[0];
        set.yVals = entries;
        _chartView.data.xValsObjc = xVals;
        [_chartView notifyDataSetChanged];
    }
    else
    {
        set = [[BarChartDataSet alloc] initWithYVals:entries label:@"Sinus Function"];
        set.barSpace = 0.4;
        [set setColor:[UIColor colorWithRed:240/255.f green:120/255.f blue:124/255.f alpha:1.f]];
        
        BarChartData *data = [[BarChartData alloc] initWithXVals:xVals dataSet:set];
        [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
        [data setDrawValues:NO];
        
        _chartView.data = data;
    }
}

- (void)optionTapped:(NSString *)key
{
    [super handleOption:key forChartView:_chartView];
}

#pragma mark - Actions

- (IBAction)slidersValueChanged:(id)sender
{
    _sliderTextX.text = [@((int)_sliderX.value + 1) stringValue];
    
    [self updateChartData];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
