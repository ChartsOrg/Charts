//
//  ScatterChartViewController.m
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

#import "ScatterChartViewController.h"
#import "ChartsDemo-Swift.h"

@interface ScatterChartViewController () <ChartViewDelegate>

@property (nonatomic, strong) IBOutlet ScatterChartView *chartView;
@property (nonatomic, strong) IBOutlet UISlider *sliderX;
@property (nonatomic, strong) IBOutlet UISlider *sliderY;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextX;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextY;

@end

@implementation ScatterChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Scatter Bar Chart";
    
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
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
    
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.maxVisibleValueCount = 200;
    _chartView.pinchZoomEnabled = YES;
    
    ChartLegend *l = _chartView.legend;
    l.position = ChartLegendPositionRightOfChart;
    l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.f];
    
    ChartYAxis *yl = _chartView.leftAxis;
    yl.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.f];
    yl.axisMinValue = 0.0; // this replaces startAtZero = YES
    
    _chartView.rightAxis.enabled = NO;
    
    ChartXAxis *xl = _chartView.xAxis;
    xl.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.f];
    xl.drawGridLinesEnabled = NO;
    
    _sliderX.value = 45.0;
    _sliderY.value = 100.0;
    [self slidersValueChanged:nil];
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
    
    [self setDataCount:(_sliderX.value + 1) range:_sliderY.value];
}

- (void)setDataCount:(int)count range:(double)range
{
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        [xVals addObject:[@(i) stringValue]];
    }
    
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals3 = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        double val = (double) (arc4random_uniform(range)) + 3;
        [yVals1 addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
        
        val = (double) (arc4random_uniform(range)) + 3;
        [yVals2 addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
        
        val = (double) (arc4random_uniform(range)) + 3;
        [yVals3 addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
    }
    
    ScatterChartDataSet *set1 = [[ScatterChartDataSet alloc] initWithYVals:yVals1 label:@"DS 1"];
    set1.scatterShape = ScatterShapeSquare;
    [set1 setColor:ChartColorTemplates.colorful[0]];
    ScatterChartDataSet *set2 = [[ScatterChartDataSet alloc] initWithYVals:yVals2 label:@"DS 2"];
    set2.scatterShape = ScatterShapeCircle;
    set2.scatterShapeHoleColor = ChartColorTemplates.colorful[3];
    set2.scatterShapeHoleRadius = 3.5f;
    [set2 setColor:ChartColorTemplates.colorful[1]];
    ScatterChartDataSet *set3 = [[ScatterChartDataSet alloc] initWithYVals:yVals3 label:@"DS 3"];
    set3.scatterShape = ScatterShapeCross;
    [set3 setColor:ChartColorTemplates.colorful[2]];
    
    set1.scatterShapeSize = 8.0;
    set2.scatterShapeSize = 8.0;
    set3.scatterShapeSize = 8.0;
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    [dataSets addObject:set2];
    [dataSets addObject:set3];
    
    ScatterChartData *data = [[ScatterChartData alloc] initWithXVals:xVals dataSets:dataSets];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:7.f]];
    
    _chartView.data = data;
}

- (void)optionTapped:(NSString *)key
{
    [super handleOption:key forChartView:_chartView];
}

#pragma mark - Actions

- (IBAction)slidersValueChanged:(id)sender
{
    _sliderTextX.text = [@((int)_sliderX.value + 1) stringValue];
    _sliderTextY.text = [@((int)_sliderY.value) stringValue];
    
    [self updateChartData];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull )entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
