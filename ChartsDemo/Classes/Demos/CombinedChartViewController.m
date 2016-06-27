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
//  https://github.com/danielgindi/Charts
//

#import "CombinedChartViewController.h"
#import "ChartsDemo-Swift.h"

#define ITEM_COUNT 12

@interface CombinedChartViewController () <ChartViewDelegate>

@property (nonatomic, strong) IBOutlet KlineChartView *chartView;

@property (nonatomic, strong) CandleChartData *candleData;

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
                     @{@"key": @"toggleData", @"label": @"Toggle Data"},
                     @{@"key": @"toggleBarBorders", @"label": @"Show Bar Borders"},
                     ];
//    
//    _chartView.delegate = self;
//    
//    _chartView.descriptionText = @"";
//    _chartView.noDataTextDescription = @"You need to provide data for the chart.";
//    
//    _chartView.drawGridBackgroundEnabled = NO;
//    _chartView.drawBarShadowEnabled = NO;
//    
//    _chartView.autoScaleMinMaxEnabled = YES;
//    _chartView.drawOrder = @[
////                             @(CombinedChartDrawOrderBar),
////                             @(CombinedChartDrawOrderBubble),
//                            @(CombinedChartDrawOrderLine),
//                             @(CombinedChartDrawOrderCandle),
//                        
////                             @(CombinedChartDrawOrderScatter)
//                             ];
//    
//    ChartYAxis *rightAxis = _chartView.rightAxis;
//    rightAxis.drawGridLinesEnabled = NO;
////    rightAxis.axisMinValue = 0.0; // this replaces startAtZero = YES
//    
//    ChartYAxis *leftAxis = _chartView.leftAxis;
//    leftAxis.drawGridLinesEnabled = NO;
////    leftAxis.axisMinValue = 0.0; // this replaces startAtZero = YES
//    
//    ChartXAxis *xAxis = _chartView.xAxis;
//    xAxis.labelPosition = XAxisLabelPositionBothSided;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
        [self updateChartData];
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
        _chartView.klineData = nil;
        return;
    }
    
    [self setChartData];
}

- (void)setChartData
{
//    NSMutableArray *xVals = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < 50; i++)
//    {
//        [xVals addObject:[@(i + 1990) stringValue]];
//    }
//    KlineChartData *data = [[KlineChartData alloc] initWithXVals:xVals];


//    data.candleData =
//    da
//    self.candleData =  [self generateCandleData];
//    data.candleData = self.candleData;
//    data.lineData = [self generateLineData];
//    data.candleData = nil;
//    data.barData = [self generateBarData];
//    data.bubbleData = [self generateBubbleData];
//    data.scatterData = [self generateScatterData];
    [self generateCandleData];
    
 
}

- (void)optionTapped:(NSString *)key
{
//    if ([key isEqualToString:@"toggleLineValues"])
//    {
//        for (NSObject<IChartDataSet> *set in _chartView.data.dataSets)
//        {
//            if ([set isKindOfClass:LineChartDataSet.class])
//            {
//                set.drawValuesEnabled = !set.isDrawValuesEnabled;
//            }
//        }
//        
//        [_chartView setNeedsDisplay];
//        return;
//    }
//    
//    if ([key isEqualToString:@"toggleBarValues"])
//    {
//        for (NSObject<IChartDataSet> *set in _chartView.data.dataSets)
//        {
//            if ([set isKindOfClass:BarChartDataSet.class])
//            {
//                set.drawValuesEnabled = !set.isDrawValuesEnabled;
//            }
//        }
//        
//        [_chartView setNeedsDisplay];
//        return;
//    }
//    
//    [super handleOption:key forChartView:_chartView];
    
    if (self.chartView.klineData.qualificationType == KlineQualificationMACD) {
        self.chartView.klineData.qualificationType = KlineQualificationKDJ;
//        self.chartView.d
    } else {
        self.chartView.klineData.qualificationType = KlineQualificationMACD;
    }
    
    [self.chartView resetData];
}


//- (LineChartData *)generateLineData
//{


