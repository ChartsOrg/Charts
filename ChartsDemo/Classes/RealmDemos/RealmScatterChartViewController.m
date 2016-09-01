//
//  RealmScatterChartViewController.m
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import "RealmScatterChartViewController.h"
#import "ChartsDemo-Swift.h"
#import <Realm/Realm.h>
#import "RealmDemoData.h"

@interface RealmScatterChartViewController () <ChartViewDelegate>

@property (nonatomic, strong) IBOutlet ScatterChartView *chartView;

@end

@implementation RealmScatterChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self writeRandomDataToDbWithObjectCount:45];
    
    self.title = @"Realm.io Scatter Chart";
    
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
    
    _chartView.leftAxis.drawGridLinesEnabled = NO;
    _chartView.xAxis.drawGridLinesEnabled = NO;
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
    
    RealmScatterDataSet *set = [[RealmScatterDataSet alloc] initWithResults:results xValueField:@"xValue" yValueField:@"yValue"];
    
    set.label = @"Realm ScatterDataSet";
    set.scatterShapeSize = 9.f;
    [set setColor:[ChartColorTemplates colorFromString:@"#CDDC39"]];
    [set setScatterShape:ScatterShapeCircle];
    
    NSArray<id <IChartDataSet>> *dataSets = @[set];
    
    ScatterChartData *data = [[ScatterChartData alloc] initWithDataSets:dataSets];
    [self styleData:data];
    
    [_chartView zoomWithScaleX:5.f scaleY:1.f x:0.f y:0.f];
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
