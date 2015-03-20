//
//  CombinedChartViewController.m
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 17/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

#import "CombinedChartViewController.h"
#import "ChartsDemo-Swift.h"

@interface CombinedChartViewController () <ChartViewDelegate>

@property (nonatomic, strong) IBOutlet CombinedChartView *chartView;

@end

@implementation CombinedChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Combined Chart";
    
    self.options = @[
                     @{@"key": @"toggleLineValues", @"label": @"Toggle Line Values"},
                     @{@"key": @"toggleBarValues", @"label": @"Toggle Bar Values"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     ];
    
    _chartView.delegate = self;
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"You need to provide data for the chart.";
    
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.drawBarShadowEnabled = NO;
    
    _chartView.drawOrder = @[@(DrawOrderBar), @(DrawOrderLine)];
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.drawGridLinesEnabled = NO;
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.drawGridLinesEnabled = NO;
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBothSided;
    
    CombinedChartData *data = [[CombinedChartData alloc] initWithXVals:months];
    data.lineData = [self generateLineData];
    data.barData = [self generateBarData];
    
    _chartView.data = data;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)optionTapped:(NSString *)key
{
    if ([key isEqualToString:@"toggleLineValues"])
    {
        for (ChartDataSet *set in _chartView.data.dataSets)
        {
            if ([set isKindOfClass:LineChartDataSet.class])
            {
                set.drawValuesEnabled = !set.isDrawValuesEnabled;
            }
        }
        
        [_chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"toggleBarValues"])
    {
        for (ChartDataSet *set in _chartView.data.dataSets)
        {
            if ([set isKindOfClass:BarChartDataSet.class])
            {
                set.drawValuesEnabled = !set.isDrawValuesEnabled;
            }
        }
        
        [_chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"saveToGallery"])
    {
        [_chartView saveToCameraRoll];
    }
}

- (LineChartData *)generateLineData
{
    LineChartData *d = [[LineChartData alloc] init];
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < 12; index++)
    {
        [entries addObject:[[ChartDataEntry alloc] initWithValue:(arc4random_uniform(15) + 10) xIndex:index]];
    }
    
    LineChartDataSet *set = [[LineChartDataSet alloc] initWithYVals:entries label:@"Line DataSet"];
    [set setColor:[UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f]];
    set.lineWidth = 2.5f;
    [set setCircleColor:[UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f]];
    set.fillColor = [UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f];
    set.drawCubicEnabled = YES;
    set.drawValuesEnabled = YES;
    set.valueFont = [UIFont systemFontOfSize:10.f];
    set.valueTextColor = [UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f];
    
    set.axisDependency = AxisDependencyLeft;
    
    [d addDataSet:set];
    
    return d;
}

- (BarChartData *)generateBarData
{
    BarChartData *d = [[BarChartData alloc] init];
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < 12; index++)
    {
        [entries addObject:[[BarChartDataEntry alloc] initWithValue:(arc4random_uniform(15) + 30) xIndex:index]];
    }
    
    BarChartDataSet *set = [[BarChartDataSet alloc] initWithYVals:entries label:@"Bar DataSet"];
    [set setColor:[UIColor colorWithRed:60/255.f green:220/255.f blue:78/255.f alpha:1.f]];
    set.valueTextColor = [UIColor colorWithRed:60/255.f green:220/255.f blue:78/255.f alpha:1.f];
    set.valueFont = [UIFont systemFontOfSize:10.f];
    
    set.axisDependency = AxisDependencyLeft;
    
    [d addDataSet:set];
    
    return d;
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(__nonnull ChartViewBase *)chartView entry:(__nonnull ChartDataEntry *)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(__nonnull ChartHighlight *)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(__nonnull ChartViewBase *)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