//    NSArray *entries = [((CandleChartDataSet *)[self candleData].dataSets[0]) EMAValuesForNum:5];
//    
//    LineChartDataSet *set = [[LineChartDataSet alloc] initWithYVals:entries label:@"Line DataSet"];
//    [set setColor:[UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f]];
//    set.lineWidth = 2.5;
//    [set setCircleColor:[UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f]];
//    set.fillColor = [UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f];
//    set.drawCubicEnabled = YES;
//     set.drawCirclesEnabled = NO;
//    set.drawValuesEnabled = NO;
//    set.valueFont = [UIFont systemFontOfSize:10.f];
//    set.valueTextColor = [UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f];
//    
//    set.axisDependency = AxisDependencyLeft;
//    
//        NSArray *entries1 = [((CandleChartDataSet *)[self candleData].dataSets[0]) EMAValuesForNum:10];
//    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:entries1 label:@"Line DataSet"];
//    [set1 setColor:[UIColor colorWithRed:220/255.f green:0 blue:70 alpha:1.f]];
//    set1.lineWidth = 2.5;
//    [set1 setCircleColor:[UIColor colorWithRed:220/255.f green:0 blue:0 alpha:1.f]];
//    set1.fillColor = [UIColor colorWithRed:220/255.f  green:0 blue:0 alpha:1.f];
//    set1.drawCubicEnabled = YES;
//    set1.drawCirclesEnabled = NO;
//    set1.drawValuesEnabled = NO;
//    set1.valueFont = [UIFont systemFontOfSize:10.f];
//    set1.valueTextColor = [UIColor colorWithRed:220/255.f green:0 blue:0 alpha:1.f];
//    set.axisDependency = AxisDependencyLeft;
//    
//            NSArray *entries2 = [((CandleChartDataSet *)[self candleData].dataSets[0]) EMAValuesForNum:30];
//    LineChartDataSet *set2 = [[LineChartDataSet alloc] initWithYVals:entries2 label:@"Line DataSet"];
//    [set2 setColor:[UIColor colorWithRed:0 green:220/255.f blue:0 alpha:1.f]];
//    set2.lineWidth = 2.5;
//    [set2 setCircleColor:[UIColor colorWithRed:0 green:220/255.f blue:0 alpha:1.f]];
//    set2.fillColor = [UIColor colorWithRed:0  green:220/255.f blue:0 alpha:1.f];
//    set2.drawCubicEnabled = YES;
//    set2.drawValuesEnabled = NO;
//     set2.drawCirclesEnabled = NO;
//    set2.valueFont = [UIFont systemFontOfSize:10.f];
//    set2.valueTextColor = [UIColor colorWithRed:0 green:220/255.f blue:0 alpha:1.f];
//    set2.axisDependency = AxisDependencyLeft;
//    
//    
//    NSMutableArray *xVals = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < 50; i++)
//    {
//        [xVals addObject:[@(i + 1990) stringValue]];
//    }
//    
////    var sets = 
//    
//    LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:@[set,set1,set2]];
//
//    return data;
//}

- (BarChartData *)generateBarData
{
    BarChartData *d = [[BarChartData alloc] init];
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < ITEM_COUNT; index++)
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

- (ScatterChartData *)generateScatterData
{
    ScatterChartData *d = [[ScatterChartData alloc] init];
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < ITEM_COUNT; index++)
    {
        [entries addObject:[[ChartDataEntry alloc] initWithValue:(arc4random_uniform(20) + 15) xIndex:index]];
    }
    
    ScatterChartDataSet *set = [[ScatterChartDataSet alloc] initWithYVals:entries label:@"Scatter DataSet"];
    [set setColor:[UIColor greenColor]];
    set.scatterShapeSize = 7.5;
    [set setDrawValuesEnabled:YES];
    set.valueFont = [UIFont systemFontOfSize:10.f];
    
    [d addDataSet:set];
    
    return d;
}

- (void )generateCandleData
{
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
       
      KlineChartData *data = [self setDataCount:(1000) range:3000];
       
       dispatch_async(dispatch_get_main_queue(), ^{
           _chartView.klineData = data;
       });
    
   });
    
//    return
}

- (KlineChartData *)setDataCount:(int)count range:(double)range
{
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        [xVals addObject:[@(i + 1990) stringValue]];
    }
    
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        double mult = (range + 1);
        double val = (double) (arc4random_uniform(40)) + mult;
        double high = (double) (arc4random_uniform(9)) + 8.0;
        double low = (double) (arc4random_uniform(9)) + 8.0;
        double open = (double) (arc4random_uniform(6)) + 1.0;
        double close = (double) (arc4random_uniform(6)) + 1.0;
        BOOL even = i % 2 == 0;
        [yVals1 addObject:[[KlineChartDataEntry alloc] initWithXIndex:i shadowH:val + high shadowL:val - low open:even ? val + open : val - open close:even ? val - close : val + close]];
    }
    
    KlineChartDataSet *set1 = [[KlineChartDataSet alloc] initWithYVals:yVals1 label:@"KLine"];
    set1.axisDependency = AxisDependencyLeft;
    set1.drawValuesEnabled = false;
    set1.shadowColorSameAsCandle = true;
    [set1 setColor:[UIColor colorWithWhite:80/255.f alpha:1.f]];
    
    set1.shadowColor = UIColor.darkGrayColor;
    set1.shadowWidth = 0.7;
    set1.increasingColor =  [UIColor colorWithRed:255/255.f green:48/255.f blue:66/255.f alpha:1.f];
    set1.decreasingColor = [UIColor colorWithRed:0/255.f green:191/255.f blue:128/255.f alpha:1.f];
    set1.neutralColor = UIColor.blueColor;
    
    KlineChartData *data = [[KlineChartData alloc] initWithXVals:xVals dataSet:set1];
    data.qualificationType = KlineQualificationMACD;
    
    return data;
}

- (BubbleChartData *)generateBubbleData
{
    BubbleChartData *bd = [[BubbleChartData alloc] init];
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < ITEM_COUNT; index++)
    {
        double rnd = arc4random_uniform(20) + 30.f;
        [entries addObject:[[BubbleChartDataEntry alloc] initWithXIndex:index value:rnd size:rnd]];
    }
    
    BubbleChartDataSet *set = [[BubbleChartDataSet alloc] initWithYVals:entries label:@"Bubble DataSet"];
    [set setColors:ChartColorTemplates.vordiplom];
    set.valueTextColor = UIColor.whiteColor;
    set.valueFont = [UIFont systemFontOfSize:10.f];
    [set setDrawValuesEnabled:YES];
    
    [bd addDataSet:set];
    
    return bd;
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected %@",entry);
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
