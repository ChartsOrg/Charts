//
//  RealmBubbleChartViewController.m
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import "RealmBubbleChartViewController.h"
#import "ChartsDemo-Swift.h"
#import <Realm/Realm.h>
#import "RealmDemoData.h"

@interface RealmBubbleChartViewController () <ChartViewDelegate>

@property (nonatomic, strong) IBOutlet BubbleChartView *chartView;

@end

@implementation RealmBubbleChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self writeRandomBubbleDataToDbWithObjectCount:10];
    
    self.title = @"Realm.io Bubble Chart";
    
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
                     ];
    
    _chartView.delegate = self;
    
    [self setupBarLineChartView:_chartView];
    
    _chartView.xAxis.drawGridLinesEnabled = NO;
    _chartView.leftAxis.drawGridLinesEnabled = NO;
    _chartView.pinchZoomEnabled = YES;
    
    [self setData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setData
{
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults *results = [RealmDemoData allObjectsInRealm:realm];
    
    RealmBubbleDataSet *set = [[RealmBubbleDataSet alloc] initWithResults:results xValueField:@"xValue" yValueField:@"yValue" sizeField:@"bubbleSize"];
    
    set.label = @"Realm BubbleDataSet";
    [set setColors:ChartColorTemplates.colorful alpha:0.43f];
    
    NSArray<id <IChartDataSet>> *dataSets = @[set];
    
    BubbleChartData *data = [[BubbleChartData alloc] initWithDataSets:dataSets];
    [self styleData:data];
    
    _chartView.data = data;
    
    [_chartView animateWithYAxisDuration:1.4 easingOption:ChartEasingOptionEaseInOutQuart];
}

- (void)optionTapped:(NSString *)key
{
    [super handleOption:key forChartView:_chartView];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
