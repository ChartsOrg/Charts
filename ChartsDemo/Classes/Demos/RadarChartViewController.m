//
//  RadarChartViewController.m
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

#import "RadarChartViewController.h"
#import "ChartsDemo-Swift.h"

@interface RadarChartViewController () <ChartViewDelegate>

@property (nonatomic, strong) IBOutlet RadarChartView *chartView;

@end

@implementation RadarChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Radar Bar Chart";
    
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"toggleHighlightCircle", @"label": @"Toggle highlight circle"},
                     @{@"key": @"toggleXLabels", @"label": @"Toggle X-Values"},
                     @{@"key": @"toggleYLabels", @"label": @"Toggle Y-Values"},
                     @{@"key": @"toggleRotate", @"label": @"Toggle Rotate"},
                     @{@"key": @"toggleFill", @"label": @"Toggle Fill"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"spin", @"label": @"Spin"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"toggleData", @"label": @"Toggle Data"},
                     ];
    
    _chartView.delegate = self;
    
    _chartView.descriptionText = @"";
    _chartView.webLineWidth = .75;
    _chartView.innerWebLineWidth = 0.375;
    _chartView.webAlpha = 1.0;
    
    BalloonMarker *marker = [[BalloonMarker alloc] initWithColor:[UIColor colorWithWhite:180/255. alpha:1.0] font:[UIFont systemFontOfSize:12.0] insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)];
    marker.minimumSize = CGSizeMake(80.f, 40.f);
    _chartView.marker = marker;
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.f];
    
    ChartYAxis *yAxis = _chartView.yAxis;
    yAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.f];
    yAxis.labelCount = 5;
    yAxis.axisMinValue = 0.0;
    
    ChartLegend *l = _chartView.legend;
    l.position = ChartLegendPositionRightOfChart;
    l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.f];
    l.xEntrySpace = 7.0;
    l.yEntrySpace = 5.0;
    
    [self updateChartData];
    
    [_chartView animateWithXAxisDuration:1.4 yAxisDuration:1.4 easingOption:ChartEasingOptionEaseOutBack];
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
    
    [self setChartData];
}

- (void)setChartData
{
    double mult = 150.f;
    int count = 9;
    
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        [yVals1 addObject:[[ChartDataEntry alloc] initWithValue:(arc4random_uniform(mult) + mult / 2) xIndex:i]];
        [yVals2 addObject:[[ChartDataEntry alloc] initWithValue:(arc4random_uniform(mult) + mult / 2) xIndex:i]];
    }
    
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        [xVals addObject:parties[i % parties.count]];
    }
    
    RadarChartDataSet *set1 = [[RadarChartDataSet alloc] initWithYVals:yVals1 label:@"Set 1"];
    [set1 setColor:ChartColorTemplates.vordiplom[0]];
    set1.fillColor = ChartColorTemplates.vordiplom[0];
    set1.drawFilledEnabled = YES;
    set1.lineWidth = 2.0;
    
    RadarChartDataSet *set2 = [[RadarChartDataSet alloc] initWithYVals:yVals2 label:@"Set 2"];
    [set2 setColor:ChartColorTemplates.vordiplom[4]];
    set2.fillColor = ChartColorTemplates.vordiplom[4];
    set2.drawFilledEnabled = YES;
    set2.lineWidth = 2.0;
    
    RadarChartData *data = [[RadarChartData alloc] initWithXVals:xVals dataSets:@[set1, set2]];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:8.f]];
    [data setDrawValues:NO];
    
    _chartView.data = data;
}

- (void)optionTapped:(NSString *)key
{
    if ([key isEqualToString:@"toggleXLabels"])
    {
        _chartView.xAxis.drawLabelsEnabled = !_chartView.xAxis.isDrawLabelsEnabled;
        
        [_chartView notifyDataSetChanged];
        [_chartView setNeedsDisplay];
        return;
    }
    
    if ([key isEqualToString:@"toggleYLabels"])
    {
        _chartView.yAxis.drawLabelsEnabled = !_chartView.yAxis.isDrawLabelsEnabled;
        [_chartView setNeedsDisplay];
        return;
    }

    if ([key isEqualToString:@"toggleRotate"])
    {
        _chartView.rotationEnabled = !_chartView.isRotationEnabled;
        return;
    }
    
    if ([key isEqualToString:@"toggleFill"])
    {
        for (RadarChartDataSet *set in _chartView.data.dataSets)
        {
            set.drawFilledEnabled = !set.isDrawFilledEnabled;
        }
        
        [_chartView setNeedsDisplay];
        return;
    }
    
    if ([key isEqualToString:@"toggleHighlightCircle"])
    {
        for (RadarChartDataSet *set in _chartView.data.dataSets)
        {
            set.drawHighlightCircleEnabled = !set.drawHighlightCircleEnabled;
        }
        
        [_chartView setNeedsDisplay];
        return;
    }
    
    if ([key isEqualToString:@"animateX"])
    {
        [_chartView animateWithXAxisDuration:1.4];
        return;
    }
    
    if ([key isEqualToString:@"animateY"])
    {
        [_chartView animateWithYAxisDuration:1.4];
        return;
    }
    
    if ([key isEqualToString:@"animateXY"])
    {
        [_chartView animateWithXAxisDuration:1.4 yAxisDuration:1.4];
        return;
    }
    
    if ([key isEqualToString:@"spin"])
    {
        [_chartView spinWithDuration:2.0 fromAngle:_chartView.rotationAngle toAngle:_chartView.rotationAngle + 360.f easingOption:ChartEasingOptionEaseInCubic];
        return;
    }
    
    [super handleOption:key forChartView:_chartView];
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
